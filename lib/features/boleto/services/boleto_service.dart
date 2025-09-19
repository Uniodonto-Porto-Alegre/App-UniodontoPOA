import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import '../models/beneficiario_model.dart';
import '../models/boleto_model.dart';

class BoletoService {
  static const String _baseUrl =
      'https://api.odontosfera.com.br/ConsultaContratante/v1';

  // O código da operadora deve ser ajustado conforme necessário.
  // Usando '366439' como exemplo, baseado na documentação.
  static const String _codOperadora = '366439';

  Future<Map<String, dynamic>> gerarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final beneficiarioDataString = prefs.getString('beneficiario_data');

    if (beneficiarioDataString == null) {
      developer.log(
        'Erro: beneficiario_data não encontrado no SharedPreferences.',
        name: 'BoletoService',
      );
      return {
        'Sucesso': false,
        'MsgRetorno': 'Dados do beneficiário não encontrados.',
      };
    }

    final beneficiarios = Beneficiario.fromJsonList(beneficiarioDataString);
    if (beneficiarios.isEmpty) {
      developer.log(
        'Erro: A lista de beneficiários está vazia.',
        name: 'BoletoService',
      );
      return {'Sucesso': false, 'MsgRetorno': 'Nenhum beneficiário na lista.'};
    }

    final titular = beneficiarios.first;
    final cpf = titular.cpf.replaceAll(RegExp(r'[^0-9]'), '');
    final celular = titular.telefone.replaceAll(RegExp(r'[^0-9]'), '');

    // Converte a data de DD/MM/AAAA para AAAA-MM-DD
    final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    final DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    final DateTime parsedDate = inputFormat.parse(titular.nascimento);
    final String dataNascimentoFormatada = outputFormat.format(parsedDate);

    final url = Uri.parse(
      '$_baseUrl/$_codOperadora/pf/$cpf/$dataNascimentoFormatada/$celular',
    );

    final headers = {
      'Content-Type': 'application/json',
      // O 'TokenAcesso' deve ser adicionado se for um token fixo para a API.
      'chaveAcesso': 'B039FE38-5802-43AA-A255-E1B8EED677DE',
    };

    developer.log(
      'Disparando requisição para gerar token...',
      name: 'BoletoService.gerarToken',
    );
    developer.log('URL: $url', name: 'BoletoService.gerarToken');
    developer.log('Headers: $headers', name: 'BoletoService.gerarToken');
    developer.log(
      'Celular do titular: $celular',
      name: 'BoletoService.gerarToken',
    );

    try {
      final response = await http.get(url, headers: headers);

      developer.log(
        'Resposta recebida. Status: ${response.statusCode}',
        name: 'BoletoService.gerarToken',
      );
      developer.log(
        'Corpo da Resposta: ${response.body}',
        name: 'BoletoService.gerarToken',
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'Sucesso': false,
          'MsgRetorno': 'Erro na requisição: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log(
        'Exceção ao chamar gerarToken: $e',
        name: 'BoletoService.gerarToken',
        error: e,
      );
      return {
        'Sucesso': false,
        'MsgRetorno': 'Erro ao conectar ao servidor: $e',
      };
    }
  }

  // Método auxiliar para obter o telefone do titular
  Future<String?> getTelefoneDoTitular() async {
    final prefs = await SharedPreferences.getInstance();
    final beneficiarioDataString = prefs.getString('beneficiario_data');

    if (beneficiarioDataString == null) return null;

    try {
      final beneficiarios = Beneficiario.fromJsonList(beneficiarioDataString);
      if (beneficiarios.isEmpty) return null;

      final titular = beneficiarios.first;
      return titular.telefone;
    } catch (e) {
      developer.log(
        'Erro ao obter telefone do titular: $e',
        name: 'BoletoService.getTelefoneDoTitular',
        error: e,
      );
      return null;
    }
  }

  Future<List<Boleto>> getBoletos(String chaveConsulta, String tokenSms) async {
    final url = Uri.parse(
      '$_baseUrl/$_codOperadora/ConsultaContaReceber/$chaveConsulta/$tokenSms',
    );

    final headers = {
      'Content-Type': 'application/json',
      'chaveAcesso': 'B039FE38-5802-43AA-A255-E1B8EED677DE',
    };

    developer.log(
      'Disparando requisição para buscar boletos...',
      name: 'BoletoService.getBoletos',
    );
    developer.log('URL: $url', name: 'BoletoService.getBoletos');
    developer.log('Headers: $headers', name: 'BoletoService.getBoletos');

    try {
      final response = await http.get(url, headers: headers);

      developer.log(
        'Resposta recebida. Status: ${response.statusCode}',
        name: 'BoletoService.getBoletos',
      );
      developer.log(
        'Corpo da Resposta: ${response.body}',
        name: 'BoletoService.getBoletos',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Sucesso'] == true && data['ObjContasReceber'] != null) {
          final List<dynamic> boletosJson = data['ObjContasReceber'];
          return boletosJson.map((json) => Boleto.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      developer.log(
        'Exceção ao chamar getBoletos: $e',
        name: 'BoletoService.getBoletos',
        error: e,
      );
      return [];
    }
  }

  Future<String?> getBoletoPdf(
    String chaveConsulta,
    String tokenSms,
    String idContaReceber,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/$_codOperadora/ConsultaBoleto/$chaveConsulta/$tokenSms/$idContaReceber',
    );

    final headers = {
      'Content-Type': 'application/json',
      'chaveAcesso': 'B039FE38-5802-43AA-A255-E1B8EED677DE',
    };

    developer.log(
      'Disparando requisição para buscar PDF do boleto...',
      name: 'BoletoService.getBoletoPdf',
    );
    developer.log('URL: $url', name: 'BoletoService.getBoletoPdf');
    developer.log('Headers: $headers', name: 'BoletoService.getBoletoPdf');

    try {
      final response = await http.get(url, headers: headers);

      developer.log(
        'Resposta recebida. Status: ${response.statusCode}',
        name: 'BoletoService.getBoletoPdf',
      );
      // Não vamos logar o corpo inteiro aqui pois pode ser muito grande (Base64)
      developer.log(
        'Corpo da Resposta (início): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        name: 'BoletoService.getBoletoPdf',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Sucesso'] == true) {
          return data['Base64PDFBoleto'];
        }
      }
      return null;
    } catch (e) {
      developer.log(
        'Exceção ao chamar getBoletoPdf: $e',
        name: 'BoletoService.getBoletoPdf',
        error: e,
      );
      return null;
    }
  }
}
