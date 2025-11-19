import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart'; // <-- agregado para obtener jwtToken
import '../models/seguimiento.dart';
import '../utils/auth_utils.dart';

class SeguimientoService {
  // Ajusta esta URL al backend real

  Future<bool> crearSeguimiento(Seguimiento s, {String? nuevoEstatusReporte}) async {
    final url = Uri.parse('$apiBaseUrl/seguimientos');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(s.toJson()),
    );

    developer.log('crearSeguimiento - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Si se solicita, actualizar también el estatus del reporte
      if (nuevoEstatusReporte != null) {
        final actualizarOk = await _actualizarEstatusReporte(s.idReporte, nuevoEstatusReporte);
        return actualizarOk;
      }
      return true;
    } else if (resp.statusCode == 401) {
      throw UnauthorizedException('Token inválido o expirado');
    } else {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<bool> _actualizarEstatusReporte(int idReporte, String estatus) async {
    final url = Uri.parse('$apiBaseUrl/reportes/$idReporte/estatus');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'estatus': estatus}),
    );

    developer.log('actualizarEstatusReporte - status: ${resp.statusCode} - body: ${resp.body}', name: 'SeguimientoService');

    if (resp.statusCode == 200) return true;
    else if (resp.statusCode == 401) throw UnauthorizedException('Token inválido o expirado');
    else throw Exception('Error ${resp.statusCode}: ${resp.body}');
  }
}