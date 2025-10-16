import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _service = UsuarioService();
  late Future<List<Usuario>> _usuarios;

  @override
  void initState() {
    super.initState();
    _usuarios = _service.obtenerUsuarios();
  }

  void _refrescar() {
    setState(() {
      _usuarios = _service.obtenerUsuarios();
    });
  }

  void _eliminar(int id) async {
    await _service.eliminarUsuario(id);
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios')),
      body: FutureBuilder<List<Usuario>>(
        future: _usuarios,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final usuarios = snapshot.data!;
            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];
                return ListTile(
                  title: Text(u.nombre),
                  subtitle: Text('${u.correo} • ${u.rol}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UsuarioFormScreen(usuario: u),
                          ),
                        ).then((_) => _refrescar());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(u.id)),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar usuarios'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UsuarioFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green[600],
      ),
    );
  }
}
