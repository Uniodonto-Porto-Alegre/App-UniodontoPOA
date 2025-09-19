import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/provider_model.dart';

class ProviderCardWidget extends StatelessWidget {
  final ProviderModel provider;

  const ProviderCardWidget({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (provider.distancia != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      provider.distanciaFormatada,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.areaDeAtuacao,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.telefoneFormatado,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                  onPressed: () => _makePhoneCall(provider.telefoneFormatado),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _openMapsDirection(provider),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Direções'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _shareProvider(provider),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Compartilhar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openMapsDirection(ProviderModel provider) async {
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1&destination=${provider.latitude},${provider.longitude}';
    
    final Uri uri = Uri.parse(googleMapsUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareProvider(ProviderModel provider) {
    // Implementar compartilhamento usando share_plus package
    final String shareText = '''
${provider.nome}
${provider.areaDeAtuacao}
Telefone: ${provider.telefoneFormatado}
Localização: https://www.google.com/maps?q=${provider.latitude},${provider.longitude}
    ''';
    
    // Share.share(shareText);
    print('Compartilhar: $shareText'); // Para debug
  }
}