import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _titularCpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _cpfFocusNode = FocusNode();
  final FocusNode _titularCpfFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isTitular = true;
  bool _isDependente = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _registrationSuccess = false;

  // Focus states
  bool _cpfFocused = false;
  bool _titularCpfFocused = false;
  bool _passwordFocused = false;
  bool _confirmPasswordFocused = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _checkboxController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successFadeAnimation;
  late Animation<double> _checkboxAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _checkboxAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _checkboxController, curve: Curves.elasticOut),
    );

    // Focus listeners
    _cpfFocusNode.addListener(() {
      setState(() {
        _cpfFocused = _cpfFocusNode.hasFocus;
        if (_cpfFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });

    _titularCpfFocusNode.addListener(() {
      setState(() {
        _titularCpfFocused = _titularCpfFocusNode.hasFocus;
        if (_titularCpfFocused) {
          _pulseController.forward().then((_) => _pulseController.reverse());
        }
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordFocused = _passwordFocusNode.hasFocus;
        if (_passwordFocused) {
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

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _titularCpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _cpfFocusNode.dispose();
    _titularCpfFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _checkboxController.dispose();
    super.dispose();
  }

  void _handleTitularChange(bool? value) {
    if (value == true) {
      setState(() {
        _isTitular = true;
        _isDependente = false;
      });
      _checkboxController.forward().then((_) => _checkboxController.reverse());
      HapticFeedback.lightImpact();
    }
  }

  void _handleDependenteChange(bool? value) {
    if (value == true) {
      setState(() {
        _isTitular = false;
        _isDependente = true;
      });
      _checkboxController.forward().then((_) => _checkboxController.reverse());
      HapticFeedback.lightImpact();
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  void _formatCpf(TextEditingController controller, String value) {
    if (value.isEmpty) return;

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length > 11) {
      controller.text = cleaned.substring(0, 11);
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      return;
    }

    if (cleaned.length >= 3 && !value.contains('.')) {
      final formatted = Validators.formatCpf(cleaned);
      if (formatted != value) {
        controller.text = formatted;
        controller.selection = TextSelection.collapsed(
          offset: formatted.length,
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate registration process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _registrationSuccess = true;
    });

    _successController.forward();
    HapticFeedback.mediumImpact();

    // Navigate back after success
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required bool isFocused,
  }) {
    return InputDecoration(
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
          prefixIcon,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        borderSide: BorderSide(
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
      errorStyle: const TextStyle(
        fontFamily: 'Georama',
        fontSize: 12,
        height: 1.2,
      ),
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
              decoration: _buildInputDecoration(
                labelText: labelText,
                hintText: hintText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                isFocused: isFocused,
              ),
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              onChanged: onChanged,
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.fundoConteudo,
              AppColors.fundoConteudo.withOpacity(0.8),
              AppColors.fundoConteudo.withOpacity(0.05),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_registrationSuccess) ...[
                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),

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
                              borderRadius: BorderRadius.circular(50),
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
                            child: Icon(
                              Icons.person_add_rounded,
                              size: 50,
                              color: AppColors.vinhoMedioUniodonto,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontFamily: 'Georama',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vinhoMedioUniodonto,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Insira seus dados para realizar o cadastro',
                            textAlign: TextAlign.center,
                            style: AppStyles.bodyText.copyWith(
                              color: AppColors.goiabaUniodonto.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.4,
                            ),
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
                              color: AppColors.goiabaUniodonto.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Type Selection
                              Text(
                                'Tipo de usuário',
                                style: TextStyle(
                                  fontFamily: 'Georama',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.vinhoMedioUniodonto,
                                ),
                              ),

                              const SizedBox(height: 16),

                              AnimatedBuilder(
                                animation: _checkboxAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isTitular
                                        ? _checkboxAnimation.value
                                        : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isTitular
                                            ? AppColors.vinhoMedioUniodonto
                                                  .withOpacity(0.05)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isTitular
                                              ? AppColors.vinhoMedioUniodonto
                                                    .withOpacity(0.3)
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        title: Text(
                                          'Titular',
                                          style: TextStyle(
                                            fontFamily: 'Georama',
                                            fontWeight: FontWeight.w500,
                                            color: _isTitular
                                                ? AppColors.vinhoMedioUniodonto
                                                : AppColors.goiabaUniodonto,
                                          ),
                                        ),
                                        value: _isTitular,
                                        onChanged: _handleTitularChange,
                                        activeColor:
                                            AppColors.vinhoMedioUniodonto,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              AnimatedBuilder(
                                animation: _checkboxAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isDependente
                                        ? _checkboxAnimation.value
                                        : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isDependente
                                            ? AppColors.vinhoMedioUniodonto
                                                  .withOpacity(0.05)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isDependente
                                              ? AppColors.vinhoMedioUniodonto
                                                    .withOpacity(0.3)
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        title: Text(
                                          'Dependente',
                                          style: TextStyle(
                                            fontFamily: 'Georama',
                                            fontWeight: FontWeight.w500,
                                            color: _isDependente
                                                ? AppColors.vinhoMedioUniodonto
                                                : AppColors.goiabaUniodonto,
                                          ),
                                        ),
                                        value: _isDependente,
                                        onChanged: _handleDependenteChange,
                                        activeColor:
                                            AppColors.vinhoMedioUniodonto,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 28),

                              // CPF Field
                              _buildAnimatedField(
                                controller: _cpfController,
                                focusNode: _cpfFocusNode,
                                isFocused: _cpfFocused,
                                labelText: 'CPF',
                                hintText: '000.000.000-00',
                                prefixIcon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(14),
                                ],
                                validator: Validators.validateCpf,
                                onChanged: (value) =>
                                    _formatCpf(_cpfController, value),
                              ),

                              const SizedBox(height: 20),

                              // Titular CPF Field (if dependent)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: _isDependente ? null : 0,
                                child: _isDependente
                                    ? Column(
                                        children: [
                                          _buildAnimatedField(
                                            controller: _titularCpfController,
                                            focusNode: _titularCpfFocusNode,
                                            isFocused: _titularCpfFocused,
                                            labelText: 'CPF do Titular',
                                            hintText: '000.000.000-00',
                                            prefixIcon: Icons.person_outline,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                14,
                                              ),
                                            ],
                                            validator: Validators.validateCpf,
                                            onChanged: (value) => _formatCpf(
                                              _titularCpfController,
                                              value,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Password Field
                              _buildAnimatedField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                isFocused: _passwordFocused,
                                labelText: 'Senha',
                                hintText: 'Digite sua senha',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                validator: Validators.validatePassword,
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        key: ValueKey(_obscurePassword),
                                        color: _passwordFocused
                                            ? AppColors.vinhoMedioUniodonto
                                            : AppColors.goiabaUniodonto
                                                  .withOpacity(0.6),
                                        size: 22,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    splashRadius: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Confirm Password Field
                              _buildAnimatedField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                isFocused: _confirmPasswordFocused,
                                labelText: 'Confirmar Senha',
                                hintText: 'Confirme sua senha',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                validator: _validateConfirmPassword,
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        key: ValueKey(_obscureConfirmPassword),
                                        color: _confirmPasswordFocused
                                            ? AppColors.vinhoMedioUniodonto
                                            : AppColors.goiabaUniodonto
                                                  .withOpacity(0.6),
                                        size: 22,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    splashRadius: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

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
                                            color: AppColors.vinhoMedioUniodonto
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
                                    onTap: _isLoading ? null : _handleSubmit,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      child: Center(
                                        child: _isLoading
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
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
                                                    'Cadastrando...',
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.person_add_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text(
                                                    'Criar Conta',
                                                    style: TextStyle(
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
                ] else ...[
                  // Success State
                  FadeTransition(
                    opacity: _successFadeAnimation,
                    child: ScaleTransition(
                      scale: _successScaleAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          Container(
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
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 60,
                              color: Colors.green[600],
                            ),
                          ),

                          const SizedBox(height: 32),

                          Text(
                            'Cadastro realizado!',
                            style: TextStyle(
                              fontFamily: 'Georama',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Sua conta foi criada com sucesso!\nVocê será redirecionado para o login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Georama',
                                color: AppColors.goiabaUniodonto.withOpacity(
                                  0.8,
                                ),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Success animation with particles effect
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.green[100],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[400]!,
                                      Colors.green[600]!,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
