// models/prestador_model.dart

import 'dart:convert';

// Função para decodificar a resposta da API em um objeto PrestadorResponse
PrestadorResponse prestadorResponseFromJson(String str) =>
    PrestadorResponse.fromJson(json.decode(str));

// Classe principal que representa a resposta da API
class PrestadorResponse {
  final List<Prestador> data;
  final Pagination pagination;

  PrestadorResponse({required this.data, required this.pagination});

  factory PrestadorResponse.fromJson(Map<String, dynamic> json) =>
      PrestadorResponse(
        data: List<Prestador>.from(
          json["data"].map((x) => Prestador.fromJson(x)),
        ),
        pagination: Pagination.fromJson(json["pagination"]),
      );
}

// Classe que representa um único prestador
class Prestador {
  final String nome;
  final String? endereco;
  final String? estado;
  final String? cidade;
  final String? bairro;
  final String? contatos;
  final String? celulares;
  final String? cro;
  final String? areasDeAtuacao;

  Prestador({
    required this.nome,
    this.endereco,
    this.estado,
    this.cidade,
    this.bairro,
    this.contatos,
    this.celulares,
    this.cro,
    this.areasDeAtuacao,
  });

  factory Prestador.fromJson(Map<String, dynamic> json) => Prestador(
    nome: json["Nome"] ?? "Nome não informado",
    endereco: json["Endereco"],
    estado: json["Estado"],
    cidade: json["Cidade"],
    bairro: json["Bairro"],
    contatos: json["Contatos"],
    celulares: json["Celulares"],
    cro: json["CRO"],
    areasDeAtuacao: json["Areas_de_Atuacao"],
  );

  // Método para verificar se tem WhatsApp e limpar o número
  bool get hasWhatsApp {
    return celulares?.contains('*') ?? false;
  }

  String? get cleanCelular {
    if (celulares == null) return null;
    // Remove o * e espaços extras
    return celulares!.replaceAll('*', '').trim();
  }

  // Método para obter o número formatado para WhatsApp
  String? get whatsappNumber {
    if (!hasWhatsApp || cleanCelular == null) return null;

    // Remove caracteres não numéricos, exceto +
    final number = cleanCelular!.replaceAll(RegExp(r'[^\d+]'), '');

    // Se não começar com +, adiciona o código do Brasil
    if (number.startsWith('+')) return number;
    if (number.startsWith('55')) return '+$number';

    return '+55$number';
  }
}

// Classe que representa as informações de paginação
class Pagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool nolimit;

  Pagination({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    required this.nolimit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["total_pages"],
    nolimit: json["nolimit"] ?? false,
  );
}
