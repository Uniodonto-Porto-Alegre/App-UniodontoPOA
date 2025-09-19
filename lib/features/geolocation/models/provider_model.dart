class ProviderModel {
  final String nome;
  final String endereco;
  final String areaDeAtuacao;
  final String? telefone;
  final String? celular;
  final int? ddd;
  final bool isEspecialista;
  final double latitude;
  final double longitude;
  final double? distancia; // Distância em km

  ProviderModel({
    required this.nome,
    required this.endereco,
    required this.areaDeAtuacao,
    this.telefone,
    this.celular,
    this.ddd,
    required this.isEspecialista,
    required this.latitude,
    required this.longitude,
    this.distancia,
  });

  // A única alteração foi feita aqui dentro
  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter qualquer valor (String, int, double) para double
    double? _parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Função auxiliar para converter qualquer valor para int
    int? _parseInt(dynamic value) {
      final parsedDouble = _parseToDouble(value);
      return parsedDouble?.toInt();
    }

    return ProviderModel(
      nome: json['Nome'] ?? 'Nome não informado',
      endereco: json['Endereco'] ?? 'Endereço não informado',
      areaDeAtuacao: json['Area_de_atuacao'] ?? 'Área não informada',
      telefone: json['Telefone']?.toString(),
      celular: json['Celular'],

      // CORRIGIDO: Agora o DDD é convertido de forma segura
      ddd: _parseInt(json['DDD']),

      isEspecialista: json['Especialista'] == 'Sim',

      // PREVENÇÃO: Adicionada conversão segura para os outros campos numéricos
      latitude: _parseToDouble(json['Latitude']) ?? 0.0,
      longitude: _parseToDouble(json['Longitude']) ?? 0.0,

      distancia: (_parseToDouble(json['distance']) != null)
          ? _parseToDouble(json['distance'])! / 1000
          : null,
    );
  }

  String get telefoneFormatado {
    if (celular != null && celular!.isNotEmpty) {
      return celular!;
    }
    if (telefone != null && ddd != null) {
      return '($ddd) $telefone';
    }
    return 'Telefone não disponível';
  }

  String get distanciaFormatada {
    if (distancia != null) {
      if (distancia! < 1) {
        final metros = (distancia! * 1000).round();
        return '$metros m';
      }
      return '${distancia!.toStringAsFixed(1)} km';
    }
    return '';
  }
}
