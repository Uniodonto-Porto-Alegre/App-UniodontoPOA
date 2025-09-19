import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  final http.Client client = http.Client();

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro HTTP ${response.statusCode}');
    }
  }
}
