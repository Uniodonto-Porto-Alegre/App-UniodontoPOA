import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';

class ModernAuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cpfController;
  final TextEditingController passwordController;
  final VoidCallback onSubmitted;

  const ModernAuthForm({
    Key? key,
    required this.formKey,
    required this.cpfController,
    required this.passwordController,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  _ModernAuthFormState createState() => _ModernAuthFormState();
}

class _ModernAuthFormState extends State<ModernAuthForm>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _cpfFocused = false;
  bool _passwordFocused = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final FocusNode _cpfFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cpfFocusNode.addListener(() {
      setState(() {
        _cpfFocused = _cpfFocusNode.hasFocus;
        if (_cpfFocused) {
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cpfFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _formatCpf(String value) {
    if (value.isEmpty) return;

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length > 11) {
      widget.cpfController.text = cleaned.substring(0, 11);
      widget.cpfController.selection = TextSelection.collapsed(
        offset: widget.cpfController.text.length,
      );
      return;
    }

    if (cleaned.length >= 3 && !value.contains('.')) {
      final formatted = Validators.formatCpf(cleaned);
      if (formatted != value) {
        widget.cpfController.text = formatted;
        widget.cpfController.selection = TextSelection.collapsed(
          offset: formatted.length,
        );
      }
    }
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
      errorStyle: const TextStyle(
        fontFamily: 'Georama',
        fontSize: 12,
        height: 1.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // CPF Field
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cpfFocused ? _pulseAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _cpfFocused
                        ? [
                            BoxShadow(
                              color: AppColors.vinhoMedioUniodonto.withOpacity(
                                0.2,
                              ),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: TextFormField(
                    controller: widget.cpfController,
                    focusNode: _cpfFocusNode,
                    style: const TextStyle(
                      fontFamily: 'Georama',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    decoration: _buildInputDecoration(
                      labelText: 'CPF',
                      hintText: '000.000.000-00',
                      prefixIcon: Icons.person_outline,
                      isFocused: _cpfFocused,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                    validator: Validators.validateCpf,
                    onChanged: _formatCpf,
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Password Field
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _passwordFocused ? _pulseAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _passwordFocused
                        ? [
                            BoxShadow(
                              color: AppColors.vinhoMedioUniodonto.withOpacity(
                                0.2,
                              ),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: TextFormField(
                    controller: widget.passwordController,
                    focusNode: _passwordFocusNode,
                    style: const TextStyle(
                      fontFamily: 'Georama',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    decoration: _buildInputDecoration(
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
                      prefixIcon: Icons.lock_outline,
                      isFocused: _passwordFocused,
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              key: ValueKey(_obscurePassword),
                              color: _passwordFocused
                                  ? AppColors.vinhoMedioUniodonto
                                  : AppColors.goiabaUniodonto.withOpacity(0.6),
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
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    onFieldSubmitted: (_) => widget.onSubmitted(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
