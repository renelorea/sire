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
  List<Usuario> _todos = [];
  final List<String> _roles = ['Todos', 'Profesor', 'Administrador'];
  String _filtroRol = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final lista = await _service.obtenerUsuarios();
    setState(() {
      _todos = lista;
      _aplicarFiltro();
    });
  }

  void _aplicarFiltro() {
    final filtro = _filtroRol?.trim().toLowerCase();
    if (filtro == null || filtro == 'todos') {
      _usuarios = Future.value(_todos);
      return;
    }
    final filtrados = _todos.where((u) {
      final rolUsuario = (u.rol ?? '').trim().toLowerCase();
      return rolUsuario == filtro;
    }).toList();
    _usuarios = Future.value(filtrados);
  }

  void _refrescar() {
    _cargarUsuarios();
  }

  void _eliminar(int id) async {
    await _service.eliminarUsuario(id);
    _cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // flecha de regreso en blanco
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Usuarios', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroRol,
                    decoration: InputDecoration(labelText: 'Filtrar por rol'),
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filtroRol = value!;
                        _aplicarFiltro();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroRol = 'Todos';
                      _aplicarFiltro();
                    });
                  },
                  child: Text('Limpiar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
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
          ),
        ],
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
