import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reporte.dart';
import '../models/seguimiento.dart';
import '../services/seguimiento_service.dart';

class ReporteDetailScreen extends StatefulWidget {
  final Reporte reporte;
  ReporteDetailScreen({required this.reporte});

  @override
  _ReporteDetailScreenState createState() => _ReporteDetailScreenState();
}

class _ReporteDetailScreenState extends State<ReporteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _responsableCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _evidenciaCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  String _estadoSeguimiento = 'pendiente';
  String _nuevoEstatusReporte = '';

  final _service = SeguimientoService();
  bool _guardando = false;

  final List<String> _estatusReporteOpciones = ['Abierto', 'En Seguimiento', 'Cerrado'];
  final List<String> _estadoSeguimientoOpciones = ['pendiente', 'en revision', 'solucionado'];

  @override
  void initState() {
    super.initState();
    _nuevoEstatusReporte = widget.reporte.estatus;
  }

  @override
  void dispose() {
    _responsableCtrl.dispose();
    _descripcionCtrl.dispose();
    _evidenciaCtrl.dispose();
    super.dispose();
  }

  int _getIdReporte() => widget.reporte.id;
  String _getDescripcion() => widget.reporte.descripcionHechos;
  String _getEstatus() => widget.reporte.estatus;
  String _getFolio() => widget.reporte.folio;

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'), // muestra el picker en español
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardarSeguimiento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final seg = Seguimiento(
      idReporte: _getIdReporte(),
      responsable: _responsableCtrl.text.trim(),
      fechaSeguimiento: '${_fecha.toIso8601String().split('T')[0]}',
      descripcion: _descripcionCtrl.text.trim(),
      evidenciaUrl: _evidenciaCtrl.text.trim().isEmpty ? null : _evidenciaCtrl.text.trim(),
      estado: _estadoSeguimiento,
      validado: 0,
    );

    final ok = await _service.crearSeguimiento(
      seg,
      nuevoEstatusReporte: _nuevoEstatusReporte == _getEstatus() ? null : _nuevoEstatusReporte,
    );

    setState(() => _guardando = false);

    if (ok) {
      // Mostrar diálogo de confirmación y luego cerrar pasando true
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seguimiento guardado'),
          content: const Text('El seguimiento se guardó correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      // Mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar seguimiento')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reporte;
    final fechaStr = DateFormat.yMMMMd('es').format(_fecha); // ejemplo: "20 de noviembre de 2025"

    return Scaffold(
      appBar: AppBar(
        // flecha de retorno en blanco
        iconTheme: IconThemeData(color: Colors.white),
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
        title: Text('Detalle - Folio: ${_getFolio()}', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text('Alumno: ${r.alumno.nombre} ${r.alumno.apaterno}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo: ${r.tipoReporte.nombre} (${r.tipoReporte.gravedad})'),
                    Text('Fecha: ${r.fechaIncidencia.split(' ')[0]}'),
                    Text('Estatus actual: ${_getEstatus()}'),
                    SizedBox(height: 8),
                    Text('Descripción:'),
                    Text(_getDescripcion(), style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Cambiar estatus del reporte', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _nuevoEstatusReporte.isNotEmpty ? _nuevoEstatusReporte : _getEstatus(),
              items: _estatusReporteOpciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _nuevoEstatusReporte = v ?? _nuevoEstatusReporte),
              decoration: InputDecoration(),
            ),
            Divider(height: 24),
            Text('Agregar seguimiento / evidencia', style: TextStyle(fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _responsableCtrl,
                    decoration: InputDecoration(labelText: 'Responsable'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa responsable' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descripcionCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: 'Descripción'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa descripción' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _evidenciaCtrl,
                    decoration: InputDecoration(labelText: 'URL de evidencia (opcional)'),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Fecha: $fechaStr'),
                      Spacer(),
                      TextButton(onPressed: _seleccionarFecha, child: Text('Seleccionar fecha')),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _estadoSeguimiento,
                    items: _estadoSeguimientoOpciones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _estadoSeguimiento = v ?? _estadoSeguimiento),
                    decoration: InputDecoration(labelText: 'Estado seguimiento'),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarSeguimiento,
                    icon: Icon(Icons.save),
                    label: Text(_guardando ? 'Guardando...' : 'Guardar seguimiento'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}