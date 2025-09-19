// widgets/prestador_list_item.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../models/prestador_model.dart';

class PrestadorListItem extends StatelessWidget {
  final Prestador prestador;

  const PrestadorListItem({Key? key, required this.prestador})
    : super(key: key);

  String extractPhoneNumber(String rawPhone) {
    // Remove todos os caracteres não numéricos
    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length >= 11) {
      return digitsOnly.substring(0, 13);
    }
    return digitsOnly;
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final cleanedNumber = extractPhoneNumber(phoneNumber);
    final url = 'https://wa.me/$cleanedNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }

  bool _hasContactInfo() {
    return (prestador.contatos != null &&
            prestador.contatos!.trim().isNotEmpty) ||
        (prestador.cleanCelular != null &&
            prestador.cleanCelular!.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPrestadorDetails(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Header do card com gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.vinhoMedioUniodonto,
                    AppColors.vinhoUltraUniodonto,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Avatar do prestador
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nome e informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prestador.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CRO: ${prestador.cro ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ícone de ação
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Corpo do card com informações detalhadas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Localização
                  _buildModernInfoRow(
                    Icons.location_on,
                    Colors.red.shade400,
                    '${prestador.endereco ?? ''}, ${prestador.bairro ?? ''} - ${prestador.cidade ?? ''} / ${prestador.estado ?? ''}',
                  ),
                  const SizedBox(height: 16),

                  // Área de atuação
                  _buildModernInfoRow(
                    Icons.medical_services,
                    Colors.green.shade400,
                    prestador.areasDeAtuacao ?? 'Área não informada',
                  ),

                  // Contatos (se existirem)
                  if (_hasContactInfo()) ...[
                    const SizedBox(height: 16),
                    _buildContactSection(),
                  ],

                  // Botão WhatsApp se disponível
                  if (prestador.hasWhatsApp &&
                      prestador.whatsappNumber != null) ...[
                    const SizedBox(height: 16),
                    _buildWhatsAppButton(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                size: 18,
                color: AppColors.vinhoUltraUniodonto,
              ),
              const SizedBox(width: 8),
              Text(
                'Contatos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (prestador.contatos != null &&
                  prestador.contatos!.trim().isNotEmpty)
                Expanded(
                  child: _buildContactChip(
                    Icons.phone,
                    prestador.contatos!,
                    AppColors.vinhoUltraUniodonto,
                  ),
                ),
              if (prestador.contatos != null &&
                  prestador.contatos!.trim().isNotEmpty &&
                  prestador.cleanCelular != null &&
                  prestador.cleanCelular!.trim().isNotEmpty)
                const SizedBox(width: 8),
              if (prestador.cleanCelular != null &&
                  prestador.cleanCelular!.trim().isNotEmpty)
                Expanded(
                  child: _buildContactChip(
                    Icons.smartphone,
                    prestador.cleanCelular!,
                    Colors.green.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String contact, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              contact,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return GestureDetector(
      onTap: () => _launchWhatsApp(prestador.whatsappNumber!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366), // Verde do WhatsApp
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade600.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 24, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Chamar no WhatsApp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrestadorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle do modal
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.vinhoUltraUniodonto,
                              AppColors.vinhoMedioUniodonto,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
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
                              prestador.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'CRO: ${prestador.cro ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Conteúdo scrollável
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildDetailSection(
                        'Localização',
                        Icons.location_on,
                        Colors.red.shade400,
                        [
                          if (prestador.endereco?.isNotEmpty == true)
                            'Endereço: ${prestador.endereco}',
                          if (prestador.bairro?.isNotEmpty == true)
                            'Bairro: ${prestador.bairro}',
                          if (prestador.cidade?.isNotEmpty == true)
                            'Cidade: ${prestador.cidade}',
                          if (prestador.estado?.isNotEmpty == true)
                            'Estado: ${prestador.estado}',
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildDetailSection(
                        'Informações Profissionais',
                        Icons.medical_services,
                        Colors.green.shade400,
                        [
                          'CRO: ${prestador.cro ?? 'Não informado'}',
                          'Área de Atuação: ${prestador.areasDeAtuacao ?? 'Não informado'}',
                        ],
                      ),

                      if (_hasContactInfo()) ...[
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          'Contatos',
                          Icons.contact_phone,
                          AppColors.vinhoUltraUniodonto,
                          [
                            if (prestador.contatos?.trim().isNotEmpty == true)
                              'Telefone: ${prestador.contatos}',
                            if (prestador.cleanCelular?.trim().isNotEmpty ==
                                true)
                              'Celular: ${prestador.cleanCelular}',
                          ],
                        ),
                      ],

                      if (prestador.hasWhatsApp &&
                          prestador.whatsappNumber != null) ...[
                        const SizedBox(height: 20),
                        _buildWhatsAppButtonSection(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    final validItems = items.where((item) => item.isNotEmpty).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...validItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButtonSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF25D366).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.phone_android, size: 24, color: Color(0xFF25D366)),
              SizedBox(width: 12),
              Text(
                'Disponível no WhatsApp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Clique abaixo para iniciar uma conversa',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _buildWhatsAppButton(),
        ],
      ),
    );
  }
}
