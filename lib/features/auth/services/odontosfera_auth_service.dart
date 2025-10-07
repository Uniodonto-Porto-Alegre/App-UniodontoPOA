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

  /// Realiza a validação de credenciais
  /// - Mobile: Chama a API real
  /// - Web/Chrome: Simula resposta para apresentação
  static Future<OdontosferaAuthResult> validateCredentials(
    String username,
    String password,
  ) async {
    // Validação de entrada
    if (username.isEmpty || password.isEmpty) {
      return const OdontosferaAuthResult(
        isValid: false,
        message: 'Usuário e senha são obrigatórios.',
      );
    }

    // Se estiver rodando no web (Chrome) para apresentação, simula login
    if (kIsWeb) {
      return _simulateWebLogin(username, password);
    }

    // Código original para mobile
    return _performMobileLogin(username, password);
  }

  /// Simula login para apresentação web
  static Future<OdontosferaAuthResult> _simulateWebLogin(
    String username,
    String password,
  ) async {
    debugPrint('🖥️ Executando no Chrome - Simulando login para apresentação');
    debugPrint('🔐 Validando credenciais para usuário: $username');

    // Simula delay da API
    await Future.delayed(const Duration(milliseconds: 800));

    // Simula alguns casos de teste
    if (username.toLowerCase() == 'demo' && password == 'demo123') {
      debugPrint('✅ Login demo realizado com sucesso');
      return const OdontosferaAuthResult(
        isValid: true,
        message: 'Login demo realizado com sucesso',
      );
    }

    // Para CPFs válidos (11 dígitos), aceita qualquer senha
    if (RegExp(
      r'^\d{11}$',
    ).hasMatch(username.replaceAll(RegExp(r'[.-]'), ''))) {
      debugPrint('✅ CPF válido - Login simulado com sucesso');
      return const OdontosferaAuthResult(
        isValid: true,
        message: 'Credenciais válidas (simulação)',
      );
    }

    // Para qualquer outro usuário com senha "123456", aceita
    if (password == '123456') {
      debugPrint('✅ Senha padrão aceita - Login simulado');
      return const OdontosferaAuthResult(
        isValid: true,
        message: 'Login realizado com sucesso (demonstração)',
      );
    }

    // Simula erro de credenciais inválidas
    debugPrint('❌ Credenciais inválidas (simulação)');
    return const OdontosferaAuthResult(
      isValid: false,
      message:
          'CPF ou senha incorretos. Para demo, use: demo/demo123 ou qualquer CPF/123456',
    );
  }

  /// Login original para dispositivos mobile
  static Future<OdontosferaAuthResult> _performMobileLogin(
    String username,
    String password,
  ) async {
    try {
      // Formata os dados conforme especificado (com < >)
      final body = {'login': '<$username>', 'senha': '<$password>'};

      debugPrint('📱 Executando login mobile para usuário: $username');

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

      debugPrint('📡 Status da resposta: ${response.statusCode}');

      // FOCO APENAS NA VALIDAÇÃO DE CREDENCIAIS
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          // Verifica se a resposta tem estrutura básica válida
          if (responseData != null && responseData is Map<String, dynamic>) {
            final beneficiarios = responseData['beneficiarios'] as List?;
            final usuarioLogado = responseData['usuarioLogado'] as Map?;

            // Se tem estrutura de beneficiários ou usuário logado = credenciais válidas
            if ((beneficiarios != null) || (usuarioLogado != null)) {
              debugPrint('✅ Credenciais validadas com sucesso');

              return const OdontosferaAuthResult(
                isValid: true,
                message: 'Credenciais válidas',
              );
            } else {
              debugPrint('❌ Estrutura de resposta inválida');
              return const OdontosferaAuthResult(
                isValid: false,
                message: 'Resposta inválida do servidor de autenticação.',
              );
            }
          } else {
            debugPrint('❌ Resposta não é um objeto JSON válido');
            return const OdontosferaAuthResult(
              isValid: false,
              message: 'Formato de resposta inválido do servidor.',
            );
          }
        } catch (e) {
          debugPrint('❌ Erro ao processar resposta: $e');
          return const OdontosferaAuthResult(
            isValid: false,
            message: 'Erro ao processar resposta do servidor.',
          );
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Credenciais inválidas (401)');
        return const OdontosferaAuthResult(
          isValid: false,
          message: 'CPF ou senha incorretos. Verifique suas credenciais.',
        );
      } else if (response.statusCode == 400) {
        debugPrint('❌ Dados inválidos (400)');
        return const OdontosferaAuthResult(
          isValid: false,
          message: 'Dados de login inválidos. Verifique os campos preenchidos.',
        );
      } else if (response.statusCode == 404) {
        debugPrint('❌ Serviço não encontrado (404)');
        return const OdontosferaAuthResult(
          isValid: false,
          message: 'Serviço não encontrado. Tente novamente mais tarde.',
        );
      } else if (response.statusCode >= 500) {
        debugPrint('❌ Erro do servidor (${response.statusCode})');
        return OdontosferaAuthResult(
          isValid: false,
          message:
              'Erro no servidor (${response.statusCode}). Tente novamente em alguns minutos.',
        );
      } else {
        debugPrint('❌ Erro inesperado (${response.statusCode})');
        return OdontosferaAuthResult(
          isValid: false,
          message: 'Erro inesperado (${response.statusCode}). Tente novamente.',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout: $e');
      return const OdontosferaAuthResult(
        isValid: false,
        message: 'Tempo limite excedido. Verifique sua conexão.',
      );
    } on SocketException catch (e) {
      debugPrint('🌐 Erro de conexão: $e');
      return const OdontosferaAuthResult(
        isValid: false,
        message: 'Sem conexão com a internet. Verifique sua rede.',
      );
    } on FormatException catch (e) {
      debugPrint('📄 Erro de formato: $e');
      return const OdontosferaAuthResult(
        isValid: false,
        message: 'Erro na resposta do servidor.',
      );
    } catch (e) {
      debugPrint('💥 Erro geral: $e');
      String errorMessage = 'Erro inesperado: $e';

      // Personaliza mensagens para erros conhecidos
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Servidor indisponível. Tente novamente mais tarde.';
      } else if (e.toString().contains('Connection timed out')) {
        errorMessage = 'Tempo limite da conexão excedido.';
      } else if (e.toString().contains('No route to host')) {
        errorMessage = 'Não foi possível conectar ao servidor.';
      }

      return OdontosferaAuthResult(isValid: false, message: errorMessage);
    }
  }

  // MÉTODO LEGADO MANTIDO PARA COMPATIBILIDADE
  // Apenas chama o novo método de validação
  static Future<OdontosferaLoginResult> login(
    String username,
    String password,
  ) async {
    final authResult = await validateCredentials(username, password);

    return OdontosferaLoginResult(
      success: authResult.isValid,
      userData: null, // Não retorna dados do usuário
      message: authResult.message,
    );
  }
}

/// Classe simplificada que representa APENAS o resultado da autenticação
class OdontosferaAuthResult {
  final bool isValid;
  final String message;

  const OdontosferaAuthResult({required this.isValid, required this.message});

  @override
  String toString() {
    return 'OdontosferaAuthResult(isValid: $isValid, message: $message)';
  }
}

/// Classe mantida para compatibilidade com código existente
/// MAS NÃO EXTRAI MAIS DADOS DO USUÁRIO
class OdontosferaLoginResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String message;

  const OdontosferaLoginResult({
    required this.success,
    this.userData,
    required this.message,
  });

  /// REMOVIDO: Não extrai mais dados do usuário
  /// A coleta de dados será feita em outra tela após o login
  OdontosferaUserData? get userBasicData => null;
}

/// Classe mantida apenas para compatibilidade
/// Os dados reais serão coletados em outra tela
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
}
