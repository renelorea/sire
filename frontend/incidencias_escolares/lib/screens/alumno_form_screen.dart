import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../models/grupo.dart';
import '../services/alumno_service.dart';
import '../services/grupo_service.dart';
import 'package:intl/intl.dart';

class AlumnoFormScreen extends StatefulWidget {
  final Alumno? alumno;
  AlumnoFormScreen({this.alumno});

  @override
  _AlumnoFormScreenState createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends State<AlumnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apaternoController = TextEditingController();
  final _amaternoController = TextEditingController();
  final _fechaController = TextEditingController();
  Grupo? _grupoSeleccionado;
  List<Grupo> _grupos = [];

  final _alumnoService = AlumnoService();
  final _grupoService = GrupoService();

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
  }

  void _inicializarFormulario() async {
    final lista = await _grupoService.obtenerGrupos();
    Grupo? grupoInicial;

    if (widget.alumno != null) {
      _matriculaController.text = widget.alumno!.matricula;
      _nombreController.text = widget.alumno!.nombre;
      _apaternoController.text = widget.alumno!.apaterno;
      _amaternoController.text = widget.alumno!.amaterno;
      _fechaController.text = widget.alumno!.fechaNacimiento ?? '';

      grupoInicial = lista.firstWhere(
        (g) => g.id == widget.alumno!.grupo.id,
        orElse: () => Grupo(
          id: 0,
          descripcion: 'Sin grupo',
          grado: 0,
          ciclo: '',
          idTutor: 0,
        ),
      );

    }

    setState(() {
      _grupos = lista;
      _grupoSeleccionado = grupoInicial;
    });
  }

  void _seleccionarFecha() async {
  final fecha = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1990),
    lastDate: DateTime(2100),
  );
  if (fecha != null) {
    final formato = DateFormat('yyyy-MM-dd');
    setState(() {
      _fechaController.text = formato.format(fecha);
    });
  }
}


  void _guardar() async {
    if (_formKey.currentState!.validate() && _grupoSeleccionado != null) {
      final nuevo = Alumno(
        id: widget.alumno?.id ?? 0,
        matricula: _matriculaController.text,
        nombre: _nombreController.text,
        apaterno: _apaternoController.text,
        amaterno: _amaternoController.text,
        fechaNacimiento: _fechaController.text,
        grupo: _grupoSeleccionado!,
      );

      if (widget.alumno == null) {
        await _alumnoService.crearAlumno(nuevo);
      } else {
        await _alumnoService.editarAlumno(nuevo);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.alumno == null ? 'Nuevo Alumno' : 'Editar Alumno')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matrícula'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apaternoController,
                decoration: InputDecoration(labelText: 'Apellido Paterno'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _amaternoController,
                decoration: InputDecoration(labelText: 'Apellido Materno'),
              ),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<Grupo>(
                value: _grupoSeleccionado,
                items: _grupos.map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text('${g.descripcion} • ${g.grado}° • ${g.ciclo}'),
                  );
                }).toList(),
                onChanged: (grupo) => setState(() => _grupoSeleccionado = grupo),
                decoration: InputDecoration(labelText: 'Grupo'),
                validator: (value) => value == null ? 'Selecciona un grupo' : null,
              ),
              SizedBox(height: 20),
              widget.alumno == null
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
