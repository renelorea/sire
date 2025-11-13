import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/alumno.dart';


class AlumnoService {
  Future<List<Alumno>> obtenerAlumnos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/alumnos'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Alumno.fromJson(e)).toList();
  }

  Future<void> crearAlumno(Alumno a) async {
    final resp = await http.post(
      Uri.parse('$apiBaseUrl/alumnos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(a.toJson()),
    );
  }

// ...existing code...
Future<void> editarAlumno(Alumno a) async {
  final payload = a.toJson();
  developer.log('editarAlumno - payload: ${jsonEncode(payload)}', name: 'AlumnoService');
  try {
    final resp = await http.put(
      Uri.parse('$apiBaseUrl/alumnos/${a.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    developer.log('editarAlumno - status: ${resp.statusCode} - body: ${resp.body}', name: 'AlumnoService');
  } catch (e, st) {
    developer.log('editarAlumno - exception: $e', name: 'AlumnoService', error: e, stackTrace: st);
    // opcional: lanzar excepción para manejar en UI
    rethrow;
  }
}

  Future<void> eliminarAlumno(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/alumnos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
