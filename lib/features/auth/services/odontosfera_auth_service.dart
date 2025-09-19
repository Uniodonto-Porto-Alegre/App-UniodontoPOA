import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OdontosferaAuthService {
  static const String _baseUrl =
      'https://api.odontosfera.com.br/mobilesaude/v1/366439/Login';
  static const String _tokenAcesso = '2EC005CD-E038-47A3-A8E6-730E2119DA75';

  static const Map<String, String> _headers = {
    'TokenAcesso': _tokenAcesso,
    'Content-Type': 'application/json',
  };

  /// Realiza login na API da Odontosfera
  /// Retorna OdontosferaLoginResult com o resultado da autenticação
  static Future<OdontosferaLoginResult> login(
    String username,
    String password,
  ) async {
    try {
      // Validação de entrada
      if (username.isEmpty || password.isEmpty) {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message: 'Usuário e senha são obrigatórios.',
        );
      }

      // Formata os dados conforme especificado (com < >)
      final body = {'login': '<$username>', 'senha': '<$password>'};

      debugPrint('Tentando login com usuário: $username');

      final response = await http
          .post(Uri.parse(_baseUrl), headers: _headers, body: json.encode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Tempo limite excedido',
                const Duration(seconds: 30),
              );
            },
          );

      debugPrint('Status da resposta: ${response.statusCode}');
      debugPrint('Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          // Verifica se a resposta contém dados válidos
          if (responseData != null && responseData is Map<String, dynamic>) {
            // Verifica se há beneficiários ou dados de usuário
            final beneficiarios = responseData['beneficiarios'] as List?;
            final usuarioLogado = responseData['usuarioLogado'] as Map?;

            if ((beneficiarios != null && beneficiarios.isNotEmpty) ||
                (usuarioLogado != null)) {
              return OdontosferaLoginResult(
                success: true,
                userData: responseData,
                message: 'Login realizado com sucesso',
              );
            } else {
              return OdontosferaLoginResult(
                success: false,
                userData: null,
                message: 'Dados de usuário não encontrados na resposta.',
              );
            }
          } else {
            return OdontosferaLoginResult(
              success: false,
              userData: null,
              message: 'Formato de resposta inválido do servidor.',
            );
          }
        } catch (e) {
          debugPrint('Erro ao processar JSON: $e');
          return OdontosferaLoginResult(
            success: false,
            userData: null,
            message: 'Erro ao processar resposta do servidor.',
          );
        }
      } else if (response.statusCode == 401) {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message: 'CPF ou senha incorretos. Verifique suas credenciais.',
        );
      } else if (response.statusCode == 400) {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message: 'Dados de login inválidos. Verifique os campos preenchidos.',
        );
      } else if (response.statusCode == 404) {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message: 'Serviço não encontrado. Tente novamente mais tarde.',
        );
      } else if (response.statusCode >= 500) {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message:
              'Erro no servidor (${response.statusCode}). Tente novamente em alguns minutos.',
        );
      } else {
        return OdontosferaLoginResult(
          success: false,
          userData: null,
          message: 'Erro inesperado (${response.statusCode}). Tente novamente.',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      return OdontosferaLoginResult(
        success: false,
        userData: null,
        message: 'Tempo limite excedido. Verifique sua conexão.',
      );
    } on SocketException catch (e) {
      debugPrint('Erro de conexão: $e');
      return OdontosferaLoginResult(
        success: false,
        userData: null,
        message: 'Sem conexão com a internet. Verifique sua rede.',
      );
    } on FormatException catch (e) {
      debugPrint('Erro de formato: $e');
      return OdontosferaLoginResult(
        success: false,
        userData: null,
        message: 'Erro na resposta do servidor.',
      );
    } catch (e) {
      debugPrint('Erro geral: $e');
      String errorMessage = 'Erro inesperado: $e';

      // Personaliza mensagens para erros conhecidos
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Servidor indisponível. Tente novamente mais tarde.';
      } else if (e.toString().contains('Connection timed out')) {
        errorMessage = 'Tempo limite da conexão excedido.';
      } else if (e.toString().contains('No route to host')) {
        errorMessage = 'Não foi possível conectar ao servidor.';
      }

      return OdontosferaLoginResult(
        success: false,
        userData: null,
        message: errorMessage,
      );
    }
  }
}

