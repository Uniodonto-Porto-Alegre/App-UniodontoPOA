import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import '../model/beneficiario_model.dart';
import '../services/reembolso_form_service.dart';
import '../widgets/reembolso_form_widgets.dart';
import '../widgets/reembolso_form_steps.dart';
import '../widgets/form_controllers.dart';
import '../widgets/form_validation.dart';

class ModernReembolsoFormView extends StatefulWidget {
  const ModernReembolsoFormView({super.key});

  @override
  State<ModernReembolsoFormView> createState() =>
      _ModernReembolsoFormViewState();
}

class _ModernReembolsoFormViewState extends State<ModernReembolsoFormView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoadingBeneficiarios = true;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;

  // Models e Services
  List<BeneficiarioModel> _beneficiarios = [];
  BeneficiarioModel? _selectedBeneficiario;
  String? _titularName;
  List<dynamic> _anexosRecibos = []; // Alterado para aceitar File e XFile
  final ReembolsoFormService _formService = ReembolsoFormService();

  // Controllers
  final FormControllers _controllers = FormControllers();

  final List<String> _stepTitles = [
    'Dados do Beneficiário',
    'Dados do Dentista',
    'Anexos e Banco',
    'Revisão Final',
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.medical_services_outlined,
    Icons.attach_money_outlined,
    Icons.check_circle_outline,
  ];

  static const int _maxFiles = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadBeneficiarioData();
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadBeneficiarioData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('beneficiario_data');

      if (dataString != null) {
        final beneficiarios = beneficiarioModelFromJson(dataString);
        setState(() {
          _beneficiarios = beneficiarios;
          _titularName = beneficiarios
              .firstWhere((b) => b.tipo == 'TITULAR')
              .nome;
          _controllers.titularNome.text = _titularName ?? 'Não encontrado';
          _isLoadingBeneficiarios = false;
        });
      } else {
        setState(() {
          _isLoadingBeneficiarios = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBeneficiarios = false;
      });
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Erro ao carregar dados do beneficiário.',
      );
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId =
          prefs.getString('user_id') ?? prefs.getString('id_usuario') ?? '';
      final userEmail =
          prefs.getString('user_email') ??
          prefs.getString('email_usuario') ??
          '';

      setState(() {
        _controllers.idUsuario.text = userId;
        _controllers.emailUsuario.text = userEmail;
      });
    } catch (e) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Erro ao carregar dados do usuário.',
      );
    }
  }

  void _onBeneficiarioChanged(BeneficiarioModel? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedBeneficiario = newValue;
        _controllers.beneficiarioNome.text = newValue.nome;
        _controllers.beneficiarioCartao.text = newValue.carteira;
        _controllers.beneficiarioPlano.text = newValue.plano;
        _controllers.beneficiarioEmpresa.text = newValue.empresa;
      });
    }
  }

  Future<void> _pickFile() async {
    if (_anexosRecibos.length >= _maxFiles) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Você pode anexar no máximo $_maxFiles arquivos.',
      );
      return;
    }

    final picker = ImagePicker();
    final source = await ReembolsoFormUtils.showFileSourceBottomSheet(context);

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            // No web, usamos XFile diretamente
            _anexosRecibos.add(pickedFile);
          } else {
            // No mobile/desktop, convertemos para File
            _anexosRecibos.add(File(pickedFile.path));
          }
        });
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _anexosRecibos.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      if (_validateCurrentStep()) {
        _animationController.reset();
        setState(() {
          _currentStep += 1;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _animationController.forward();
      }
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.reset();
      setState(() {
        _currentStep -= 1;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
  }

  bool _validateCurrentStep() {
    return FormValidation.validateStep(
      context,
      _currentStep,
      _selectedBeneficiario,
      _controllers,
      _anexosRecibos,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_anexosRecibos.isEmpty) {
        ReembolsoFormUtils.showErrorSnackbar(
          context,
          'Por favor, anexe pelo menos um recibo ou nota fiscal.',
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        print('=== INÍCIO DO ENVIO DO FORMULÁRIO ===');

        final formData = FormDataHelper.buildFormData(_controllers);
        print('Dados do formulário:');
        formData.forEach((key, value) {
          print('$key: $value');
        });

        print('Chamando _formService.submitReembolso...');

        await _formService
            .submitReembolso(formData: formData, arquivos: _anexosRecibos)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException(
                  'Timeout na requisição',
                  const Duration(seconds: 30),
                );
              },
            );

        print('Formulário enviado com sucesso!');
        ReembolsoFormUtils.showSuccessDialog(context);
      } on FormSubmitException catch (e) {
        print('FormSubmitException capturada: ${e.toString()}');
        ReembolsoFormUtils.showErrorSnackbar(context, e.toString());
      } on TimeoutException catch (e) {
        print('TimeoutException: ${e.message}');
        ReembolsoFormUtils.showErrorSnackbar(
          context,
          'Tempo limite excedido. Verifique sua conexão e tente novamente.',
        );
      } on SocketException catch (e) {
        print('SocketException (problema de rede): $e');
        ReembolsoFormUtils.showErrorSnackbar(
          context,
          'Erro de conexão. Verifique sua internet e tente novamente.',
        );
      } on HttpException catch (e) {
        print('HttpException: $e');
        ReembolsoFormUtils.showErrorSnackbar(
          context,
          'Erro na comunicação com o servidor. Tente novamente.',
        );
      } on FormatException catch (e) {
        print('FormatException (resposta inválida): $e');
        ReembolsoFormUtils.showErrorSnackbar(
          context,
          'Resposta inválida do servidor. Tente novamente.',
        );
      } catch (e, stackTrace) {
        print('=== ERRO GENÉRICO CAPTURADO ===');
        print('Tipo do erro: ${e.runtimeType}');
        print('Erro: $e');
        print('Stack trace:');
        print(stackTrace);
        print('=== FIM DO LOG DE ERRO ===');

        String errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';

        if (kDebugMode) {
          errorMessage += '\n\nErro técnico: ${e.toString()}';
        }

        ReembolsoFormUtils.showErrorSnackbar(context, errorMessage);
      } finally {
        print('Finalizando _submitForm...');
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      print('Formulário inválido - validação falhou');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isSubmitting
          ? ReembolsoFormWidgets.buildLoadingScreen()
          : _buildFormScreen(),
    );
  }

  Widget _buildFormScreen() {
    return Column(
      children: [
        ReembolsoFormWidgets.buildModernAppBar(
          context,
          _stepTitles[_currentStep],
          _currentStep,
          _stepTitles.length,
        ),
        ReembolsoFormWidgets.buildProgressIndicator(
          _currentStep,
          _stepTitles.length,
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: _stepTitles.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildStepContent(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        ReembolsoFormWidgets.buildNavigationButtons(
          context,
          _currentStep,
          _stepTitles.length,
          _previousStep,
          _nextStep,
        ),
      ],
    );
  }

  Widget _buildStepContent(int step) {
    final stepBuilder = ReembolsoFormSteps(
      controllers: _controllers,
      beneficiarios: _beneficiarios,
      selectedBeneficiario: _selectedBeneficiario,
      onBeneficiarioChanged: _onBeneficiarioChanged,
      isLoadingBeneficiarios: _isLoadingBeneficiarios,
      anexosRecibos: _anexosRecibos,
      maxFiles: _maxFiles,
      onPickFile: _pickFile,
      onRemoveFile: _removeFile,
      stepTitles: _stepTitles,
      stepIcons: _stepIcons,
    );

    Widget content;
    switch (step) {
      case 0:
        content = stepBuilder.buildStepBeneficiario();
        break;
      case 1:
        content = stepBuilder.buildStepDentista();
        break;
      case 2:
        content = stepBuilder.buildStepReciboBancario();
        break;
      case 3:
        content = stepBuilder.buildStepRevisao();
        break;
      default:
        content = const SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReembolsoFormWidgets.buildStepHeader(
            _stepIcons[step],
            _stepTitles[step],
          ),
          const SizedBox(height: 24),
          content,
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class FormSubmitException implements Exception {
  final String message;
  FormSubmitException(this.message);
}
