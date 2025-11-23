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
      try {
        await _service.crearUsuario(nuevo);

        // Mostrar diálogo de confirmación
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuario creado'),
            content: const Text('El usuario se creó correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el usuario: $e')),
        );
      }
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
      try {
        await _service.editUsuario(nuevo);

        // Mostrar diálogo de confirmación
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuario actualizado'),
            content: const Text('El usuario se actualizó correctamente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario',
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

class HomeScreen extends StatelessWidget {
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
        title: Text('Incidencias'),
      ),
      body: Center(
        child: Text('Bienvenido a la app de incidencias'),
      ),
    );
  }
}

class TiposReporteScreen extends StatelessWidget {
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
        title: Text('Tipos de Reporte'),
      ),
      body: Center(
        child: Text('Selecciona un tipo de reporte'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Incidencias',
    initialRoute: '/',
    routes: {
      '/': (context) => HomeScreen(), // ajusta según tu app
      '/tipos_reporte': (context) => TiposReporteScreen(),
      // otras rutas...
    },
  ));
}
