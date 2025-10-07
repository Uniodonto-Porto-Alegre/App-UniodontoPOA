import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../services/forgot_password_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _cpfFocusNode = FocusNode();
  final FocusNode _birthDateFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _cpfFocused = false;
  bool _birthDateFocused = false;
  bool _newPasswordFocused = false;
  bool _confirmPasswordFocused = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _identificationFound = false;
  bool _passwordChanged = false;

  String? _errorMessage;
  RecuperarIdentificacaoResponse? _userIdentification;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successFadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _successFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _setupFocusListeners();

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _setupFocusListeners() {
    _cpfFocusNode.addListener(() {
      setState(() {
        _cpfFocused = _cpfFocusNode.hasFocus;
        if (_cpfFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });

    _birthDateFocusNode.addListener(() {
      setState(() {
        _birthDateFocused = _birthDateFocusNode.hasFocus;
        if (_birthDateFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });

    _newPasswordFocusNode.addListener(() {
      setState(() {
        _newPasswordFocused = _newPasswordFocusNode.hasFocus;
        if (_newPasswordFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });

    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _confirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
        if (_confirmPasswordFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _birthDateController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _cpfFocusNode.dispose();
    _birthDateFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _formatCpf(String value) {
    if (value.isEmpty) return;

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length > 11) {
      _cpfController.text = cleaned.substring(0, 11);
      _cpfController.selection = TextSelection.collapsed(
        offset: _cpfController.text.length,
      );
      return;
    }

    if (cleaned.length >= 3 && !value.contains('.')) {
      final formatted = Validators.formatCpf(cleaned);
      if (formatted != value) {
        _cpfController.text = formatted;
        _cpfController.selection = TextSelection.collapsed(
          offset: formatted.length,
        );
      }
    }
  }

  void _formatBirthDate(String value) {
    if (value.isEmpty) return;

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length > 8) {
      _birthDateController.text = cleaned.substring(0, 8);
      _birthDateController.selection = TextSelection.collapsed(
        offset: _birthDateController.text.length,
      );
      return;
    }

    String formatted = cleaned;
    if (cleaned.length >= 2) {
      formatted = '${cleaned.substring(0, 2)}/';
      if (cleaned.length >= 4) {
        formatted += '${cleaned.substring(2, 4)}/';
        if (cleaned.length > 4) {
          formatted += cleaned.substring(4);
        }
      } else if (cleaned.length > 2) {
        formatted += cleaned.substring(2);
      }
    }

    if (formatted != value) {
      _birthDateController.text = formatted;
      _birthDateController.selection = TextSelection.collapsed(
        offset: formatted.length,
      );
    }
  }

  String _convertBirthDateToApi(String formattedDate) {
    // Converte de dd/mm/yyyy para yyyy-mm-dd
    final parts = formattedDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return formattedDate;
  }

  void _handleIdentificationSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      final cpfClean = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      final birthDateApi = _convertBirthDateToApi(_birthDateController.text);

      final response = await ForgotPasswordService.recuperarIdentificacao(
        cpf: cpfClean,
        dataNascimento: birthDateApi,
      );

      setState(() {
        _userIdentification = response;
        _identificationFound = true;
        _isLoading = false;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is ForgotPasswordException
            ? e.message
            : 'Erro ao buscar dados do usuário';
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      setState(() {
        _isLoading = false;
        _passwordChanged = true;
      });

      _successController.forward();
      HapticFeedback.mediumImpact();

      // Volta para tela anterior após alguns segundos
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is ForgotPasswordException
            ? e.message
            : 'Erro ao alterar senha';
      });
      HapticFeedback.heavyImpact();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool isFocused,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isFocused ? _pulseAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.vinhoMedioUniodonto.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(
                fontFamily: 'Georama',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                labelStyle: TextStyle(
                  fontFamily: 'Georama',
                  color: isFocused
                      ? AppColors.vinhoMedioUniodonto
                      : AppColors.goiabaUniodonto.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  fontFamily: 'Georama',
                  color: AppColors.goiabaUniodonto.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    icon,
                    color: isFocused
                        ? AppColors.vinhoMedioUniodonto
                        : AppColors.goiabaUniodonto.withOpacity(0.6),
                    size: 22,
                  ),
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: isFocused
                    ? AppColors.vinhoMedioUniodonto.withOpacity(0.05)
                    : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.vinhoMedioUniodonto,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2.0),
                ),
              ),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              obscureText: obscureText,
              validator: validator,
              onChanged: onChanged,
              onTap: () => HapticFeedback.lightImpact(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.vinhoMedioUniodonto,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.fundoConteudo,
              AppColors.fundoConteudo,
              AppColors.fundoConteudo,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    140,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),

                    // Header Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Icon Container
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.vinhoMedioUniodonto.withOpacity(
                                      0.1,
                                    ),
                                    AppColors.vinhoMedioUniodonto.withOpacity(
                                      0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color: AppColors.vinhoMedioUniodonto
                                      .withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.vinhoMedioUniodonto
                                        .withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 60,
                                color: AppColors.vinhoMedioUniodonto,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              _passwordChanged
                                  ? 'Senha Alterada!'
                                  : _identificationFound
                                  ? 'Nova Senha'
                                  : 'Recuperar Senha',
                              style: TextStyle(
                                fontFamily: 'Georama',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _passwordChanged
                                    ? Colors.green[700]
                                    : AppColors.vinhoMedioUniodonto,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                _passwordChanged
                                    ? 'Sua senha foi alterada com sucesso!'
                                    : _identificationFound
                                    ? 'Olá, ${_userIdentification?.integracao.nome ?? ''}!\nDefina sua nova senha'
                                    : 'Informe seu CPF e data de nascimento para continuar',
                                textAlign: TextAlign.center,
                                style: AppStyles.bodyText.copyWith(
                                  color: AppColors.goiabaUniodonto.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Content based on state
                    if (_passwordChanged) ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeTransition(
                                opacity: _successFadeAnimation,
                                child: ScaleTransition(
                                  scale: _successScaleAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[200]!.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 60,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeTransition(
                                opacity: _successFadeAnimation,
                                child: Text(
                                  'Sua senha foi alterada\ncom sucesso!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georama',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FadeTransition(
                                opacity: _successFadeAnimation,
                                child: Text(
                                  'Você já pode fazer login\ncom sua nova senha',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georama',
                                    fontSize: 16,
                                    color: AppColors.goiabaUniodonto
                                        .withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Form Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.3,
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: AppColors.goiabaUniodonto.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (!_identificationFound) ...[
                                    // CPF Field
                                    _buildTextField(
                                      controller: _cpfController,
                                      focusNode: _cpfFocusNode,
                                      labelText: 'CPF',
                                      hintText: '000.000.000-00',
                                      icon: Icons.person_outline_rounded,
                                      isFocused: _cpfFocused,
                                      validator: Validators.validateCpf,
                                      onChanged: _formatCpf,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(14),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Birth Date Field
                                    _buildTextField(
                                      controller: _birthDateController,
                                      focusNode: _birthDateFocusNode,
                                      labelText: 'Data de Nascimento',
                                      hintText: 'dd/mm/aaaa',
                                      icon: Icons.calendar_today_rounded,
                                      isFocused: _birthDateFocused,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Data de nascimento é obrigatória';
                                        }
                                        final regex = RegExp(
                                          r'^\d{2}/\d{2}/\d{4}$',
                                        );
                                        if (!regex.hasMatch(value)) {
                                          return 'Formato inválido (dd/mm/aaaa)';
                                        }
                                        return null;
                                      },
                                      onChanged: _formatBirthDate,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                    ),
                                  ] else ...[
                                    // New Password Field
                                    _buildTextField(
                                      controller: _newPasswordController,
                                      focusNode: _newPasswordFocusNode,
                                      labelText: 'Nova Senha',
                                      hintText: 'Digite sua nova senha',
                                      icon: Icons.lock_outline_rounded,
                                      isFocused: _newPasswordFocused,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nova senha é obrigatória';
                                        }
                                        if (value.length < 8) {
                                          return 'Senha deve ter pelo menos 8 caracteres';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {},
                                      obscureText: !_showNewPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showNewPassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.goiabaUniodonto
                                              .withOpacity(0.6),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showNewPassword =
                                                !_showNewPassword;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Confirm Password Field
                                    _buildTextField(
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocusNode,
                                      labelText: 'Confirmar Senha',
                                      hintText: 'Confirme sua nova senha',
                                      icon: Icons.lock_outline_rounded,
                                      isFocused: _confirmPasswordFocused,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirmação de senha é obrigatória';
                                        }
                                        if (value !=
                                            _newPasswordController.text) {
                                          return 'Senhas não coincidem';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {},
                                      obscureText: !_showConfirmPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showConfirmPassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.goiabaUniodonto
                                              .withOpacity(0.6),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showConfirmPassword =
                                                !_showConfirmPassword;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 32),

                                  // Error Message
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.red[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(
                                                fontFamily: 'Georama',
                                                color: Colors.red[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Submit Button
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: _isLoading
                                            ? [
                                                AppColors.goiabaUniodonto
                                                    .withOpacity(0.6),
                                                AppColors.goiabaUniodonto
                                                    .withOpacity(0.4),
                                              ]
                                            : [
                                                AppColors.vinhoMedioUniodonto,
                                                AppColors.vinhoMedioUniodonto
                                                    .withOpacity(0.8),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: _isLoading
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: AppColors
                                                    .vinhoMedioUniodonto
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        onTap: _isLoading
                                            ? null
                                            : (_identificationFound
                                                  ? _handlePasswordReset
                                                  : _handleIdentificationSubmit),
                                        borderRadius: BorderRadius.circular(16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 56,
                                          child: Center(
                                            child: _isLoading
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                Colors.white
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Text(
                                                        _identificationFound
                                                            ? 'Alterando senha...'
                                                            : 'Verificando...',
                                                        style: TextStyle(
                                                          fontFamily: 'Georama',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _identificationFound
                                                            ? Icons
                                                                  .security_rounded
                                                            : Icons
                                                                  .search_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        _identificationFound
                                                            ? 'Alterar Senha'
                                                            : 'Buscar Dados',
                                                        style: const TextStyle(
                                                          fontFamily: 'Georama',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (!_identificationFound) ...[
                        const SizedBox(height: 32),
                      ],
                    ],

                    const SizedBox(height: 12),

                    // Support Link
                    if (!_passwordChanged && !_identificationFound)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.8,
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // Implementar navegação para suporte
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.vinhoMedioUniodonto,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Precisa de ajuda? Entre em contato com o suporte',
                              style: TextStyle(
                                fontFamily: 'Georama',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.vinhoMedioUniodonto
                                    .withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
