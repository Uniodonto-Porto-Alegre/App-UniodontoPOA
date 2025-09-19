// services/prestador_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer'; // Import para usar a função log()

import '../models/prestador_model.dart';

class PrestadorService {
  // URL base da sua API
  static const String _baseUrl =
      "https://prestador-src.uniodontopoa.com.br:2087/ListaPrestadorGeral";

  // Token de autorização
  static const String token =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc1MDA3NzAzMywianRpIjoiM2UxYTY5MDctNDE5Ny00OTUyLTg3YjctNTU3NGEyODA3MGZmIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImJyeWFuLnNpbHZhIiwibmJmIjoxNzUwMDc3MDMzLCJjc3JmIjoiOGVhMzJlN2QtZjExNy00YjNmLWI1NDktM2Y2YmZkOTY3YjQ2IiwiZXhwIjoxNzY1NjI5MDMzfQ.SGNSZgA4dk6Cakj3mtgzIfTwKtIfUWV99Xsrd1EeiUI';

  // Cabeçalhos para a requisição
  static const Map<String, String> _headers = {
    'Authorization': token,
    'Content-Type': 'application/json',
  };

  // Busca prestadores com paginação
  Future<PrestadorResponse> fetchPrestadores({
    int page = 1,
    String estado = '',
    String cidade = '',
    String bairro = '',
    String nome = '',
    String areaDeAtuacao = '',
    String cro = '',
  }) async {
    // Monta a URL com os parâmetros de filtro e paginação
    final queryParams = <String, String?>{
      'limit': null,
      'page': page.toString(),
    };

    // Adiciona os parâmetros apenas se não estiverem vazios
    if (estado.isNotEmpty) queryParams['estado'] = estado;
    if (cidade.isNotEmpty) queryParams['cidade'] = cidade;
    if (bairro.isNotEmpty) queryParams['bairro'] = bairro;
    if (nome.isNotEmpty) queryParams['nome'] = nome;
    if (areaDeAtuacao.isNotEmpty)
      queryParams['area_de_atuacao'] = areaDeAtuacao;
    if (cro.isNotEmpty) queryParams['cro'] = cro;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
    log('URI: $uri');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return prestadorResponseFromJson(response.body);
      } else {
        log(
          'Falha ao carregar prestadores. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Falha ao carregar prestadores: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }

  // Busca todos os prestadores (sem paginação) para popular os filtros
  Future<List<Prestador>> fetchAllPrestadores({
    String estado = '',
    String cidade = '',
  }) async {
    // Monta a URL com nolimit para buscar todos os dados
    final queryParams = <String, String>{'nolimit': ''};

    // Adiciona os parâmetros apenas se não estiverem vazios
    if (estado.isNotEmpty) queryParams['estado'] = estado;
    if (cidade.isNotEmpty) queryParams['cidade'] = cidade;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
    log('URI para filtros: $uri');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<Prestador> prestadores = (decoded['data'] as List)
            .map((item) => Prestador.fromJson(item))
            .toList();
        return prestadores;
      } else {
        log(
          'Falha ao carregar filtros. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Falha ao carregar dados para filtros: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Falha na conexão para filtros: $e');
    }
  }
}
