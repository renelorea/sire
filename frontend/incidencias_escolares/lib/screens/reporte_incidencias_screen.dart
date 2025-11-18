import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../config/global.dart';
import '../services/reporte_service.dart';

class ReporteIncidenciasScreen extends StatefulWidget {
  const ReporteIncidenciasScreen({Key? key}) : super(key: key);

  @override
  State<ReporteIncidenciasScreen> createState() => _ReporteIncidenciasScreenState();
}

class _ReporteIncidenciasScreenState extends State<ReporteIncidenciasScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apPaternoCtrl = TextEditingController();
  final TextEditingController _apMaternoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _loading = false;
  List<dynamic> _resultados = [];

  List<Map<String, dynamic>> _grupos = [];
  Map<String, dynamic>? _grupoSeleccionado;

  final ReporteService _reporteService = ReporteService();

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    if (jwtToken == null) return;
    try {
      final uri = Uri.parse('$apiBaseUrl/grupos');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is List) {
          setState(() {
            _grupos = data.map((e) => e as Map<String, dynamic>).toList();
          });
        }
      } else {
        // no bloquear la pantalla si falla; mostrar mensaje breve
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando grupos (${resp.statusCode})')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando grupos: $e')));
    }
  }

  Future<void> _buscar({bool enviarEmail = false}) async {
    if (jwtToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final grupoId = _grupoSeleccionado != null
          ? (_grupoSeleccionado!['id_grupo'] ?? _grupoSeleccionado!['id'])?.toString()
          : null;

      final result = await _reporteService.consultar(
        grupo: grupoId,
        nombre: _nombreCtrl.text.isNotEmpty ? _nombreCtrl.text : null,
        apellidoPaterno: _apPaternoCtrl.text.isNotEmpty ? _apPaternoCtrl.text : null,
        apellidoMaterno: _apMaternoCtrl.text.isNotEmpty ? _apMaternoCtrl.text : null,
        email: enviarEmail && _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
      );

      if (enviarEmail && result is Map && result.containsKey('msg')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['msg'].toString())));
      } else if (result is List) {
        setState(() => _resultados = result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuesta inesperada del servidor')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildItem(dynamic r) {
    final alumno = r['alumno'] ?? {};
    final grupo = alumno['grupo'] ?? {};
    return ListTile(
      title: Text('${alumno['nombre'] ?? ''} ${alumno['apellido_paterno'] ?? ''} ${alumno['apellido_materno'] ?? ''}'),
      subtitle: Text('Folio: ${r['folio'] ?? ''}  ·  Grupo: ${grupo['grupo'] ?? grupo['id_grupo'] ?? ''}'),
      trailing: Text(r['estatus'] ?? ''),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Detalle reporte'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Folio: ${r['folio'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Fecha incidencia: ${r['fecha_incidencia'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Estatus: ${r['estatus'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Descripción: ${r['descripcion_hechos'] ?? ''}'),
                  const SizedBox(height: 6),
                  Text('Acciones: ${r['acciones_tomadas'] ?? ''}'),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apPaternoCtrl.dispose();
    _apMaternoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Envio de reportes', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Dropdown grupos
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _grupoSeleccionado,
            decoration: const InputDecoration(labelText: 'Grupo'),
            items: _grupos.map((g) {
              final label = g['Descripcion'] ?? g['grupo'] ?? g['nombre'] ?? 'Grupo ${g['id_grupo'] ?? g['id'] ?? ''}';
              return DropdownMenuItem<Map<String, dynamic>>(
                value: g,
                child: Text(label.toString()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _grupoSeleccionado = v),
            isExpanded: true,
          ),
          const SizedBox(height: 8),
          TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _apPaternoCtrl, decoration: const InputDecoration(labelText: 'Apellido paterno'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _apMaternoCtrl, decoration: const InputDecoration(labelText: 'Apellido materno'))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (para enviar Excel)')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Buscar'),
                  onPressed: _loading ? null : () => _buscar(enviarEmail: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Enviar por correo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_emailCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un email de destino')));
                            return;
                          }
                          _buscar(enviarEmail: true);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Expanded(
            child: _resultados.isEmpty
                ? const Center(child: Text('No hay resultados'))
                : ListView.separated(
                    itemCount: _resultados.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) => _buildItem(_resultados[i]),
                  ),
          ),
        ],
      ),
    );
  }
}