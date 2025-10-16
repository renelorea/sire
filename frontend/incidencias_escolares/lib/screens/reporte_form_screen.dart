import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../services/reporte_service.dart';

class ReporteFormScreen extends StatefulWidget {
  final Reporte? reporte;
  ReporteFormScreen({this.reporte});

  @override
  _ReporteFormScreenState createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaController = TextEditingController();
  final _alumnoIdController = TextEditingController();
  final _grupoIdController = TextEditingController();
  final _tipoIdController = TextEditingController();
  final _service = ReporteService();

  @override
  void initState() {
    super.initState();
    if (widget.reporte != null) {
      _tituloController.text = widget.reporte!.titulo;
      _descripcionController.text = widget.reporte!.descripcion;
      _fechaController.text = widget.reporte!.fecha;
      _alumnoIdController.text = widget.reporte!.alumnoId.toString();
      _grupoIdController.text = widget.reporte!.grupoId.toString();
      _tipoIdController.text = widget.reporte!.tipoReporteId.toString();
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Reporte(
        id: widget.reporte?.id ?? 0,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        fecha: _fechaController.text,
        alumnoId: int.tryParse(_alumnoIdController.text) ?? 0,
        grupoId: int.tryParse(_grupoIdController.text) ?? 0,
        tipoReporteId: int.tryParse(_tipoIdController.text) ?? 0,
      );
      if (widget.reporte == null) {
        await _service.crearReporte(nuevo);
      } else {
        await _service.editarReporte(nuevo);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reporte == null ? 'Nuevo Reporte' : 'Editar Reporte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _alumnoIdController,
                decoration: InputDecoration(labelText: 'ID del Alumno'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _grupoIdController,
                decoration: InputDecoration(labelText: 'ID del Grupo'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _tipoIdController,
                decoration: InputDecoration(labelText: 'ID del Tipo de Reporte'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              widget.reporte == null
                  ? ElevatedButton(
                      onPressed: _guardar,
                      child: Text('Guardar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    )
                  : ElevatedButton(
                      onPressed: _guardar,
                      child: Text('Actualizar'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
