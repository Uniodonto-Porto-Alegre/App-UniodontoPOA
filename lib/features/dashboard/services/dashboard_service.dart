// services/dashboard_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

class DashboardService {
  // URL base da API de beneficiário
  static const String _baseUrl =
      "https://beneficiario-src.uniodontopoa.com.br:2083/usuCatNumero";

  /// Carrega os dados do usuário ao iniciar o dashboard.
  ///
  /// 1. Pega o CPF salvo no SharedPreferences.
  /// 2. Formata o CPF removendo pontos e traços.
  /// 3. Faz uma requisição à API com o CPF formatado.
  /// 4. Salva o JSON de resposta no SharedPreferences.
  static Future<void> loadDashboardData() async {
    try {
      // Passo 1: Obter instância do SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Passo 2: Pegar o CPF armazenado
      final String? storedCpf = prefs.getString('user_cpf');

      if (storedCpf == null || storedCpf.isEmpty) {
        log('CPF do usuário não encontrado no SharedPreferences.');
        throw Exception('CPF do usuário não encontrado.');
      }

      // Passo 3: Remover pontos e traço do CPF
      final String formattedCpf = storedCpf.replaceAll(RegExp(r'[.-]'), '');
      log('CPF formatado para a API: $formattedCpf');

      const String token =
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc0NDgxMjMwMSwianRpIjoiZDYzODA3ZWEtOTUwNC00ZWQ0LWE2ODUtOTE3NjNlY2UwYTU2IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6InRpIiwidGlwb19jaGF2ZSI6IklOVEVSTk8ifSwibmJmIjoxNzQ0ODEyMzAxLCJjc3JmIjoiZWFkMjVlYWEtMzY0Zi00NTU5LWE4ZWItZjE3NjljMjI3YjRjIiwiZXhwIjoxNzYwMzY0MzAxfQ.JEml0IwbJf2yNAmEZT8bl3mbTA4ZrqSMzC3FTkJ4NgE';

      // Passo 4: Fazer a consulta na API
      final uri = Uri.parse('$_baseUrl?cpf=$formattedCpf');
      log('Consultando a URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Passo 5: Salvar o conteúdo retornado ou lançar erro
      if (response.statusCode == 200) {
        log('API retornou sucesso. Salvando dados do beneficiário.');
        await prefs.setString('beneficiario_data', response.body);
        log('Dados do beneficiário salvos com sucesso!');
      } else if (response.statusCode == 404) {
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody['error'] == 'Titular ou dependente não encontrado') {
            log(
              'Erro específico da API: Titular ou dependente não encontrado.',
            );
            throw Exception('Titular ou dependente não encontrado');
          }
        } catch (e) {
          // Se o corpo da resposta não for um JSON válido ou não tiver a chave 'error'
          log('Erro na API com status 404 e corpo inesperado.');
        }
        throw Exception('Falha na API com status ${response.statusCode}');
      } else {
        log(
          'Falha na API. Status: ${response.statusCode}, Corpo: ${response.body}',
        );
        throw Exception('Falha na API com status ${response.statusCode}');
      }
    } catch (e) {
      log('Ocorreu um erro ao carregar os dados do dashboard: $e');
      // Relança o erro para ser tratado pela UI
      rethrow;
    }
  }
}
