import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orcamento_model.dart';

class OrcamentoService {
  static const String baseUrl =
      'https://beneficiario-src.uniodontopoa.com.br:2083';

  Future<List<Orcamento>> getOrcamentosAprovados(String codigoUniodonto) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/OrcamentosAprovados?codigo_uniodonto=$codigoUniodonto',
        ),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc1NjM4ODU1OCwianRpIjoiNmMzOWMyZDUtNWMyOS00MmRhLWIzNzMtOTBiYzJjY2JmMTkzIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6eyJ1c2VybmFtZSI6ImJyeWFuLnNpbHZhIiwidGlwb19jaGF2ZSI6IklOVEVSTk8ifSwibmJmIjoxNzU2Mzg4NTU4LCJjc3JmIjoiMDk1ZWNmYmYtNTA5YS00YTEzLThlODUtZDUyM2FiODJjN2RmIiwiZXhwIjoxNzcxOTQwNTU4fQ.jehRofpJBtojiW6aIO_Cx1nMPUG3pWFE9s3udq8WJXU', // Você precisará implementar a lógica de autenticação
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> orcamentosData = data['orcamentos'];

        return orcamentosData.map((json) => Orcamento.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // Nenhum orçamento encontrado
      } else {
        throw Exception('Falha ao carregar orçamentos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
