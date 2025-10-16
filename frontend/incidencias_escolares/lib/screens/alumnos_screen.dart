import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/alumno_service.dart';
import 'alumno_form_screen.dart';

class AlumnosScreen extends StatefulWidget {
  @override
  _AlumnosScreenState createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  final _service = AlumnoService();
  late Future<List<Alumno>> _alumnos;

  @override
  void initState() {
    super.initState();
    _alumnos = _service.obtenerAlumnos();
  }

  void _refrescar() async {
    final nuevos = await _service.obtenerAlumnos();
    setState(() {
      _alumnos = Future.value(nuevos);
    });
  }



  void _eliminar(int id) async {
    await _service.eliminarAlumno(id);
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alumnos')),
      body: FutureBuilder<List<Alumno>>(
        future: _alumnos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final alumnos = snapshot.data!;
            return ListView.builder(
              itemCount: alumnos.length,
              itemBuilder: (context, index) {
                final a = alumnos[index];
                return ListTile(
                  title: Text('${a.nombre} ${a.apaterno}'),
                  subtitle: Text('Grupo: ${a.grupo.descripcion} • Ciclo: ${a.grupo.ciclo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlumnoFormScreen(alumno: a),
                          ),
                        ).then((_) => _refrescar());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(a.id)),
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
            MaterialPageRoute(builder: (_) => AlumnoFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
