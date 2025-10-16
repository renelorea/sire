import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  UsuarioFormScreen({this.usuario});

  @override
  _UsuarioFormScreenState createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apaternoController = TextEditingController();
  final _amaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  String _rol = 'Profesor';

  final _service = UsuarioService();

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nombreController.text = widget.usuario!.nombre;
      _apaternoController.text = widget.usuario!.apaterno;
      _amaternoController.text = widget.usuario!.amaterno;
      _correoController.text = widget.usuario!.correo;
      _contrasenaController.text = widget.usuario!.contrasena;
      _rol = widget.usuario!.rol;
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Usuario(
        id: widget.usuario?.id ?? 0,
        nombre: _nombreController.text,
        apaterno: _apaternoController.text,
        amaterno: _amaternoController.text,
        correo: _correoController.text,
        contrasena: _contrasenaController.text,
        rol: _rol,
      );
      await _service.crearUsuario(nuevo);
      Navigator.pop(context);
    }
  }

void _actualizarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Usuario(
        id: widget.usuario?.id ?? 0,
        nombre: _nombreController.text,
        apaterno: _apaternoController.text,
        amaterno: _amaternoController.text,
        correo: _correoController.text,
        contrasena: _contrasenaController.text,
        rol: _rol,
      );
      await _service.editUsuario(nuevo);
      Navigator.pop(context);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario')),
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
                controller: _apaternoController,
                decoration: InputDecoration(labelText: 'Apellido Paterno'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _amaternoController,
                decoration: InputDecoration(labelText: 'Apellido Materno'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _contrasenaController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                enabled: widget.usuario == null,
              ),
              DropdownButtonFormField<String>(
                value: _rol,
                items: ['Profesor', 'Administrador'].map((rol) {
                  return DropdownMenuItem(value: rol, child: Text(rol));
                }).toList(),
                onChanged: (value) => setState(() => _rol = value!),
                decoration: InputDecoration(labelText: 'Rol'),
              ),
              SizedBox(height: 20),
              widget.usuario == null
                ? ElevatedButton(
                    onPressed: _guardar,
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                : ElevatedButton(
                    onPressed: _actualizarUsuario,
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
