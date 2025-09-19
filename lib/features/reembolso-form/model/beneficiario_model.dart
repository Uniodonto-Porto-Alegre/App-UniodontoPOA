import 'dart:convert';

// Função para facilitar o parsing da string JSON completa
List<BeneficiarioModel> beneficiarioModelFromJson(String str) =>
    List<BeneficiarioModel>.from(
      json.decode(str).map((x) => BeneficiarioModel.fromJson(x)),
    );

class BeneficiarioModel {
  final String nome;
  final String carteira;
  final String plano;
  final String empresa;
  final String tipo; // Titular ou Dependente

  BeneficiarioModel({
    required this.nome,
    required this.carteira,
    required this.plano,
    required this.empresa,
    required this.tipo,
  });

  factory BeneficiarioModel.fromJson(Map<String, dynamic> json) =>
      BeneficiarioModel(
        nome: json["NOME"] ?? '',
        carteira: json["CARTEIRA"] ?? '',
        plano: json["MOD"] ?? '',
        empresa: json["EMPREGADOR"] ?? '',
        tipo: json["TIPO"] ?? '',
      );

  // Sobrescrevendo o operador de igualdade e hashCode para funcionar corretamente no DropdownButton
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeneficiarioModel &&
          runtimeType == other.runtimeType &&
          carteira == other.carteira;

  @override
  int get hashCode => carteira.hashCode;
}
