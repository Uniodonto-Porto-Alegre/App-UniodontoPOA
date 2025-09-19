import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/info_accordion.dart';

class RenovaScreen extends StatefulWidget {
  const RenovaScreen({super.key});

  @override
  State<RenovaScreen> createState() => _RenovaScreenState();
}

class _RenovaScreenState extends State<RenovaScreen>
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

  void _makePhoneCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+555125007100');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não foi possível abrir o discador.'),
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar moderna com efeitos visuais aprimorados
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
                          'Renova Implantes',
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
                        // Padrão geométrico sutil no fundo
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GeometricPatternPainter(),
                          ),
                        ),

                        // Ícone principal com animação
                        Center(
                          child: SlideTransition(
                            position: _heroSlideAnimation,
                            child: FadeTransition(
                              opacity: _heroOpacityAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(24),

                                child: Image.asset(
                                  // <-- Substituído de Icon para Image.asset
                                  'assets/images/logo renova.png', // <-- Caminho para o seu logotipo
                                  width:
                                      150, // Ajuste o tamanho conforme necessário
                                  height:
                                      150, // Ajuste o tamanho conforme necessário
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

              // Conteúdo principal com animações
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: SlideTransition(
                    position: _contentSlideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card hero com design glassmorphism
                          _buildHeroCard(),

                          const SizedBox(height: 48),

                          // Título da seção com design aprimorado
                          _buildSectionTitle(),

                          const SizedBox(height: 24),

                          // Texto principal com melhor formatação
                          _buildMainContent(),

                          const SizedBox(height: 20),

                          // Cards de benefícios com layout grid
                          _buildBenefitsGrid(),

                          const SizedBox(height: 32),

                          // Accordions modernizados
                          _buildAccordionSection(),

                          const SizedBox(height: 120), // Espaço para o botão
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Botão CTA modernizado
          _buildFloatingCTA(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_very_satisfied_rounded,
            size: 48,
            color: AppColors.vinhoMedioUniodonto,
          ),
          const SizedBox(height: 16),
          Text(
            'Transforme seu sorriso',
            style: AppStyles.titleText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.vinhoUltraUniodonto,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Implantes dentários de qualidade, preços acessíveis e pagamento facilitado. Eleve sua autoestima e confiança!',
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
            gradient: LinearGradient(
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
          'Por que escolher a Renova?',
          style: AppStyles.titleText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
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
            color: AppColors.vinhoUltraUniodonto.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          style: AppStyles.bodyText.copyWith(height: 1.7, fontSize: 15),
          children: const [
            TextSpan(text: 'Com '),
            TextSpan(
              text: '48 anos de história',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
            TextSpan(
              text: ' no mercado, a Uniodonto Porto Alegre se consolidou como ',
            ),
            TextSpan(
              text: 'referência em serviços odontológicos de excelência.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
            TextSpan(
              text:
                  ' Nossa trajetória é marcada pela dedicação e compromisso em cuidar da saúde bucal de nossos clientes, sempre oferecendo tratamentos de alta qualidade.\n\n',
            ),
            TextSpan(text: 'Agora, estamos orgulhosos de apresentar a '),
            TextSpan(
              text:
                  'Renova, nossa nova linha de serviços de implantes dentários.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
            TextSpan(text: '\n\nCom a Renova, unimos nossa '),
            TextSpan(
              text:
                  'tradição de confiança e experiência, com preços acessíveis e condições facilitadas de pagamento.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
            TextSpan(
              text:
                  ' Eleve sua autoestima e confiança com a Renova da Uniodonto Porto Alegre.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    final benefits = [
      {
        'icon': Icons.timer_outlined,
        'title': '48 Anos',
        'subtitle': 'de experiência',
        'color': AppColors.vinhoMedioUniodonto,
      },
      {
        'icon': Icons.star_outline_rounded,
        'title': 'Qualidade',
        'subtitle': 'garantida',
        'color': AppColors.vinhoUltraUniodonto,
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Preços',
        'subtitle': 'acessíveis',
        'color': AppColors.vinhoUltraUniodonto,
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Localização',
        'subtitle': 'privilegiada',
        'color': AppColors.vinhoMedioUniodonto,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (benefit['color'] as Color).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (benefit['color'] as Color).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (benefit['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  size: 18,
                  color: benefit['color'] as Color,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                benefit['title'] as String,
                style: AppStyles.subtitleText.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: benefit['color'] as Color,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                benefit['subtitle'] as String,
                style: AppStyles.bodyText.copyWith(
                  fontSize: 12,
                  color: AppColors.goiabaUniodonto,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccordionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saiba mais',
          style: AppStyles.titleText.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const InfoAccordion(
          icon: Icons.star_border_rounded,
          title: 'Profissionais Qualificados',
          content:
              'Na Renova, você tem acesso a uma equipe de dentistas altamente qualificados e especializados em implantes dentários. Nossa rede é composta por profissionais dedicados a proporcionar o melhor cuidado para sua saúde bucal.',
        ),
        const InfoAccordion(
          icon: Icons.attach_money_rounded,
          title: 'Preços Acessíveis',
          content:
              'A Renova oferece preços competitivos, tornando os implantes dentários mais acessíveis para todos. Nossa missão é proporcionar tratamentos de alta qualidade a um custo que cabe no seu bolso.',
        ),
        const InfoAccordion(
          icon: Icons.verified_user_outlined,
          title: 'Qualidade Garantida',
          content:
              'Na Renova, cada paciente recebe um atendimento especializado, com garantia de qualidade em todos os procedimentos. Nosso compromisso é garantir sua satisfação e confiança em nossos serviços.',
        ),
        const InfoAccordion(
          icon: Icons.location_on_outlined,
          title: 'Localização de Fácil Acesso',
          content:
              'Estamos localizados nas dependências da Uniodonto Porto Alegre, na Av. Independência, 914, sala 03. Nosso local é de fácil acesso, oferecendo conveniência e conforto para nossos pacientes.',
        ),
      ],
    );
  }

  Widget _buildFloatingCTA() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.95),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.vinhoUltraUniodonto,
                AppColors.vinhoMedioUniodonto,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.vinhoUltraUniodonto.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _makePhoneCall(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.cianoUniodonto,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'TRANSFORMAR MEU SORRISO',
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
      ),
    );
  }
}

// Custom Painter para padrão geométrico sutil
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Criar padrão geométrico sutil
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
