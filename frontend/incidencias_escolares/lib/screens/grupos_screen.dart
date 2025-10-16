import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';
import 'grupo_form_screen.dart';

class GruposScreen extends StatefulWidget {
  @override
  _GruposScreenState createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  final _service = GrupoService();
  late Future<List<Grupo>> _grupos;

  @override
  void initState() {
    super.initState();
    _grupos = _service.obtenerGrupos();
  }

  void _refrescar() => setState(() => _grupos = _service.obtenerGrupos());

  void _eliminar(int id) async {
    await _service.eliminarGrupo(id);
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grupos')),
      body: FutureBuilder<List<Grupo>>(
        future: _grupos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final grupos = snapshot.data!;
            return ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, index) {
                final g = grupos[index];
                return ListTile(
                  title: Text('Grupo ${g.descripcion} - ${g.grado}°'),
                  subtitle: Text('Ciclo: ${g.ciclo} • Tutor ID: ${g.idTutor}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrupoFormScreen(grupo: g),
                          ),
                        ).then((_) => _refrescar());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(g.id)),
                    ],
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GrupoFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
