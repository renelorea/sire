import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/grupo.dart';

class GrupoService {
  Future<List<Grupo>> obtenerGrupos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/grupos'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Grupo.fromJson(e)).toList();
  }

  Future<void> crearGrupo(Grupo grupo) async {
    await http.post(
      Uri.parse('$apiBaseUrl/grupos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(grupo.toJson()),
    );
  }

  Future<void> editarGrupo(Grupo grupo) async {
    await http.put(
      Uri.parse('$apiBaseUrl/grupos/${grupo.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(grupo.toJson()),
    );
  }

  Future<void> eliminarGrupo(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/grupos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
