import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../models/solicitacao_model.dart';

class ReembolsoDetalheView extends StatelessWidget {
  final Solicitacao solicitacao;

  const ReembolsoDetalheView({super.key, required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalhes da Solicitação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.vinhoUltraUniodonto,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card principal com status
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Card com informações básicas
            _buildInfoCard('Informações Gerais', Icons.info_outline, [
              _buildInfoItem(
                'Protocolo',
                solicitacao.numProtocolo,
                Icons.confirmation_number,
              ),
              _buildInfoItem(
                'ID da Solicitação',
                solicitacao.idSolicitacao.toString(),
                Icons.tag,
              ),
              _buildInfoItem(
                'Prioridade',
                solicitacao.prioridadeFormatada,
                Icons.flag,
              ),
              _buildInfoItem(
                'Ouvidoria',
                solicitacao.ouvidoria ? 'Sim' : 'Não',
                Icons.hearing,
              ),
            ]),
            const SizedBox(height: 16),

            // Card com datas
            _buildInfoCard('Cronologia', Icons.schedule, [
              _buildInfoItem(
                'Data de Criação',
                _formatDate(solicitacao.dataCriacaoSolicitacao),
                Icons.event,
              ),
              if (solicitacao.dataEncerramentoSolicitacao != null)
                _buildInfoItem(
                  'Data de Encerramento',
                  _formatDate(solicitacao.dataEncerramentoSolicitacao!),
                  Icons.event_available,
                ),
              if (solicitacao.dataPrevistaEncerramentoSolicitacao != null)
                _buildInfoItem(
                  'Previsão de Encerramento',
                  _formatDate(solicitacao.dataPrevistaEncerramentoSolicitacao!),
                  Icons.event_note,
                ),
            ]),
            const SizedBox(height: 16),

            // Card com responsáveis
            _buildInfoCard('Responsáveis', Icons.people, [
              _buildInfoItem(
                'Usuário Criação',
                solicitacao.usuarioCriacaoSolicitacao,
                Icons.person_add,
              ),
              if (solicitacao.usuarioResponsavelSolicitacao != null)
                _buildInfoItem(
                  'Responsável',
                  solicitacao.usuarioResponsavelSolicitacao!,
                  Icons.person,
                ),
              if (solicitacao.usuarioEncerramentoSolicitacao != null)
                _buildInfoItem(
                  'Encerramento',
                  solicitacao.usuarioEncerramentoSolicitacao!,
                  Icons.person_outline,
                ),
            ]),
            const SizedBox(height: 16),

            // Card com contato
            if (solicitacao.emailOutros.isNotEmpty ||
                solicitacao.telefoneOutros != '000000000')
              _buildInfoCard('Contato', Icons.contact_mail, [
                if (solicitacao.emailOutros.isNotEmpty)
                  _buildInfoItem(
                    'E-mail',
                    solicitacao.emailOutros.trim(),
                    Icons.email,
                  ),
                if (solicitacao.telefoneOutros != '000000000')
                  _buildInfoItem(
                    'Telefone',
                    solicitacao.telefoneFormatado,
                    Icons.phone,
                  ),
              ]),

            if (solicitacao.emailOutros.isNotEmpty ||
                solicitacao.telefoneOutros != '000000000')
              const SizedBox(height: 16),

            // Card com descrição
            _buildDescriptionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
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
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status da Solicitação',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    solicitacao.statusFormatado,
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
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.vinhoUltraUniodonto,
                    size: 20,
                  ),
                ),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.goiabaUniodonto, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppColors.vinhoUltraUniodonto,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vinhoUltraUniodonto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Text(
                solicitacao.descricaoSolicitacao,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'N/A';
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}
