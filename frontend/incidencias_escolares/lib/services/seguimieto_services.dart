import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/seguimiento.dart';

class SeguimientoService {
  Future<List<SeguimientoEvidencia>> obtenerSeguimientos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SeguimientoEvidencia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener seguimientos');
    }
  }

  Future<SeguimientoEvidencia> obtenerSeguimientoPorId(int id) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SeguimientoEvidencia.fromJson(data);
    } else {
      throw Exception('Seguimiento no encontrado');
    }
  }

  Future<void> crearSeguimiento(SeguimientoEvidencia seguimiento) async {
    await http.post(
      Uri.parse('$apiBaseUrl/seguimientos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );
  }

  Future<void> editarSeguimiento(SeguimientoEvidencia seguimiento) async {
    await http.put(
      Uri.parse('$apiBaseUrl/seguimientos/${seguimiento.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(seguimiento.toJson()),
    );
  }

  Future<void> eliminarSeguimiento(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/seguimientos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
