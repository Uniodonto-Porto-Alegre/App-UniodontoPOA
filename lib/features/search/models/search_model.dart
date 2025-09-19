class SearchModel {
  final String? estado;
  final String? cidade;
  final String? bairro;
  final String? areaAtuacao;
  final String? cro;
  final String? nome;

  SearchModel({
    this.estado,
    this.cidade,
    this.bairro,
    this.areaAtuacao,
    this.cro,
    this.nome,
  });

  SearchModel copyWith({
    String? estado,
    String? cidade,
    String? bairro,
    String? areaAtuacao,
    String? cro,
    String? nome,
  }) {
    return SearchModel(
      estado: estado ?? this.estado,
      cidade: cidade ?? this.cidade,
      bairro: bairro ?? this.bairro,
      areaAtuacao: areaAtuacao ?? this.areaAtuacao,
      cro: cro ?? this.cro,
      nome: nome ?? this.nome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estado': estado,
      'cidade': cidade,
      'bairro': bairro,
      'areaAtuacao': areaAtuacao,
      'cro': cro,
      'nome': nome,
    };
  }

  @override
  String toString() {
    return 'SearchModel(estado: $estado, cidade: $cidade, bairro: $bairro, areaAtuacao: $areaAtuacao, cro: $cro, nome: $nome)';
  }
}

// Modelos para os dados dos dropdowns
class Estado {
  final String id;
  final String nome;
  final String sigla;

  Estado({required this.id, required this.nome, required this.sigla});
}

class Cidade {
  final String id;
  final String nome;
  final String estadoId;

  Cidade({required this.id, required this.nome, required this.estadoId});
}

class Bairro {
  final String id;
  final String nome;
  final String cidadeId;

  Bairro({required this.id, required this.nome, required this.cidadeId});
}

class AreaAtuacao {
  final String id;
  final String nome;

  AreaAtuacao({required this.id, required this.nome});
}

class Prestador {
  final String id;
  final String nome;
  final String cro;
  final String areaAtuacao;
  final String endereco;
  final String telefone;
  final String email;

  Prestador({
    required this.id,
    required this.nome,
    required this.cro,
    required this.areaAtuacao,
    required this.endereco,
    required this.telefone,
    required this.email,
  });
}
