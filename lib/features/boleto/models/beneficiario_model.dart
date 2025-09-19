import 'dart:convert';

class Beneficiario {
  final String cpf;
  final String nome;
  final String nascimento;
  final String telefone;

  Beneficiario({
    required this.cpf,
    required this.nome,
    required this.nascimento,
    required this.telefone,
  });

  factory Beneficiario.fromJson(Map<String, dynamic> json) {
    return Beneficiario(
      cpf: json['CPF'] ?? '',
      nome: json['NOME'] ?? '',
      nascimento: json['NASCIMENTO'] ?? '',
      telefone: json['TELEFONE'] ?? '',
    );
  }

  static List<Beneficiario> fromJsonList(String jsonString) {
    final List<dynamic> parsed = json.decode(jsonString);
    return parsed.map((json) => Beneficiario.fromJson(json)).toList();
  }
}
