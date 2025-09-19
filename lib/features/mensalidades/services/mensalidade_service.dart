import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Importado para usar o debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mensalidade_model.dart';

/// Tipos de erro específicos do serviço de mensalidades
enum MensalidadeServiceErrorType {
  networkError,
  serverError,
  authenticationError,
  dataError,
  unknown,
}

/// Exceção customizada para erros do serviço de mensalidades
class MensalidadeServiceException implements Exception {
  final String message;
  final MensalidadeServiceErrorType type;

  const MensalidadeServiceException(this.message, this.type);

  @override
  String toString() => 'MensalidadeServiceException: $message';

  /// Retorna uma mensagem amigável para o usuário baseada no tipo de erro
  String get userFriendlyMessage {
    switch (type) {
      case MensalidadeServiceErrorType.networkError:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';
      case MensalidadeServiceErrorType.serverError:
        return 'Servidor indisponível. Tente novamente em alguns instantes.';
      case MensalidadeServiceErrorType.authenticationError:
        return 'Dados de usuário não encontrados. Faça login novamente.';
      case MensalidadeServiceErrorType.dataError:
        return 'Erro nos dados recebidos. Se o problema persistir, contate o suporte.';
      case MensalidadeServiceErrorType.unknown:
        return 'Erro inesperado. Tente novamente ou contate o suporte.';
    }
  }
}

class MensalidadeService {
  // TODO: Substituir pela URL base da sua API
  static const String _baseUrl =
      "https://beneficiario-src.uniodontopoa.com.br:2083";
  static const Duration _timeout = Duration(seconds: 30);

  // TODO: Substituir pela lógica de obtenção dinâmica do token
  static const String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc0NDgxMjMwMSwianRpIjoiZDYzODA3ZWEtOTUwNC00ZWQ0LWE2ODUtOTE3NjNlY2UwYTU2IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6InRpIiwidGlwb19jaGF2ZSI6IklOVEVSTk8ifSwibmJmIjoxNzQ0ODEyMzAxLCJjc3JmIjoiZWFkMjVlYWEtMzY0Zi00NTU5LWE4ZWItZjE3NjljMjI3YjRjIiwiZXhwIjoxNzYwMzY0MzAxfQ.JEml0IwbJf2yNAmEZT8bl3mbTA4ZrqSMzC3FTkJ4NgE';

