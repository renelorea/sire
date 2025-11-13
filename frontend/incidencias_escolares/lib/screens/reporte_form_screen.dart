import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../models/usuario.dart';
import '../models/tipo_reporte.dart';
import '../models/reporte.dart';
import '../services/alumno_service.dart';
import '../services/usuario_service.dart';
import '../services/tipo_reporte_service.dart';
import '../services/reporte_service.dart';

class ReporteFormScreen extends StatefulWidget {
  final Reporte? reporte;
  ReporteFormScreen({this.reporte});

  @override
  _ReporteFormScreenState createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _accionesController = TextEditingController();
  DateTime? _fechaIncidencia;

  List<Alumno> _alumnos = [];
  List<Usuario> _usuarios = [];
  List<TipoReporte> _tipos = [];

  Alumno? _alumnoSeleccionado;
  Usuario? _usuarioSeleccionado;
  TipoReporte? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final alumnos = await AlumnoService().obtenerAlumnos();
    final usuarios = await UsuarioService().obtenerUsuarios();
    final tipos = await TipoReporteService().obtenerTipos();

    setState(() {
      _alumnos = alumnos;
      _usuarios = usuarios;
      _tipos = tipos;
    });
  }

  void _guardar() async {
    if (_formKey.currentState!.validate() &&
        _alumnoSeleccionado != null &&
        _usuarioSeleccionado != null &&
        _tipoSeleccionado != null &&
        _fechaIncidencia != null) {
      final nuevo = Reporte(
        id: 0,
        folio: '', // Se autogenera en backend
        descripcionHechos: _descripcionController.text,
        accionesTomadas: _accionesController.text,
        fechaIncidencia: _fechaIncidencia!.toIso8601String(),
        fechaCreacion: '', // Se autogenera en backend
        estatus: 'Abierto',
        alumno: _alumnoSeleccionado!,
        usuario: _usuarioSeleccionado!,
        tipoReporte: _tipoSeleccionado!,
      );

      await ReporteService().crearReporte(nuevo);
      Navigator.pop(context);
    }
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
        title: Text('Nuevo Reporte de Incidencia', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _alumnos.isEmpty || _usuarios.isEmpty || _tipos.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Alumno>(
                      value: _alumnoSeleccionado,
                      decoration: InputDecoration(labelText: 'Alumno'),
                      items: _alumnos.map((a) {
                        return DropdownMenuItem(
                          value: a,
                          child: Text('${a.nombre} ${a.apaterno} ${a.amaterno}'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _alumnoSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un alumno' : null,
                    ),
                    DropdownButtonFormField<Usuario>(
                      value: _usuarioSeleccionado,
                      decoration: InputDecoration(labelText: 'Usuario que reporta'),
                      items: _usuarios.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text('${u.nombre} ${u.apaterno} (${u.rol})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _usuarioSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un usuario' : null,
                    ),
                    DropdownButtonFormField<TipoReporte>(
                      value: _tipoSeleccionado,
                      decoration: InputDecoration(labelText: 'Tipo de reporte'),
                      items: _tipos.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text('${t.nombre} (${t.gravedad})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _tipoSeleccionado = value),
                      validator: (value) => value == null ? 'Selecciona un tipo' : null,
                    ),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(labelText: 'Descripción de los hechos'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: _accionesController,
                      decoration: InputDecoration(labelText: 'Acciones tomadas'),
                      maxLines: 2,
                    ),
                    ListTile(
                      title: Text(_fechaIncidencia == null
                          ? 'Selecciona fecha de incidencia'
                          : 'Fecha: ${_fechaIncidencia!.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (fecha != null) {
                          setState(() => _fechaIncidencia = fecha);
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: 'Abierto',
                      decoration: InputDecoration(labelText: 'Estatus'),
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: Text('Guardar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
