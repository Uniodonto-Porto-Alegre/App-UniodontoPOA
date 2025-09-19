import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _heroOpacityAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heroOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroAnimationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          ),
        );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Iniciar animações sequencialmente
    _heroAnimationController.forward().then((_) {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _openWhatsApp(
    BuildContext context, {
    required String phone,
    required String message,
  }) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não foi possível abrir o WhatsApp.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar moderna com o tema de Suporte
          SliverAppBar(
            expandedHeight: 270.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.vinhoUltraUniodonto,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: AnimatedBuilder(
                animation: _heroOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _heroOpacityAnimation.value,
                    child: Text(
                      'Central de Suporte',
                      style: AppStyles.titleText.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.vinhoUltraUniodonto,
                      AppColors.vinhoUltraUniodonto.withOpacity(0.9),
                      AppColors.vinhoMedioUniodonto.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: GeometricPatternPainter()),
                    ),
                    Center(
                      child: SlideTransition(
                        position: _heroSlideAnimation,
                        child: FadeTransition(
                          opacity: _heroOpacityAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),

                            child: Image.asset(
                              // <-- Substituído de Icon para Image.asset
                              'assets/images/logo suporte.png', // <-- Caminho para o seu logotipo
                              width:
                                  164, // Ajuste o tamanho conforme necessário
                              height:
                                  164, // Ajuste o tamanho conforme necessário
                              // A cor da imagem já deve vir do asset, mas se precisar ajustar, use:
                              // color: AppColors.laranjaSuporte,
                              // colorBlendMode: BlendMode.srcIn,
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

          // Conteúdo principal da tela de suporte
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card de introdução
                      _buildHeroCard(),

                      const SizedBox(height: 48),

                      // Título da seção de contato
                      _buildSectionTitle(),

                      const SizedBox(height: 24),

                      // Card de Suporte Geral
                      _buildSupportCard(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Suporte Geral',
                        description:
                            'Para dúvidas, informações, problemas técnicos ou sugestões, nossa equipe está pronta para ajudar.',
                        onTap: () => _openWhatsApp(
                          context,
                          phone:
                              '+5551999999999', // SUBSTITUA PELO NÚMERO DE SUPORTE
                          message: 'Olá! Preciso de ajuda com o suporte geral.',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Card de Suporte Cobrança
                      _buildSupportCard(
                        context,
                        icon: Icons.payments_outlined,
                        title: 'Suporte Cobrança',
                        description:
                            'Fale conosco para resolver questões sobre pagamentos, faturas, boletos e outros assuntos financeiros.',
                        onTap: () => _openWhatsApp(
                          context,
                          phone:
                              '+5551888888888', // SUBSTITUA PELO NÚMERO DE COBRANÇA
                          message: 'Olá! Tenho uma dúvida sobre cobrança.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cianoUniodonto.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vinhoUltraUniodonto.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_outline_rounded,
            size: 48,
            color: AppColors.vinhoMedioUniodonto,
          ),
          const SizedBox(height: 16),
          Text(
            'Como podemos ajudar?',
            style: AppStyles.titleText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.vinhoUltraUniodonto,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Estamos aqui para resolver suas dúvidas e garantir a melhor experiência com nossos serviços. Escolha um canal de atendimento abaixo.',
            style: AppStyles.bodyText.copyWith(
              fontSize: 14,
              height: 1.6,
              color: AppColors.goiabaUniodonto,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.vinhoUltraUniodonto,
                AppColors.vinhoUltraUniodonto,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Canais de Atendimento',
          style: AppStyles.titleText.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vinhoUltraUniodonto.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.vinhoUltraUniodonto,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppStyles.titleText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppStyles.bodyText.copyWith(
              height: 1.6,
              fontSize: 14,
              color: AppColors.goiabaUniodonto,
            ),
          ),
          const SizedBox(height: 24),
          // Botão para chamar no WhatsApp
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.vinhoUltraUniodonto,
                  AppColors.vinhoMedioUniodonto,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vinhoUltraUniodonto.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call_rounded,
                        color: AppColors.cianoUniodonto,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'CHAMAR NO WHATSAPP',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.cianoUniodonto,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter para padrão geométrico (o mesmo da tela Renova)
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < size.width; i += 60) {
      for (int j = 0; j < size.height; j += 60) {
        path.addOval(
          Rect.fromCircle(
            center: Offset(i.toDouble(), j.toDouble()),
            radius: 20,
          ),
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
