import 'dart:convert';
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

  Future<void> crearAlumno(Alumno alumno) async {
    await http.post(
      Uri.parse('$apiBaseUrl/alumnos'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(alumno.toJson()),
    );
  }

  Future<void> editarAlumno(Alumno alumno) async {
    await http.put(
      Uri.parse('$apiBaseUrl/alumnos/${alumno.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(alumno.toJson()),
    );
  }

  Future<void> eliminarAlumno(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/alumnos/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
