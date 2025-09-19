import 'dart:convert';
import 'package:http/http.dart' as http;

class CepModel {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String ibge;
  final String gia;
  final String ddd;
  final String siafi;
  final bool erro;

  CepModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.gia,
    required this.ddd,
    required this.siafi,
    this.erro = false,
  });

  factory CepModel.fromJson(Map<String, dynamic> json) {
    return CepModel(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      ibge: json['ibge'] ?? '',
      gia: json['gia'] ?? '',
      ddd: json['ddd'] ?? '',
      siafi: json['siafi'] ?? '',
      erro: json['erro'] ?? false,
    );
  }
}

class CepService {
  static const String _viaCepBaseUrl = 'https://viacep.com.br/ws';
  static const String _nominatimBaseUrl =
      'https://nominatim.openstreetmap.org/search';

  /// Busca informações do CEP usando a API ViaCEP
  static Future<CepModel?> getAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      String cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanCep.length != 8) {
        throw Exception('CEP deve conter 8 dígitos');
      }

      final uri = Uri.parse('$_viaCepBaseUrl/$cleanCep/json/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['erro'] == true) {
          throw Exception('CEP não encontrado');
        }

        return CepModel.fromJson(data);
      } else {
        throw Exception('Erro ao consultar CEP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar CEP: $e');
      throw Exception('Erro ao consultar CEP: $e');
    }
  }

  /// Converte endereço em coordenadas geográficas usando Nominatim (OpenStreetMap)
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    CepModel address,
  ) async {
    try {
      // Monta o endereço completo para geocodificação
      String fullAddress =
          '${address.logradouro}, ${address.bairro}, ${address.localidade}, ${address.uf}, Brasil';

      final uri = Uri.parse('$_nominatimBaseUrl').replace(
        queryParameters: {
          'q': fullAddress,
          'format': 'json',
          'limit': '1',
          'countrycodes': 'br',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception('Coordenadas não encontradas para este endereço');
        }

        final result = data.first;
        return {
          'latitude': double.parse(result['lat']),
          'longitude': double.parse(result['lon']),
        };
      } else {
        throw Exception('Erro ao buscar coordenadas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao converter endereço em coordenadas: $e');
      throw Exception('Erro ao obter coordenadas: $e');
    }
  }

  /// Função combinada que busca CEP e retorna coordenadas
  static Future<Map<String, double>?> getCoordinatesByCep(String cep) async {
    try {
      final address = await getAddressByCep(cep);
      if (address == null) {
        throw Exception('Endereço não encontrado');
      }

      return await getCoordinatesFromAddress(address);
    } catch (e) {
      print('Erro ao obter coordenadas por CEP: $e');
      rethrow;
    }
  }
}
