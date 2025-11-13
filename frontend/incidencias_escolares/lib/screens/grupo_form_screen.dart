import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';

class GrupoFormScreen extends StatefulWidget {
  final Grupo? grupo;
  GrupoFormScreen({this.grupo});

  @override
  _GrupoFormScreenState createState() => _GrupoFormScreenState();
}

class _GrupoFormScreenState extends State<GrupoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _gradoController = TextEditingController();
  final _cicloController = TextEditingController();
  final _tutorController = TextEditingController();
  final _service = GrupoService();

  @override
  void initState() {
    super.initState();
    if (widget.grupo != null) {
      _descripcionController.text = widget.grupo!.descripcion;
      _gradoController.text = widget.grupo!.grado.toString();
      _cicloController.text = widget.grupo!.ciclo;
      _tutorController.text = widget.grupo!.idTutor.toString();
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Grupo(
        id: widget.grupo?.id ?? 0,
        descripcion: _descripcionController.text,
        grado: int.tryParse(_gradoController.text) ?? 0,
        ciclo: _cicloController.text,
        idTutor: int.tryParse(_tutorController.text) ?? 0,
      );
      if (widget.grupo == null) {
        await _service.crearGrupo(nuevo);
      } else {
        await _service.editarGrupo(nuevo);
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
          widget.grupo == null ? 'Nuevo Grupo' : 'Editar Grupo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _gradoController,
                decoration: InputDecoration(labelText: 'Grado'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cicloController,
                decoration: InputDecoration(labelText: 'Ciclo Escolar'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _tutorController,
                decoration: InputDecoration(labelText: 'ID del Tutor'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              SizedBox(height: 20),
              widget.grupo == null
                ? ElevatedButton(onPressed: _guardar, child: Text('Guardar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))
                : ElevatedButton(onPressed: _guardar, child: Text('Actualizar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
