import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/reporte.dart';

class ReporteService {
  Future<List<Reporte>> obtenerReportes() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/reportes'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Reporte.fromJson(e)).toList();
  }

  Future<void> crearReporte(Reporte reporte) async {
    await http.post(
      Uri.parse('$apiBaseUrl/reportes'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reporte.toJson()),
    );
  }

  Future<void> editarReporte(Reporte reporte) async {
    await http.put(
      Uri.parse('$apiBaseUrl/reportes/${reporte.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reporte.toJson()),
    );
  }

  Future<void> eliminarReporte(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/reportes/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
