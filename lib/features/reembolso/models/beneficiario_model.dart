class Beneficiario {
  final String carteira;
  final String nome;
  final String cpf;
  final String tipo;

  Beneficiario({
    required this.carteira,
    required this.nome,
    required this.cpf,
    required this.tipo,
  });

  factory Beneficiario.fromJson(Map<String, dynamic> json) {
    return Beneficiario(
      carteira: json['CARTEIRA'] ?? '',
      nome: json['NOME'] ?? '',
      cpf: json['CPF'] ?? '',
      tipo: json['TIPO'] ?? '',
    );
  }
}
