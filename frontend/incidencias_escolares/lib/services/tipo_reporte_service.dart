import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import '../models/tipo_reporte.dart';

class TipoReporteService {
  Future<List<TipoReporte>> obtenerTipos() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/tipos-reporte'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => TipoReporte.fromJson(e)).toList();
  }

  Future<void> crearTipo(TipoReporte tipo) async {
    await http.post(
      Uri.parse('$apiBaseUrl/tipos-reporte'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tipo.toJson()),
    );
  }

  Future<void> editarTipo(TipoReporte tipo) async {
    await http.put(
      Uri.parse('$apiBaseUrl/tipos-reporte/${tipo.id}'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tipo.toJson()),
    );
  }

  Future<void> eliminarTipo(int id) async {
    await http.delete(
      Uri.parse('$apiBaseUrl/tipos-reporte/$id'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
  }
}
