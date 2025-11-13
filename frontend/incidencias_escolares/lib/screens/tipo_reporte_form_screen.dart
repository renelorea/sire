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

  String _gravedadSeleccionada = 'Leve';
  final List<String> _gravedades = ['Leve', 'Moderada', 'Grave'];

  @override
  void initState() {
    super.initState();
    if (widget.tipo != null) {
      _nombreController.text = widget.tipo!.nombre;
      _descripcionController.text = widget.tipo!.descripcion;
      _gravedadSeleccionada = widget.tipo!.gravedad ?? 'Leve';
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = TipoReporte(
        id: widget.tipo?.id ?? 0,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        gravedad: _gravedadSeleccionada,
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
        title: Text(
          widget.tipo == null ? 'Nuevo Tipo de Incidencia' : 'Editar Tipo de Incidencia',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
              DropdownButtonFormField<String>(
                value: _gravedadSeleccionada,
                decoration: InputDecoration(labelText: 'Gravedad'),
                items: _gravedades.map((nivel) {
                  return DropdownMenuItem(
                    value: nivel,
                    child: Text(nivel),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gravedadSeleccionada = value!;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una gravedad' : null,
              ),
              SizedBox(height: 20),
              widget.tipo == null
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
