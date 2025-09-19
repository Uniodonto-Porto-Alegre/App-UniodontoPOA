import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/beneficiario_model.dart';
import '../models/solicitacao_model.dart';

class ReembolsoService {
  static const String _baseUrl =
      "https://beneficiario-src.uniodontopoa.com.br:2083";
  static const String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc0NDgxMjMwMSwianRpIjoiZDYzODA3ZWEtOTUwNC00ZWQ0LWE2ODUtOTE3NjNlY2UwYTU2IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6InRpIiwidGlwb19jaGF2ZSI6IklOVEVSTk8ifSwibmJmIjoxNzQ0ODEyMzAxLCJjc3JmIjoiZWFkMjVlYWEtMzY0Zi00NTU5LWE4ZWItZjE3NjljMjI3YjRjIiwiZXhwIjoxNzYwMzY0MzAxfQ.JEml0IwbJf2yNAmEZT8bl3mbTA4ZrqSMzC3FTkJ4NgE';
  static const String _motivoReembolso = '224';
  static const Duration _timeout = Duration(seconds: 30);

  // Headers padrão para as requisições
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
    'Accept': 'application/json',
  };

  /// Busca todas as solicitações de reembolso para o usuário titular
  Future<List<Solicitacao>> fetchReembolsos() async {
    try {
      final carteiraTitular = await _obterCarteiraTitular();
      final carteiraProcessada = _processarCarteira(carteiraTitular);

      final url = _construirUrl(carteiraProcessada);

      final response = await _fazerRequisicao(url);

      return _processarResposta(response);
    } on ReembolsoServiceException {
      rethrow;
    } catch (e) {
      throw ReembolsoServiceException(
        'Erro inesperado ao buscar reembolsos: $e',
        ReembolsoServiceErrorType.unknown,
      );
    }
  }

  /// Obtém os dados do beneficiário titular do SharedPreferences
  Future<String> _obterCarteiraTitular() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final beneficiarioJsonString = prefs.getString('beneficiario_data');

      if (beneficiarioJsonString == null) {
        throw ReembolsoServiceException(
          'Dados do beneficiário não encontrados. Faça login novamente.',
          ReembolsoServiceErrorType.authenticationError,
        );
      }

      final beneficiarioListJson =
          json.decode(beneficiarioJsonString) as List<dynamic>;

      if (beneficiarioListJson.isEmpty) {
        throw ReembolsoServiceException(
          'Lista de beneficiários vazia. Verifique seus dados.',
          ReembolsoServiceErrorType.dataError,
        );
      }

      final beneficiarioTitular = Beneficiario.fromJson(
        beneficiarioListJson.first,
      );

      if (beneficiarioTitular.carteira.isEmpty) {
        throw ReembolsoServiceException(
          'Carteira do beneficiário não encontrada.',
          ReembolsoServiceErrorType.dataError,
        );
      }

      return beneficiarioTitular.carteira;
    } catch (e) {
      if (e is ReembolsoServiceException) rethrow;

      throw ReembolsoServiceException(
        'Erro ao processar dados do beneficiário: $e',
        ReembolsoServiceErrorType.dataError,
      );
    }
  }

  /// Processa a carteira removendo dígitos conforme regra de negócio
  String _processarCarteira(String carteira) {
    String carteiraProcessada = carteira;

    // Remove o '0' após o primeiro '6' se existir
    final indexOfSix = carteiraProcessada.indexOf('6');
    if (indexOfSix != -1 &&
        indexOfSix + 1 < carteiraProcessada.length &&
        carteiraProcessada[indexOfSix + 1] == '0') {
      carteiraProcessada =
          carteiraProcessada.substring(0, indexOfSix + 1) +
          carteiraProcessada.substring(indexOfSix + 2);
    }

    // Remove os dois últimos dígitos
    if (carteiraProcessada.length > 2) {
      carteiraProcessada = carteiraProcessada.substring(
        0,
        carteiraProcessada.length - 2,
      );
    }

    return carteiraProcessada;
  }

  /// Constrói a URL da requisição
  Uri _construirUrl(String carteira) {
    final queryParams = {
      'id_usuario_titular_solicitante': carteira,
      'id_solicitacao_motivo': _motivoReembolso,
    };

    return Uri.parse(
      '$_baseUrl/solicitacoes',
    ).replace(queryParameters: queryParams);
  }

  /// Faz a requisição HTTP com tratamento de timeout e erros de rede
  Future<http.Response> _fazerRequisicao(Uri url) async {
    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      return response;
    } on SocketException {
      throw ReembolsoServiceException(
        'Erro de conexão. Verifique sua internet.',
        ReembolsoServiceErrorType.networkError,
      );
    } on HttpException {
      throw ReembolsoServiceException(
        'Erro de comunicação com o servidor.',
        ReembolsoServiceErrorType.networkError,
      );
    } on FormatException {
      throw ReembolsoServiceException(
        'Erro no formato da resposta do servidor.',
        ReembolsoServiceErrorType.serverError,
      );
    } catch (e) {
      throw ReembolsoServiceException(
        'Timeout na requisição. Tente novamente.',
        ReembolsoServiceErrorType.networkError,
      );
    }
  }

  /// Processa a resposta da API
  List<Solicitacao> _processarResposta(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return _extrairSolicitacoes(response.body);

      case 404:
        return []; // Nenhuma solicitação encontrada

      case 401:
        throw ReembolsoServiceException(
          'Acesso negado. Faça login novamente.',
          ReembolsoServiceErrorType.authenticationError,
        );

      case 403:
        throw ReembolsoServiceException(
          'Você não tem permissão para acessar estes dados.',
          ReembolsoServiceErrorType.authorizationError,
        );

      case 500:
        throw ReembolsoServiceException(
          'Erro interno do servidor. Tente novamente mais tarde.',
          ReembolsoServiceErrorType.serverError,
        );

      default:
        throw ReembolsoServiceException(
          'Erro do servidor (${response.statusCode}): ${response.body}',
          ReembolsoServiceErrorType.serverError,
        );
    }
  }

  /// Extrai as solicitações do JSON de resposta
  List<Solicitacao> _extrairSolicitacoes(String responseBody) {
    try {
      final data = json.decode(responseBody) as Map<String, dynamic>;

      if (!data.containsKey('solicitacoes')) {
        throw ReembolsoServiceException(
          'Formato de resposta inválido: campo "solicitacoes" não encontrado.',
          ReembolsoServiceErrorType.dataError,
        );
      }

      final solicitacoesJson = data['solicitacoes'] as List<dynamic>;

      return solicitacoesJson
          .map((json) => Solicitacao.fromJson(json))
          .toList();
    } catch (e) {
      if (e is ReembolsoServiceException) rethrow;

      throw ReembolsoServiceException(
        'Erro ao processar dados recebidos: $e',
        ReembolsoServiceErrorType.dataError,
      );
    }
  }
}

