import 'package:flutter/material.dart';
import '../models/tipo_reporte.dart';
import '../services/tipo_reporte_service.dart';
import 'tipo_reporte_form_screen.dart';

class TiposReporteScreen extends StatefulWidget {
  @override
  _TiposReporteScreenState createState() => _TiposReporteScreenState();
}

class _TiposReporteScreenState extends State<TiposReporteScreen> {
  final _service = TipoReporteService();
  late Future<List<TipoReporte>> _tipos;

  @override
  void initState() {
    super.initState();
    _tipos = _service.obtenerTipos();
  }

  void _refrescar() => setState(() => _tipos = _service.obtenerTipos());

  void _eliminar(int id) async {
    await _service.eliminarTipo(id);
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tipos de Reporte')),
      body: FutureBuilder<List<TipoReporte>>(
        future: _tipos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tipos = snapshot.data!;
            return ListView.builder(
              itemCount: tipos.length,
              itemBuilder: (context, index) {
                final t = tipos[index];
                return ListTile(
                  title: Text(t.nombre),
                  subtitle: Text(t.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TipoReporteFormScreen(tipo: t),
                          ),
                        ).then((_) => _refrescar());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(t.id)),
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
            MaterialPageRoute(builder: (_) => TipoReporteFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
