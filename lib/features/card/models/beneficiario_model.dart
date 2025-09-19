// card/models/beneficiario_model.dart

import 'dart:convert';

// Helper function to decode the list of beneficiaries from a JSON string
List<Beneficiario> beneficiarioFromJson(String str) => List<Beneficiario>.from(
  json.decode(str).map((x) => Beneficiario.fromJson(x)),
);

class Beneficiario {
  final String abrangencia;
  final String carteira;
  final String cns;
  final String cpf;
  final String empregador;
  final String inclusao;
  final String mod;
  final String nascimento;
  final String nome;
  final String registro;
  final String tipoContratacao;

  Beneficiario({
    required this.abrangencia,
    required this.carteira,
    required this.cns,
    required this.cpf,
    required this.empregador,
    required this.inclusao,
    required this.mod,
    required this.nascimento,
    required this.nome,
    required this.registro,
    required this.tipoContratacao,
  });

  // Factory constructor to create a Beneficiario instance from a map (JSON object)
  factory Beneficiario.fromJson(Map<String, dynamic> json) => Beneficiario(
    abrangencia: json["ABRANGENCIA"] ?? '',
    carteira: json["CARTEIRA"] ?? '',
    cns: json["CNS"] ?? '',
    cpf: json["CPF"] ?? '',
    empregador: json["EMPREGADOR"] ?? '',
    inclusao: json["INCLUSAO"] ?? '',
    mod: json["MOD"] ?? '',
    nascimento: json["NASCIMENTO"] ?? '',
    nome: json["NOME"] ?? '',
    registro: json["REGISTRO"] ?? '',
    tipoContratacao: json["TIPO_CONTRATACAO"] ?? '',
  );
}
