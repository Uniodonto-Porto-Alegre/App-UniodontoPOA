import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../services/auth_provider.dart';
import '../services/odontosfera_auth_service.dart';
import '../widgets/auth_form.dart';
import '../widgets/auth_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/validators.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_page.dart';
import 'forgot_page.dart';
import '../../dashboard/views/loading_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Estados para controle da validação paralela
  bool _isValidatingOdontosfera = false;
  String? _odontosferaError;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRegister() {
    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _navigateToDashboard() async {
    if (!mounted) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_cpf', _cpfController.text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoadingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao salvar dados: $e');
      }
    }
  }

  void _navigateToForgotPassword() {
    if (!mounted) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ForgotPasswordPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Validação paralela com Odontosfera
  Future<void> _validateWithOdontosfera() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidatingOdontosfera = true;
      _odontosferaError = null;
    });

    try {
      // Extrai apenas os números do CPF para usar como username
      final username = Validators.cleanCpf(_cpfController.text);
      final password = _passwordController.text;

      // Chama a API da Odontosfera
      final result = await OdontosferaAuthService.login(username, password);

      if (!mounted) return;

      if (result.success) {
        // Login bem-sucedido na Odontosfera
        HapticFeedback.lightImpact();

        // Salva dados da Odontosfera se disponíveis
        final userData = result.userBasicData;
        if (userData != null) {
          try {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString(
              'odontosfera_user_data',
              json.encode(userData.toJson()),
            );
            await prefs.setString(
              'odontosfera_login_response',
              json.encode(result.userData ?? {}),
            );
          } catch (e) {
            debugPrint('Erro ao salvar dados da Odontosfera: $e');
            // Continua mesmo se não conseguir salvar os dados extras
          }
        }

        // Procede para o dashboard
        await _navigateToDashboard();
      } else {
        // Falha na validação da Odontosfera
        setState(() {
          _odontosferaError = result.message;
        });
        HapticFeedback.heavyImpact();
        _showErrorDialog(result.message);
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = 'Erro inesperado: ${e.toString()}';
      setState(() {
        _odontosferaError = errorMessage;
      });
      HapticFeedback.heavyImpact();
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingOdontosfera = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Erro de Login',
              style: TextStyle(
                fontFamily: 'Georama',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Georama',
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.vinhoMedioUniodonto,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Georama',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    void _handleLoginPress() {
      _validateWithOdontosfera();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.fundoConteudo,
              AppColors.fundoConteudo.withOpacity(0.8),
              AppColors.goiabaUniodonto.withOpacity(0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.fromLTRB(
              24.0,
              keyboardHeight > 0 ? 16.0 : 40.0,
              24.0,
              keyboardHeight > 0 ? 16.0 : 40.0,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      80,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Section with Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: keyboardHeight > 0 ? 0 : 0),

                              // Logo Container
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Image.asset(
                                  'assets/images/Logos-Uniodonto-POA2.png',
                                  width: keyboardHeight > 0 ? 130 : 180,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Welcome Text
                              Text(
                                'Bem-vindo de volta!',
                                style: TextStyle(
                                  fontFamily: 'Georama',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.vinhoMedioUniodonto,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Faça login para continuar sua jornada',
                                style: AppStyles.bodyText.copyWith(
                                  color: AppColors.goiabaUniodonto.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.3),
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
                            child: ModernAuthForm(
                              formKey: _formKey,
                              cpfController: _cpfController,
                              passwordController: _passwordController,
                              onSubmitted: _validateWithOdontosfera,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Error Message (Odontosfera ou Auth Provider)
                      if (_odontosferaError != null ||
                          authProvider.error != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[400],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _odontosferaError ?? authProvider.error!,
                                    style: TextStyle(
                                      fontFamily: 'Georama',
                                      color: Colors.red[700],
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Login Button
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
                                    0.6,
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                          child: ModernAuthButton(
                            isLoading:
                                _isValidatingOdontosfera ||
                                authProvider.isLoading,
                            text: _isValidatingOdontosfera
                                ? 'Validando...'
                                : 'Entrar',
                            onPressed: _isValidatingOdontosfera
                                ? null
                                : _handleLoginPress,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Bottom Links
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
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: _navigateToForgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppColors.vinhoMedioUniodonto,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Esqueci minha senha',
                                  style: TextStyle(
                                    fontFamily: 'Georama',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors
                                        .vinhoMedioUniodonto
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Não tem uma conta? ',
                                    style: TextStyle(
                                      fontFamily: 'Georama',
                                      color: AppColors.goiabaUniodonto
                                          .withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateToRegister,
                                    child: Text(
                                      'Cadastre-se',
                                      style: TextStyle(
                                        fontFamily: 'Georama',
                                        color: AppColors.vinhoMedioUniodonto,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.vinhoMedioUniodonto,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
