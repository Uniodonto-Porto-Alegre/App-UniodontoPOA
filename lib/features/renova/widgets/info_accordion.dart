import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InfoAccordion extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;

  const InfoAccordion({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  State<InfoAccordion> createState() => _InfoAccordionState();
}

class _InfoAccordionState extends State<InfoAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _iconRotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.5, // 180 graus
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutBack,
          ),
        );

    _colorAnimation =
        ColorTween(
          begin: AppColors.vinhoMedioUniodonto,
          end: AppColors.vinhoUltraUniodonto,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _backgroundColorAnimation =
        ColorTween(
          begin: Colors.white,
          end: AppColors.vinhoUltraUniodonto.withOpacity(0.02),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: _backgroundColorAnimation.value,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (_colorAnimation.value ?? AppColors.vinhoMedioUniodonto)
                  .withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (_colorAnimation.value ?? AppColors.vinhoMedioUniodonto)
                    .withOpacity(_isExpanded ? 0.1 : 0.05),
                blurRadius: _isExpanded ? 20 : 15,
                offset: const Offset(0, 5),
                spreadRadius: _isExpanded ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Header do accordion
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                      bottom: Radius.circular(20),
                    ),
                    onTap: _toggleExpansion,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Ícone com container animado
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  (_colorAnimation.value ??
                                          AppColors.vinhoMedioUniodonto)
                                      .withOpacity(_isExpanded ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    (_colorAnimation.value ??
                                            AppColors.vinhoMedioUniodonto)
                                        .withOpacity(_isExpanded ? 0.4 : 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              color:
                                  _colorAnimation.value ??
                                  AppColors.vinhoMedioUniodonto,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Título
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: _isExpanded
                                        ? AppColors.vinhoUltraUniodonto
                                        : AppColors.goiabaUniodonto,
                                  ) ??
                                  const TextStyle(),
                              child: Text(widget.title),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Ícone de expansão com rotação
                          RotationTransition(
                            turns: _iconRotationAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (_colorAnimation.value ??
                                            AppColors.vinhoMedioUniodonto)
                                        .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    _colorAnimation.value ??
                                    AppColors.vinhoMedioUniodonto,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Conteúdo expansível
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divisor elegante
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                (_colorAnimation.value ??
                                        AppColors.vinhoMedioUniodonto)
                                    .withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Conteúdo com animações
                        FadeTransition(
                          opacity: _expandAnimation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, -0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeOutQuart,
                                  ),
                                ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color:
                                    (_colorAnimation.value ??
                                            AppColors.vinhoMedioUniodonto)
                                        .withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      (_colorAnimation.value ??
                                              AppColors.vinhoMedioUniodonto)
                                          .withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Indicador visual na lateral
                                  Container(
                                    width: 3,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _colorAnimation.value ??
                                              AppColors.vinhoMedioUniodonto,
                                          (_colorAnimation.value ??
                                                  AppColors.vinhoMedioUniodonto)
                                              .withOpacity(0.3),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Texto do conteúdo
                                  Expanded(
                                    child: Text(
                                      widget.content,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.goiabaUniodonto,
                                            height: 1.6,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
