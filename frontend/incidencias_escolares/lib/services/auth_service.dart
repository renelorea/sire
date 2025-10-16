import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_response.dart';

class AuthService {
  Future<LoginResponse?> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contraseña': contrasena}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LoginResponse.fromJson(json);
    } else {
      return null;
    }
  }
}