/// Tipos de erro específicos do serviço de reembolso
enum ReembolsoServiceErrorType {
  networkError,
  serverError,
  authenticationError,
  authorizationError,
  dataError,
  unknown,
}

/// Exception customizada para erros do serviço de reembolso
class ReembolsoServiceException implements Exception {
  final String message;
  final ReembolsoServiceErrorType type;

  const ReembolsoServiceException(this.message, this.type);

  @override
  String toString() => 'ReembolsoServiceException: $message';

  /// Retorna uma mensagem amigável para o usuário baseada no tipo de erro
  String get userFriendlyMessage {
    switch (type) {
      case ReembolsoServiceErrorType.networkError:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';

      case ReembolsoServiceErrorType.serverError:
        return 'Servidor temporariamente indisponível. Tente novamente em alguns instantes.';

      case ReembolsoServiceErrorType.authenticationError:
        return 'Sessão expirada. Faça login novamente.';

      case ReembolsoServiceErrorType.authorizationError:
        return 'Você não tem permissão para acessar estes dados.';

      case ReembolsoServiceErrorType.dataError:
        return 'Erro nos dados. Entre em contato com o suporte se persistir.';

      case ReembolsoServiceErrorType.unknown:
        return 'Erro inesperado. Tente novamente ou entre em contato com o suporte.';
    }
  }

  /// Retorna se o erro permite retry (nova tentativa)
  bool get canRetry {
    switch (type) {
      case ReembolsoServiceErrorType.networkError:
      case ReembolsoServiceErrorType.serverError:
        return true;

      case ReembolsoServiceErrorType.authenticationError:
      case ReembolsoServiceErrorType.authorizationError:
      case ReembolsoServiceErrorType.dataError:
      case ReembolsoServiceErrorType.unknown:
        return false;
    }
  }
}
