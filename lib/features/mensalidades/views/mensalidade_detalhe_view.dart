import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart'; // Mantenha seu import de tema
import '../models/mensalidade_model.dart';
// import 'package:url_launcher/url_launcher.dart'; // Descomente para usar o link do boleto

class MensalidadeDetalheView extends StatelessWidget {
  final Mensalidade mensalidade;

  const MensalidadeDetalheView({super.key, required this.mensalidade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalhes da Mensalidade',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.vinhoUltraUniodonto,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildInfoCard('Valores e Datas', Icons.monetization_on, [
              _buildInfoItem(
                'Valor da Mensalidade',
                mensalidade.valorFormatado,
                Icons.attach_money,
              ),
              _buildInfoItem(
                'Vencimento',
                mensalidade.dataVencimentoFormatada,
                Icons.event,
              ),
              if (mensalidade.dataRecebContaReceb != null)
                _buildInfoItem(
                  'Data do Pagamento',
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(mensalidade.dataRecebContaReceb!),
                  Icons.event_available,
                ),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Informações da Fatura', Icons.receipt_long, [
              _buildInfoItem(
                'Número da Fatura',
                mensalidade.idFatura?.toString() ?? 'N/A',
                Icons.tag,
              ),
              if (mensalidade.strObservacoes != null &&
                  mensalidade.strObservacoes!.isNotEmpty)
                _buildInfoItem(
                  'Observações',
                  mensalidade.strObservacoes!,
                  Icons.comment,
                ),
            ]),
            if (mensalidade.urlVindiBoleto != null &&
                mensalidade.urlVindiBoleto!.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Abrir Boleto'),
                onPressed: () {
                  // _launchURL(mensalidade.urlVindiBoleto!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vinhoUltraUniodonto,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Função para abrir o link do boleto
  // Future<void> _launchURL(String url) async {
  //   final uri = Uri.parse(url);
  //   if (!await launchUrl(uri)) {
  //     throw Exception('Não foi possível abrir o link $url');
  //   }
  // }

  Widget _buildStatusCard() {
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.8), statusColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(statusIcon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.vinhoUltraUniodonto, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vinhoUltraUniodonto,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.goiabaUniodonto, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
