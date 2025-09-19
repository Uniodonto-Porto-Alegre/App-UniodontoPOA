class Orcamento {
  final String idUsuarioTitular;
  final String idOrcamento;
  final String procedimentos;
  final String dentista;
  final String data;
  final String beneficiario;

  Orcamento({
    required this.idUsuarioTitular,
    required this.idOrcamento,
    required this.procedimentos,
    required this.dentista,
    required this.data,
    required this.beneficiario,
  });

  factory Orcamento.fromJson(Map<String, dynamic> json) {
    return Orcamento(
      idUsuarioTitular: json['id_usuario_titular']?.toString() ?? '',
      idOrcamento: json['id_orcamento']?.toString() ?? '',
      procedimentos: json['procedimentos'] ?? '',
      dentista: json['dentista'] ?? '',
      data: json['data'] ?? '',
      beneficiario: json['beneficiário'] ?? '',
    );
  }
}
