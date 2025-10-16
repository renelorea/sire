import 'package:flutter/material.dart';
import '../models/tipo_reporte.dart';
import '../services/tipo_reporte_service.dart';

class TipoReporteFormScreen extends StatefulWidget {
  final TipoReporte? tipo;
  TipoReporteFormScreen({this.tipo});

  @override
  _TipoReporteFormScreenState createState() => _TipoReporteFormScreenState();
}

class _TipoReporteFormScreenState extends State<TipoReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _service = TipoReporteService();

  @override
  void initState() {
    super.initState();
    if (widget.tipo != null) {
      _nombreController.text = widget.tipo!.nombre;
      _descripcionController.text = widget.tipo!.descripcion;
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = TipoReporte(
        id: widget.tipo?.id ?? 0,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
      );
      if (widget.tipo == null) {
        await _service.crearTipo(nuevo);
      } else {
        await _service.editarTipo(nuevo);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tipo == null ? 'Nuevo Tipo de Reporte' : 'Editar Tipo de Reporte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              widget.tipo == null
                ? ElevatedButton(onPressed: _guardar, child: Text('Guardar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))
                : ElevatedButton(onPressed: _guardar, child: Text('Actualizar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
