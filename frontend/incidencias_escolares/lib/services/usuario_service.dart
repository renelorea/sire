import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/usuario.dart';

class UsuarioService {
  Future<List<Usuario>> obtenerUsuarios() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/usuarios'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    print('Respuesta API usuarios: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<void> crearUsuario(Usuario usuario) async {
    await http.post(
      Uri.parse('$apiBaseUrl/usuarios'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(usuario.toJson()),
    );
  }

  Future<void> editUsuario(Usuario usuario) async {
    await http.put(
      Uri.parse('$apiBaseUrl/usuarios/${usuario.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(usuario.toJson()),
    );
  }

  Future<void> eliminarUsuario(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/usuarios/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