  // Headers padrão para as requisições
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
    'Accept': 'application/json',
  };

  /// Busca todas as mensalidades para o usuário logado
  Future<List<Mensalidade>> fetchMensalidades() async {
    debugPrint('[LOG] Iniciando busca de mensalidades...');
    try {
      final cpf = await _obterCpfDoUsuario();
      final cpfSanitizado = _sanitizarCpf(cpf);
      final url = _construirUrl(cpfSanitizado);
      final response = await _fazerRequisicao(url);
      return _processarResposta(response);
    } on MensalidadeServiceException catch (e) {
      debugPrint(
        '[LOG] Erro de serviço (MensalidadeServiceException) em fetchMensalidades: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[LOG] Erro inesperado em fetchMensalidades: $e');
      throw MensalidadeServiceException(
        'Erro inesperado ao buscar mensalidades: $e',
        MensalidadeServiceErrorType.unknown,
      );
    }
  }

  /// Obtém o CPF do usuário do SharedPreferences
  Future<String> _obterCpfDoUsuario() async {
    debugPrint('[LOG] Obtendo CPF do SharedPreferences...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final cpf = prefs.getString('user_cpf');

      if (cpf == null || cpf.isEmpty) {
        debugPrint('[LOG] ERRO: CPF não encontrado no SharedPreferences.');
        throw const MensalidadeServiceException(
          'CPF do usuário não encontrado no armazenamento local.',
          MensalidadeServiceErrorType.authenticationError,
        );
      }
      debugPrint('[LOG] CPF obtido com sucesso: $cpf');
      return cpf;
    } catch (e) {
      if (e is MensalidadeServiceException) rethrow;
      debugPrint('[LOG] ERRO ao ler dados locais (SharedPreferences): $e');
      throw MensalidadeServiceException(
        'Falha ao ler dados locais: $e',
        MensalidadeServiceErrorType.dataError,
      );
    }
  }

  /// Remove caracteres não numéricos do CPF
  String _sanitizarCpf(String cpf) {
    final sanitizado = cpf.replaceAll(RegExp(r'[\.\-]'), '');
    debugPrint('[LOG] CPF sanitizado: $sanitizado');
    return sanitizado;
  }

  /// Constrói a URL da requisição
  Uri _construirUrl(String cpf) {
    final url = Uri.parse(
      '$_baseUrl/mensalidades',
    ).replace(queryParameters: {'cpf': cpf});
    debugPrint('[LOG] URL da requisição construída: $url');
    return url;
  }

  /// Faz a requisição HTTP com tratamento de timeout e erros de rede
  Future<http.Response> _fazerRequisicao(Uri url) async {
    debugPrint('[LOG] Realizando requisição GET para a API...');
    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);
      debugPrint(
        '[LOG] Resposta recebida da API com statusCode: ${response.statusCode}',
      );
      return response;
    } on SocketException catch (e) {
      debugPrint('[LOG] ERRO de SocketException (sem rede): $e');
      throw const MensalidadeServiceException(
        'Erro de conexão. Verifique sua internet.',
        MensalidadeServiceErrorType.networkError,
      );
    } on HttpException catch (e) {
      debugPrint('[LOG] ERRO de HttpException: $e');
      throw const MensalidadeServiceException(
        'Erro de comunicação com o servidor.',
        MensalidadeServiceErrorType.networkError,
      );
    } catch (e) {
      // Geralmente TimeoutException
      debugPrint(
        '[LOG] ERRO genérico na requisição (provavelmente Timeout): $e',
      );
      throw const MensalidadeServiceException(
        'A requisição demorou muito para responder. Tente novamente.',
        MensalidadeServiceErrorType.networkError,
      );
    }
  }

  /// Processa a resposta da API e trata os códigos de status
  List<Mensalidade> _processarResposta(http.Response response) {
    debugPrint('[LOG] Processando resposta da API...');
    switch (response.statusCode) {
      case 200:
        return _extrairMensalidades(response.body);
      case 404:
        debugPrint(
          '[LOG] Nenhuma mensalidade encontrada (status 404). Retornando lista vazia.',
        );
        return []; // Nenhuma mensalidade encontrada
      case 401:
        debugPrint('[LOG] ERRO de autenticação (status 401).');
        throw const MensalidadeServiceException(
          'Acesso não autorizado. Faça login novamente.',
          MensalidadeServiceErrorType.authenticationError,
        );
      case 500:
        debugPrint('[LOG] ERRO interno do servidor (status 500).');
        throw const MensalidadeServiceException(
          'Erro interno do servidor. Tente mais tarde.',
          MensalidadeServiceErrorType.serverError,
        );
      default:
        debugPrint(
          '[LOG] ERRO desconhecido do servidor (status ${response.statusCode}).',
        );
        throw MensalidadeServiceException(
          'Erro do servidor (${response.statusCode}): ${response.body}',
          MensalidadeServiceErrorType.serverError,
        );
    }
  }

  /// Extrai a lista de Mensalidade do corpo da resposta JSON
  List<Mensalidade> _extrairMensalidades(String responseBody) {
    debugPrint('[LOG] Extraindo mensalidades do corpo da resposta JSON...');
    try {
      final data = json.decode(responseBody) as Map<String, dynamic>;
      if (!data.containsKey('mensalidades')) {
        debugPrint(
          '[LOG] ERRO: a chave "mensalidades" não foi encontrada no JSON.',
        );
        throw const MensalidadeServiceException(
          'Formato de resposta da API inválido.',
          MensalidadeServiceErrorType.dataError,
        );
      }
      final mensalidadesJson = data['mensalidades'] as List<dynamic>;
      debugPrint(
        '[LOG] Sucesso: ${mensalidadesJson.length} mensalidades extraídas do JSON.',
      );
      return mensalidadesJson
          .map((json) => Mensalidade.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[LOG] ERRO ao decodificar ou processar o JSON: $e');
      throw MensalidadeServiceException(
        'Erro ao processar os dados recebidos: $e',
        MensalidadeServiceErrorType.dataError,
      );
    }
  }
}
