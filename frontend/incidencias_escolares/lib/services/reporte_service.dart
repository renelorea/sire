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

  // 👇 Log para ver el contenido crudo
  print('📦 Datos recibidos del backend:');
  for (var item in data) {
    print(item); // Puedes usar jsonEncode(item) si quieres verlo como string
  }

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

   Future<dynamic> consultar({
    String? grupo,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? email,
  }) async {
    final params = <String, String>{};
    if (grupo != null && grupo.isNotEmpty) params['grupo'] = grupo;
    if (nombre != null && nombre.isNotEmpty) params['nombre'] = nombre;
    if (apellidoPaterno != null && apellidoPaterno.isNotEmpty) params['apellido_paterno'] = apellidoPaterno;
    if (apellidoMaterno != null && apellidoMaterno.isNotEmpty) params['apellido_materno'] = apellidoMaterno;
    if (email != null && email.isNotEmpty) params['email'] = email;

    final uri = Uri.parse('$apiBaseUrl/reportes/reporte').replace(queryParameters: params.isEmpty ? null : params);

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jwtToken != null && jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }

    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final decoded = json.decode(resp.body);
      return decoded;
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado (401). Requiere login.');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}
