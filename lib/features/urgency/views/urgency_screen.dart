import 'package:flutter/material.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/location_card.dart';

class UrgencyScreen extends StatefulWidget {
  const UrgencyScreen({super.key});

  @override
  State<UrgencyScreen> createState() => _UrgencyScreenState();
}

class _UrgencyScreenState extends State<UrgencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar moderna com gradiente
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.vinhoUltraUniodonto, // Vinho escuro
                    AppColors.vinhoUltraUniodonto, // Vinho médio
                    AppColors.vinhoUltraUniodonto, // Vinho claro
                  ],
                ),
              ),

              // ... (código anterior)
              child: FlexibleSpaceBar(
                title: const Text(
                  'Urgência Odontológica',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.vinhoUltraUniodonto,
                        AppColors.vinhoMedioUniodonto,
                      ],
                    ),
                  ),
                  child: Center(
                    // Substitua o Icon pelo seu logotipo
                    child: Image.asset(
                      'assets/images/logo urgencia.png', // <-- Caminho para o seu logotipo
                      width: 190, // Ajuste o tamanho conforme necessário
                      height: 190, // Ajuste o tamanho conforme necessário
                      // Você pode adicionar um color ou colorBlendMode se quiser ajustar a cor da imagem
                      // color: AppColors.limaUniodonto,
                      // colorBlendMode: BlendMode.modulate,
                    ),
                  ),
                ),
              ),

              // ... (código posterior)
            ),
          ),

          // Conteúdo principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com animação
                  AnimatedBuilder(
                    animation: _headerAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: SlideTransition(
                          position: _headerSlideAnimation,
                          child: _buildHeader(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Cards das localizações com animação
                  AnimatedBuilder(
                    animation: _cardsAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          _buildAnimatedLocationCard(
                            animationValue: _cardsAnimation.value,
                            delay: 0,
                            city: 'Porto Alegre',
                            schedule:
                                'Atendimento de urgência 24h, 7 dias por semana, inclusive em domingos e feriados.',
                            addressLine1: 'Avenida Independência, 914',
                            addressLine2: 'Independência',
                            phone: '(51) 3302-4024',
                            isHighlighted: true,
                          ),
                          _buildAnimatedLocationCard(
                            animationValue: _cardsAnimation.value,
                            delay: 200,
                            city: 'Guaíba',
                            schedule:
                                'Atendimento de urgência de segunda a sexta das 8h15 às 12h30 e das 13h30 às 17h30.',
                            addressLine1: 'Rua Vinte de Setembro, 787',
                            addressLine2: 'Centro',
                            phone: '(51) 3055-4058',
                          ),
                          _buildAnimatedLocationCard(
                            animationValue: _cardsAnimation.value,
                            delay: 400,
                            city: 'Pelotas',
                            schedule:
                                'Atendimento de urgência de segunda a sexta das 13h30 às 17h30.',
                            addressLine1: 'Rua Princesa Isabel, 280',
                            addressLine2: 'Centro',
                            phone: '(53) 3227-6515',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Rodapé com dicas
                  _buildFooterTips(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8647C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Color(0xFF8B1538),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Urgência Odontológica',
                  style: AppStyles.titleText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Emergências odontológicas exigem rapidez. Por isso, a Uniodonto Porto Alegre oferece três unidades de Pronto Atendimento, localizadas para garantir agilidade, conforto e segurança.',
            style: AppStyles.bodyText.copyWith(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8647C).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF8B1538),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Atendimento por ordem de chegada, sem necessidade de agendamento.',
                    style: AppStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLocationCard({
    required double animationValue,
    required int delay,
    required String city,
    required String schedule,
    required String addressLine1,
    required String addressLine2,
    required String phone,
    bool isHighlighted = false,
  }) {
    // Calcular o progresso da animação com delay
    final delayProgress = (delay / 1000.0); // Converter delay para segundos
    final adjustedValue = (animationValue - delayProgress).clamp(0.0, 1.0);

    // Aplicar curva de animação
    final curvedValue = Curves.easeOutBack.transform(adjustedValue);

    // Garantir que os valores estejam sempre no intervalo válido
    final opacity = curvedValue.clamp(0.0, 1.0);
    final translateY = (1 - curvedValue) * 50;

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ModernLocationCard(
            city: city,
            schedule: schedule,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            phone: phone,
            isHighlighted: isHighlighted,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.vinhoMedioUniodonto.withOpacity(0.05),
            AppColors.vinhoClaroUniodonto.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8647C).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF8B1538),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Dicas importantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B1538),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Traga documento com foto e carteirinha'),
          _buildTipItem('Chegue com antecedência para agilizar o atendimento'),
          _buildTipItem('Em casos graves, procure o hospital mais próximo'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8647C),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
