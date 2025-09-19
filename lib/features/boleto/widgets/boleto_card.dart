import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/boleto_model.dart';

class BoletoCard extends StatelessWidget {
  final Boleto boleto;
  final VoidCallback onViewPressed;

  const BoletoCard({
    Key? key,
    required this.boleto,
    required this.onViewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tenta formatar a data, mas usa o valor original se falhar
    String dataFormatada;
    bool isVencido = false;
    try {
      // Considera diferentes formatos de data que podem vir da API
      DateTime parsedDate;
      if (boleto.dataVencimento.contains('/')) {
        parsedDate = DateFormat(
          'dd/MM/yyyy HH:mm:ss',
        ).parse(boleto.dataVencimento);
      } else {
        parsedDate = DateTime.parse(boleto.dataVencimento);
      }
      dataFormatada = DateFormat('dd/MM/yyyy').format(parsedDate);
      // Compara apenas a data, ignorando a hora
      isVencido = DateUtils.isSameDay(parsedDate, DateTime.now())
          ? false
          : parsedDate.isBefore(DateTime.now());
    } catch (e) {
      dataFormatada = boleto.dataVencimento.split(' ')[0];
    }

    // Tenta formatar o valor, mas usa o valor original se falhar
    String valorFormatado;
    try {
      final valorNumerico = double.parse(boleto.valor.replaceAll(',', '.'));
      valorFormatado = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
      ).format(valorNumerico);
    } catch (e) {
      valorFormatado = boleto.valor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com status e valor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isVencido
                                  ? Colors.red[100]
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isVencido ? 'VENCIDO' : 'EM DIA',
                              style: TextStyle(
                                color: isVencido
                                    ? Colors.red[800]
                                    : Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vencimento',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dataFormatada,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Valor',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          valorFormatado,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(height: 1, color: Colors.grey[200]),

                const SizedBox(height: 16),

                // ID do boleto
                Row(
                  children: [
                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${boleto.idContaReceber}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botão para visualizar/baixar
                ElevatedButton.icon(
                  onPressed: boleto.binarioDisponivel ? onViewPressed : null,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('VISUALIZAR BOLETO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                // Mensagem de indisponibilidade
                if (!boleto.binarioDisponivel)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PDF indisponível para este boleto',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
