import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart'; // Mantenha seu import de tema
import '../models/mensalidade_model.dart';
import '../views/mensalidade_detalhe_view.dart';

class MensalidadeListItem extends StatelessWidget {
  final Mensalidade mensalidade;

  const MensalidadeListItem({super.key, required this.mensalidade});

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
            offset: const Offset(0, 2),
            blurRadius: 10,
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
                    MensalidadeDetalheView(mensalidade: mensalidade),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fatura Nº: ${mensalidade.idFatura ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.vinhoUltraUniodonto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vencimento: ${mensalidade.dataVencimentoFormatada}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mensalidade.valorFormatado,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // --- LÓGICA DE CÁLCULO DE STATUS ADICIONADA ---
    String statusText;
    if (mensalidade.indCancelamentoCr) {
      statusText = 'Cancelada';
    } else if (mensalidade.dataRecebContaReceb != null) {
      statusText = 'Paga';
    } else {
      final hoje = DateTime.now();
      final dataVencimento = mensalidade.dataVencitoContaReceb;
      // Compara apenas a data, ignorando a hora para evitar problemas com fuso horário
      final isVencida = DateTime(
        dataVencimento.year,
        dataVencimento.month,
        dataVencimento.day,
      ).isBefore(DateTime(hoje.year, hoje.month, hoje.day));
      if (isVencida) {
        statusText = 'Vencida';
      } else {
        statusText = 'Em Aberto';
      }
    }
    // --- FIM DA LÓGICA ---

    Color statusColor;
    IconData statusIcon;

    switch (statusText) {
      case 'Paga':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Em Aberto':
        statusColor = Colors.blue;
        statusIcon = Icons.access_time_filled;
        break;
      case 'Vencida':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'Cancelada':
        statusColor = Colors.grey[700]!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(statusIcon, color: statusColor, size: 32),
        const SizedBox(height: 8),
        Container(
          width: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
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
}