/// Classe que representa o resultado do login
class OdontosferaLoginResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String message;

  const OdontosferaLoginResult({
    required this.success,
    this.userData,
    required this.message,
  });

  /// Extrai dados básicos do usuário da resposta
  OdontosferaUserData? get userBasicData {
    if (!success || userData == null) return null;

    try {
      final usuarioLogado = userData!['usuarioLogado'] as Map<String, dynamic>?;
      final beneficiarios = userData!['beneficiarios'] as List<dynamic>?;

      // Prioriza dados dos beneficiários se disponíveis
      if (beneficiarios != null && beneficiarios.isNotEmpty) {
        final primeiroUsuario = beneficiarios[0] as Map<String, dynamic>;
        final dadosPessoais =
            primeiroUsuario['dadosPessoais'] as Map<String, dynamic>?;
        final dadosPlano =
            primeiroUsuario['dadosDoPlano'] as Map<String, dynamic>?;
        final contato = dadosPessoais?['contato'] as Map<String, dynamic>?;
        final tipoUsuario = dadosPlano?['tipoUsuario'] as Map<String, dynamic>?;

        return OdontosferaUserData(
          nome: _getString(dadosPessoais, 'nome'),
          cpf: _getString(dadosPessoais, 'cpf'),
          email: _getString(contato, 'email'),
          telefone: _getString(contato, 'telefoneCelular'),
          matricula: _getString(dadosPlano, 'matricula'),
          tipoUsuario: _getString(tipoUsuario, 'descricao'),
          planoDescricao: _getString(dadosPlano, 'descricao'),
        );
      }

      // Fallback para dados do usuário logado
      if (usuarioLogado != null) {
        final integracao = usuarioLogado['integracao'] as Map<String, dynamic>?;
        final contato = usuarioLogado['contato'] as Map<String, dynamic>?;

        return OdontosferaUserData(
          nome: _getString(integracao, 'nome'),
          cpf: _getString(integracao, 'cpf'),
          email: _getString(contato, 'email'),
          telefone: _getString(contato, 'telefoneCelular'),
          matricula: '',
          tipoUsuario: _getString(integracao, 'observacao'),
          planoDescricao: '',
        );
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao extrair dados do usuário: $e');
      return null;
    }
  }

  /// Helper para extrair string de forma segura
  static String _getString(Map<String, dynamic>? map, String key) {
    if (map == null) return '';
    final value = map[key];
    return value?.toString().trim() ?? '';
  }
}

/// Classe com dados básicos extraídos da resposta
class OdontosferaUserData {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String matricula;
  final String tipoUsuario;
  final String planoDescricao;

  const OdontosferaUserData({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.matricula,
    required this.tipoUsuario,
    required this.planoDescricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'telefone': telefone,
      'matricula': matricula,
      'tipoUsuario': tipoUsuario,
      'planoDescricao': planoDescricao,
    };
  }

  @override
  String toString() {
    return 'OdontosferaUserData(nome: $nome, cpf: $cpf, email: $email, matricula: $matricula)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OdontosferaUserData &&
        other.nome == nome &&
        other.cpf == cpf &&
        other.email == email &&
        other.telefone == telefone &&
        other.matricula == matricula &&
        other.tipoUsuario == tipoUsuario &&
        other.planoDescricao == planoDescricao;
  }

  @override
  int get hashCode {
    return Object.hash(
      nome,
      cpf,
      email,
      telefone,
      matricula,
      tipoUsuario,
      planoDescricao,
    );
  }
}
