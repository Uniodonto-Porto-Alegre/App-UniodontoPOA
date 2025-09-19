import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Tempo de conexão excedido'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      } else {
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
