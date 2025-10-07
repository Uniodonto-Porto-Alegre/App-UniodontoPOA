import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uniodontopoa/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ModernLocationCard extends StatefulWidget {
  final String city;
  final String schedule;
  final String addressLine1;
  final String addressLine2;
  final String phone;
  final bool isHighlighted;

  const ModernLocationCard({
    super.key,
    required this.city,
    required this.schedule,
    required this.addressLine1,
    required this.addressLine2,
    required this.phone,
    this.isHighlighted = false,
  });

  @override
  State<ModernLocationCard> createState() => _ModernLocationCardState();
}

class _ModernLocationCardState extends State<ModernLocationCard>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // if (widget.isHighlighted) {
    //   _pulseController.repeat(reverse: true);
    // }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isHighlighted ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: widget.isHighlighted
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.vinhoClaroUniodonto.withOpacity(0.02),
                          ],
                        )
                      : null,
                  color: widget.isHighlighted ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: widget.isHighlighted
                      ? Border.all(
                          color: AppColors.vinhoClaroUniodonto.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    if (widget.isHighlighted)
                      BoxShadow(
                        color: AppColors.vinhoClaroUniodonto.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Padrão de fundo sutil
                      if (widget.isHighlighted)
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.vinhoClaroUniodonto.withOpacity(
                                0.05,
                              ),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho da cidade
                            _buildCityHeader(),
                            const SizedBox(height: 20),

                            // Horário de atendimento
                            _buildScheduleInfo(),
                            const SizedBox(height: 24),

                            // Informações de endereço e telefone
                            _buildContactInfo(),
                            const SizedBox(height: 28),

                            // Botões de ação
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B1538), Color(0xFFB91D47)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.vinhoUltraUniodonto.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.isHighlighted ? Icons.location_city : Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.city,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              if (widget.isHighlighted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.vinhoClaroUniodonto,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '24 HORAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.vinhoClaroUniodonto.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: Color(0xFF8B1538), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.schedule,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF636E72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.home,
          '${widget.addressLine1}, ${widget.addressLine2}',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.phone, widget.phone),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.vinhoClaroUniodonto.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF8B1538), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botão Copiar
        Expanded(
          child: _buildActionButton(
            icon: Icons.content_copy,
            label: 'COPIAR',
            isPrimary: false,
            onPressed: _copyAddress,
          ),
        ),
        const SizedBox(width: 12),
        // Botão Ligar
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'LIGAR',
            isPrimary: true,
            onPressed: _makePhoneCall,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF8B1538), Color(0xFFB91D47)],
                  )
                : null,
            color: isPrimary ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.vinhoUltraUniodonto.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : const Color(0xFF8B1538),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : const Color(0xFF8B1538),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyAddress() {
    final fullAddress =
        '${widget.addressLine1}\n${widget.addressLine2}\nTelefone: ${widget.phone}';
    Clipboard.setData(ClipboardData(text: fullAddress));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Endereço copiado!'),
          ],
        ),
        backgroundColor: const Color(0xFF8B1538),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: widget.phone.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Não foi possível abrir o discador.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao tentar realizar a ligação.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
