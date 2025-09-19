import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static const String _baseUrl =
      'https://api.odontosfera.com.br/mobilesaude/v1/366439';
  static const String _tokenAcesso = '2EC005CD-E038-47A3-A8E6-730E2119DA75';

  // Modelo para resposta da primeira requisição
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'TokenAcesso': _tokenAcesso,
  };

  /// Primeira requisição - Recuperar identificação e dados do usuário
  static Future<RecuperarIdentificacaoResponse> recuperarIdentificacao({
    required String cpf,
    required String dataNascimento,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/RecuperarIdentificacaoSenha');

      final body = {'cpf': cpf, 'dataNascimento': dataNascimento};

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecuperarIdentificacaoResponse.fromJson(data);
      } else {
        throw ForgotPasswordException(
          'Erro ao recuperar identificação: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ForgotPasswordException) {
        rethrow;
      }
      throw ForgotPasswordException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Segunda requisição - Redefinir senha
  static Future<String> redefinirSenha({
    required String chaveUnica,
    required String novaSenha,
    required String confirmacao,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/RedefinirSenha');

      final body = {
        'chaveUnica': chaveUnica,
        'novaSenha': novaSenha,
        'confirmacao': confirmacao,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['mensagem'] ?? 'Senha alterada com sucesso!';
      } else {
        throw ForgotPasswordException(
          'Erro ao redefinir senha: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ForgotPasswordException) {
        rethrow;
      }
      throw ForgotPasswordException('Erro de conexão: ${e.toString()}');
    }
  }
}

// Modelos de dados
class RecuperarIdentificacaoResponse {
  final String chaveUnica;
  final IntegracaoData integracao;
  final List<ContatoData> contatos;
  final SegurancaData seguranca;

  RecuperarIdentificacaoResponse({
    required this.chaveUnica,
    required this.integracao,
    required this.contatos,
    required this.seguranca,
  });

  factory RecuperarIdentificacaoResponse.fromJson(Map<String, dynamic> json) {
    return RecuperarIdentificacaoResponse(
      chaveUnica: json['chaveUnica'] ?? '',
      integracao: IntegracaoData.fromJson(json['integracao'] ?? {}),
      contatos:
          (json['contatos'] as List?)
              ?.map((item) => ContatoData.fromJson(item))
              .toList() ??
          [],
      seguranca: SegurancaData.fromJson(json['seguranca'] ?? {}),
    );
  }
}

class IntegracaoData {
  final String nome;
  final String cpf;
  final String observacao;

  IntegracaoData({
    required this.nome,
    required this.cpf,
    required this.observacao,
  });

  factory IntegracaoData.fromJson(Map<String, dynamic> json) {
    return IntegracaoData(
      nome: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      observacao: json['observacao'] ?? '',
    );
  }
}

class ContatoData {
  final String id;
  final String contato;
  final int tipo;
  final String ofuscado;

  ContatoData({
    required this.id,
    required this.contato,
    required this.tipo,
    required this.ofuscado,
  });

  factory ContatoData.fromJson(Map<String, dynamic> json) {
    return ContatoData(
      id: json['id'] ?? '',
      contato: json['contato'] ?? '',
      tipo: json['tipo'] ?? 0,
      ofuscado: json['ofuscado'] ?? '',
    );
  }
}

class SegurancaData {
  final List<AuthData> auth;

  SegurancaData({required this.auth});

  factory SegurancaData.fromJson(Map<String, dynamic> json) {
    return SegurancaData(
      auth:
          (json['auth'] as List?)
              ?.map((item) => AuthData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AuthData {
  final String chave;
  final String token;
  final int expiracao;

  AuthData({required this.chave, required this.token, required this.expiracao});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      chave: json['chave'] ?? '',
      token: json['token'] ?? '',
      expiracao: json['expiracao'] ?? 0,
    );
  }
}

// Exceção personalizada
class ForgotPasswordException implements Exception {
  final String message;
  final int? statusCode;

  ForgotPasswordException(this.message, [this.statusCode]);

  @override
  String toString() => 'ForgotPasswordException: $message';
}
