import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ModernBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    // Anima o item selecionado
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });

    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildNavItem(
              1,
              Icons.dynamic_feed_rounded,
              Icons.dynamic_feed_outlined,
              'Feed',
            ),
            _buildNavItem(
              2,
              Icons.settings_rounded,
              Icons.settings_outlined,
              'Config',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: SizedBox(
              width: 72,
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone com animação de transição
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.vinhoMedioUniodonto.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        key: ValueKey(isSelected),
                        size: 24,
                        color: isSelected
                            ? AppColors.vinhoMedioUniodonto
                            : AppColors.goiabaUniodonto,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Label com animação de cor e peso
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontFamily: 'Georama',
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.vinhoMedioUniodonto
                          : AppColors.goiabaUniodonto,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// UltraModernBottomNavigation com fundo vinho e melhorias
class UltraModernBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UltraModernBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<UltraModernBottomNavigation> createState() =>
      _UltraModernBottomNavigationState();
}

class _UltraModernBottomNavigationState
    extends State<UltraModernBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _indicatorController;
  late AnimationController _rippleController;
  late Animation<double> _indicatorAnimation;
  late Animation<double> _rippleAnimation;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controllers para animação individual dos itens
    _itemControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Inicializar as animações DEPOIS dos controllers
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.elasticOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 0.85).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Inicia as animações
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _indicatorController.forward();
    });
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _rippleController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(UltraModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorController.reset();
      _rippleController.reset();
      _indicatorController.forward();
      _rippleController.forward();
    }
  }

  void _onTap(int index) {
    _itemControllers[index].forward().then((_) {
      _itemControllers[index].reverse();
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 121, 0, 80),
            Color.fromARGB(255, 134, 1, 85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.vinhoUltraUniodonto.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Efeito de brilho sutil no fundo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                      Colors.white.withOpacity(0.03),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Indicador de seleção com efeito ripple
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  left: 18 + (widget.currentIndex * (screenWidth - 80) / 3),
                  top: 18,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0 + (_rippleAnimation.value * 0),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Indicador principal
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, child) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  left: 20 + (widget.currentIndex * (screenWidth - 84) / 3),
                  top: 20,
                  child: Transform.scale(
                    scale: _indicatorAnimation.value,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Itens da navegação
            Row(
              children: [
                _buildFloatingNavItem(
                  0,
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Home',
                ),
                _buildFloatingNavItem(
                  1,
                  Icons.dynamic_feed_rounded,
                  Icons.dynamic_feed_outlined,
                  'Feed',
                ),
                _buildFloatingNavItem(
                  2,
                  Icons.settings_rounded,
                  Icons.settings_outlined,
                  'Config',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: AnimatedBuilder(
        animation: _itemAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _itemAnimations[index].value,
            child: GestureDetector(
              onTap: () => _onTap(index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 88,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone com animação aprimorada
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(2),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: Tween<double>(
                                begin: 0.1,
                                end: 0.0,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isSelected ? activeIcon : inactiveIcon,
                          key: ValueKey('${isSelected}_$index'),
                          size: isSelected ? 26 : 24,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Label com melhor animação
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontFamily: 'Georama',
                        fontSize: isSelected ? 12 : 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        letterSpacing: isSelected ? 0.2 : 0.1,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
