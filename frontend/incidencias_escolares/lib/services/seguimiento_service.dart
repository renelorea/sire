import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seguimiento.dart';

class SeguimientoService {
  // Ajusta esta URL al backend real
  final String baseUrl = 'http://localhost:3000/api';

  Future<bool> crearSeguimiento(Seguimiento s, {String? nuevoEstatusReporte}) async {
    final url = Uri.parse('$baseUrl/seguimientos');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(s.toJson()),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Si se solicita, actualizar también el estatus del reporte
      if (nuevoEstatusReporte != null) {
        final actualizarOk = await _actualizarEstatusReporte(s.idReporte, nuevoEstatusReporte);
        return actualizarOk;
      }
      return true;
    } else {
      print('Error al crear seguimiento: ${resp.statusCode} ${resp.body}');
      return false;
    }
  }

  Future<bool> _actualizarEstatusReporte(int idReporte, String estatus) async {
    final url = Uri.parse('$baseUrl/reportes/$idReporte/estatus');
    final resp = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estatus': estatus}),
    );
    if (resp.statusCode == 200) return true;
    print('Error al actualizar estatus reporte: ${resp.statusCode} ${resp.body}');
    return false;
  }
}