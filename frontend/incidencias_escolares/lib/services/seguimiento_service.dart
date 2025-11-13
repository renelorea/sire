import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart'; // <-- agregado para obtener jwtToken
import '../models/seguimiento.dart';

class SeguimientoService {
  // Ajusta esta URL al backend real
  
  Future<bool> crearSeguimiento(Seguimiento s, {String? nuevoEstatusReporte}) async {
    final url = Uri.parse('$apiBaseUrl/seguimientos');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
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
    final url = Uri.parse('$apiBaseUrl/reportes/$idReporte/estatus');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'estatus': estatus}),
    );
    if (resp.statusCode == 200) return true;
    print('Error al actualizar estatus reporte: ${resp.statusCode} ${resp.body}');
    return false;
  }
}