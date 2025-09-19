class Boleto {
  final String idContaReceber;
  final String dataVencimento;
  final String valor;
  final bool binarioDisponivel;

  Boleto({
    required this.idContaReceber,
    required this.dataVencimento,
    required this.valor,
    required this.binarioDisponivel,
  });

  factory Boleto.fromJson(Map<String, dynamic> json) {
    return Boleto(
      idContaReceber: json['idContaReceber'] ?? '',
      dataVencimento: json['DataVencimento'] ?? '',
      valor: json['Valor'] ?? '0.0',
      binarioDisponivel: json['BinarioDisponivel'] ?? false,
    );
  }
}
