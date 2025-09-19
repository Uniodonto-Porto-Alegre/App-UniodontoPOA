import 'package:intl/intl.dart';

class Mensalidade {
  final int idContaReceber;
  final DateTime dataVencitoContaReceb;
  final double valorVenctoContaReceb;
  final DateTime? dataRecebContaReceb;
  final double valorRecebContaReceb;
  final bool indCancelamentoCr;
  final int? idFatura;
  final String? urlVindiBoleto;
  final String? strObservacoes;
  final String status; // Novo campo vindo da API para simplificar

  Mensalidade({
    required this.idContaReceber,
    required this.dataVencitoContaReceb,
    required this.valorVenctoContaReceb,
    this.dataRecebContaReceb,
    required this.valorRecebContaReceb,
    required this.indCancelamentoCr,
    this.idFatura,
    this.urlVindiBoleto,
    this.strObservacoes,
    required this.status,
  });

  factory Mensalidade.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter de forma segura qualquer valor para double.
    double safeParseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Função auxiliar para converter de forma segura uma String para DateTime.
    DateTime? safeParseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      return DateTime.tryParse(dateString);
    }

    return Mensalidade(
      idContaReceber: json['id_conta_receber'] ?? 0,
      dataVencitoContaReceb:
          safeParseDateTime(json['data_vencito_conta_receb']) ?? DateTime(1970),
      valorVenctoContaReceb: safeParseDouble(json['valor_vencto_conta_receb']),
      dataRecebContaReceb: safeParseDateTime(json['data_receb_conta_receb']),
      valorRecebContaReceb: safeParseDouble(json['valor_receb_conta_receb']),
      indCancelamentoCr: json['ind_cancelamento_cr'] ?? false,
      idFatura: json['id_fatura'],
      urlVindiBoleto: json['UrlVindiBoleto'], // Chave na API tem 'U' maiúsculo
      strObservacoes: json['str_observacoes'],
      status: json['status'] ?? 'Desconhecido', // Novo campo
    );
  }

  // Helper para formatar o valor como moeda brasileira
  String get valorFormatado {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(valorVenctoContaReceb);
  }

  // Helper para formatar a data de vencimento
  String get dataVencimentoFormatada {
    return DateFormat('dd/MM/yyyy').format(dataVencitoContaReceb);
  }

  // O status agora vem diretamente da API, simplificando a lógica no app.
  String get statusFormatado {
    return status;
  }
}
