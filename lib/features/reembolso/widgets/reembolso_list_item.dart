import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/solicitacao_model.dart';
import '../views/reembolso_detalhe_view.dart';

class ReembolsoListItem extends StatelessWidget {
  final Solicitacao solicitacao;

  const ReembolsoListItem({super.key, required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReembolsoDetalheView(solicitacao: solicitacao),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header com status e protocolo
                Row(
                  children: [
                    _buildStatusIndicator(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protocolo ${solicitacao.numProtocolo}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.vinhoUltraUniodonto,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${solicitacao.idSolicitacao}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Seta de navegação movida para o header para melhor alinhamento
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Data de criação
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(solicitacao.dataCriacaoSolicitacao),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;

    switch (solicitacao.statusSolicitacao.toUpperCase()) {
      case 'E':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'A':
        statusColor = Colors.blue;
        statusIcon = Icons.access_time;
        break;
      case 'P':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'C':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70, // <-- LARGURA FIXA ADICIONADA
          alignment: Alignment.center, // <-- ALINHAMENTO ADICIONADO
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            solicitacao.statusFormatado,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'Data não informada';

    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final day = parts[2];
        final month = parts[1];
        final year = parts[0];

        return '$day/$month/$year';
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}
