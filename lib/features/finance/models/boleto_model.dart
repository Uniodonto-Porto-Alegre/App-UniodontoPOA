class Boleto {
  final String id;
  final double valor;
  final DateTime dataVencimento;
  final String linhaDigitavel;
  final String status; // Ex: 'ABERTO', 'VENCIDO'

  Boleto({
    required this.id,
    required this.valor,
    required this.dataVencimento,
    required this.linhaDigitavel,
    required this.status,
  });

  // Adicione aqui os métodos fromJson, toJson, etc.
}
