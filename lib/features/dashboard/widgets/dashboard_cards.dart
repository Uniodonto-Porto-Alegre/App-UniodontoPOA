import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/urgency/views/urgency_screen.dart';
import '../../../features/renova/views/renova_screen.dart';
import '../../../features/search/views/search_screen.dart';
import '../../../features/usage/views/orcamentos_screen.dart';
import '../../finance/views/financeiro_screen.dart';
import '../../suport/views/suport_screen.dart';
import '../../geolocation/views/geolocation_view.dart';

// Widgets reutilizáveis para evitar repetição de código
class _CommonAnimations {
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: vsync,
    );
  }

  static Animation<double> createScaleAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  static Animation<double> createElevationAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = _CommonAnimations.createController(this);
    _scaleAnimation = _CommonAnimations.createScaleAnimation(_controller);
    _elevationAnimation = _CommonAnimations.createElevationAnimation(
      _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUpOrCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? AppColors.vinhoMedioUniodonto;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: (_) => _handleTapUpOrCancel(),
            onTapCancel: _handleTapUpOrCancel,
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cardColor.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: _buildBoxShadows(cardColor),
              ),
              child: Row(
                children: [
                  // Ícone animado
                  _buildAnimatedIcon(cardColor),
                  const SizedBox(width: 16),
                  // Conteúdo expandido
                  _buildContent(),
                  const SizedBox(width: 12),
                  // Seta indicativa
                  _buildArrowIndicator(cardColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<BoxShadow> _buildBoxShadows(Color cardColor) {
    final elevationValue = _elevationAnimation.value;
    return [
      BoxShadow(
        color: cardColor.withOpacity(0.08 * elevationValue),
        blurRadius: 20 * elevationValue,
        offset: Offset(0, 8 * elevationValue),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04 * elevationValue),
        blurRadius: 10 * elevationValue,
        offset: Offset(0, 2 * elevationValue),
      ),
    ];
  }

  Widget _buildAnimatedIcon(Color cardColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withOpacity(_isPressed ? 0.2 : 0.15),
            cardColor.withOpacity(_isPressed ? 0.15 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.2), width: 1),
      ),
      child: AnimatedRotation(
        turns: _isPressed ? 0.02 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(widget.icon, color: cardColor, size: 26),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontFamily: 'Georama',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontFamily: 'Georama',
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowIndicator(Color cardColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..translate(_isPressed ? 4.0 : 0.0, 0.0),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: cardColor,
          size: 16,
        ),
      ),
    );
  }
}

class DashboardQuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const DashboardQuickAction({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  State<DashboardQuickAction> createState() => _DashboardQuickActionState();
}

class _DashboardQuickActionState extends State<DashboardQuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = _CommonAnimations.createController(this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUpOrCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = widget.color ?? AppColors.vinhoMedioUniodonto;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: (_) => _handleTapUpOrCancel(),
      onTapCancel: _handleTapUpOrCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: actionColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: _buildBoxShadows(actionColor),
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (_bounceAnimation.value * 0.1),
                    child: Icon(widget.icon, color: actionColor, size: 28),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'Georama',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<BoxShadow> _buildBoxShadows(Color actionColor) {
    return [
      BoxShadow(
        color: actionColor.withOpacity(0.1),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

// Botão Principal Individualizado
class MainActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;
  final TextStyle? textStyle;

  const MainActionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color,
    required this.textStyle,
  }) : super(key: key);

  @override
  State<MainActionButton> createState() => _MainActionButtonState();
}

class _MainActionButtonState extends State<MainActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = _CommonAnimations.createController(this);

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUpOrCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: (_) => _handleTapUpOrCancel(),
      onTapCancel: _handleTapUpOrCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withOpacity(0.9),
                    widget.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: _isPressed ? 15 : 25,
                    offset: Offset(0, _isPressed ? 6 : 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _buildShimmerEffect(widget.color),
                  _buildButtonContent(widget.icon, widget.text),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect(Color color) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Transform.translate(
              offset: Offset(_shimmerAnimation.value * 200, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedRotation(
          turns: _isPressed ? 0.05 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Georama',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(_isPressed ? 4.0 : 0.0, 0.0),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class ModernizedMainCard extends StatelessWidget {
  final Function(String) onCardTap;

  const ModernizedMainCard({Key? key, required this.onCardTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    void navigateToGeolocation() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GeolocationView()),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Botão 1 - Carteirinha Digital
          MainActionButton(
            icon: Icons.card_membership_outlined,
            text: 'Carteirinha Digital',
            onTap: () => onCardTap('Carteirinha'),
            textStyle: const TextStyle(color: AppColors.fundoConteudo),

            color: AppColors.vinhoUltraUniodonto,
          ),

          const SizedBox(height: 6),

          // Botão 2 - Dentistas Próximos
          MainActionButton(
            icon: Icons.location_on_outlined,
            text: 'Dentistas próximos',
            textStyle: const TextStyle(color: AppColors.vinhoMedioUniodonto),
            onTap: navigateToGeolocation,
            color: AppColors.vinhoMedioUniodonto,
          ),
        ],
      ),
    );
  }
}

class DashboardMainContent extends StatelessWidget {
  final Function(String) onCardTap;

  const DashboardMainContent({Key? key, required this.onCardTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Funções de navegação
    void navigateToUrgency() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UrgencyScreen()),
      );
    }

    void navigateToUsage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrcamentosScreen()),
      );
    }

    void navigateToSuport() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupportScreen()),
      );
    }

    void navigateToFinance() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FinanceiroScreen()),
      );
    }

    void navigateToRenova() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RenovaScreen()),
      );
    }

    void navigateToSearch() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Principal Modernizado
          ModernizedMainCard(onCardTap: onCardTap),

          // Ações Rápidas
          _buildSectionTitle(
            title: 'Ações Rápidas',
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DashboardQuickAction(
                  icon: Icons.local_hospital_rounded,
                  label: 'Dentistas',
                  color: AppColors.cianoUniodonto,
                  onTap: navigateToSearch,
                ),
                DashboardQuickAction(
                  icon: Icons.analytics_rounded,
                  label: 'Utilização',
                  color: AppColors.roxoUniodonto,
                  onTap: navigateToUsage,
                ),
                DashboardQuickAction(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Financeiro',
                  color: AppColors.vinhoMedioUniodonto,
                  onTap: navigateToFinance,
                ),
                DashboardQuickAction(
                  icon: Icons.headset_mic_rounded,
                  label: 'Suporte',
                  color: Colors.orange,
                  onTap: navigateToSuport,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Seções Principais
          _buildSectionTitle(
            title: 'Todos os Serviços',
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                DashboardCard(
                  icon: Icons.local_hospital_rounded,
                  title: 'Encontrar Dentistas',
                  subtitle: 'Localize dentistas credenciados próximos a você',
                  color: AppColors.cianoUniodonto,
                  onTap: navigateToSearch,
                ),
                DashboardCard(
                  icon: Icons.analytics_rounded,
                  title: 'Histórico de Utilização',
                  subtitle:
                      'Consulte seus procedimentos e consultas realizadas',
                  color: AppColors.roxoUniodonto,
                  onTap: navigateToUsage,
                ),
                DashboardCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Gestão Financeira',
                  subtitle: 'Extrato, faturas e histórico de pagamentos',
                  color: AppColors.vinhoMedioUniodonto,
                  onTap: navigateToFinance,
                ),
                DashboardCard(
                  icon: Icons.six_mp_outlined,
                  title: 'Renova Implantes',
                  subtitle: 'Implantes Dentários',
                  color: Colors.orange,
                  onTap: navigateToRenova,
                ),
                DashboardCard(
                  icon: Icons.medical_services,
                  title: 'Urgência Odontológica',
                  subtitle: 'Pronto atendimento para urgências odontológicas',
                  color: AppColors.pessegoUniodonto,
                  onTap: navigateToUrgency,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required EdgeInsets padding,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Georama',
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
