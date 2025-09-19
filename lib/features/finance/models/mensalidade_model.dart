class Mensalidade {
  final String id;
  final double valor;
  final DateTime dataPagamento;
  final DateTime mesReferencia;
  final String status; // Ex: 'PAGO', 'VENCIDO'

  Mensalidade({
    required this.id,
    required this.valor,
    required this.dataPagamento,
    required this.mesReferencia,
    required this.status,
  });

  // Adicione aqui os métodos fromJson, toJson, etc.
}
