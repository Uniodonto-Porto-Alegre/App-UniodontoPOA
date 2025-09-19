import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class ModernAuthButton extends StatefulWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed; // Agora é nullable

  const ModernAuthButton({
    Key? key,
    required this.isLoading,
    required this.text,
    this.onPressed, // Não é mais obrigatório
  }) : super(key: key);

  @override
  _ModernAuthButtonState createState() => _ModernAuthButtonState();
}

class _ModernAuthButtonState extends State<ModernAuthButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  bool get _isDisabled => widget.isLoading || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _isDisabled
                    ? [
                        AppColors.goiabaUniodonto.withOpacity(0.6),
                        AppColors.goiabaUniodonto.withOpacity(0.4),
                      ]
                    : [
                        AppColors.vinhoMedioUniodonto,
                        AppColors.vinhoMedioUniodonto.withOpacity(0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: _isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.vinhoMedioUniodonto.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.vinhoMedioUniodonto.withOpacity(0.1),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                // Shimmer Effect (quando carregando)
                if (widget.isLoading)
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      _shimmerController.repeat();
                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              transform: GradientRotation(
                                _shimmerAnimation.value * 3.14159,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Button Content
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _isDisabled ? null : widget.onPressed,
                    onTapDown: _isDisabled ? null : _handleTapDown,
                    onTapUp: _isDisabled ? null : _handleTapUp,
                    onTapCancel: _isDisabled ? null : _handleTapCancel,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: widget.isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      fontFamily: 'Georama',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      fontFamily: 'Georama',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _isDisabled
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (!_isDisabled) ...[
                                    const SizedBox(width: 8),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      transform: Matrix4.translationValues(
                                        _isPressed ? 2 : 0,
                                        0,
                                        0,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
