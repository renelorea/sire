import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/seguimiento.dart';

class SeguimientoService {
  Future<List<Seguimiento>> obtenerSeguimientos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Seguimiento.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener seguimientos');
    }
  }

  Future<Seguimiento> obtenerSeguimientoPorId(int id) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Seguimiento.fromJson(data);
    } else {
      throw Exception('Seguimiento no encontrado');
    }
  }

  Future<void> crearSeguimiento(Seguimiento seguimiento) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Error al crear seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> editarSeguimiento(Seguimiento seguimiento) async {
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/seguimientos/${seguimiento.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al editar seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> eliminarSeguimiento(int id) async {
    final resp = await http.delete(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al eliminar seguimiento: ${resp.statusCode} ${resp.body}');
    }
  }
}
