import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../services/reporte_service.dart';
import 'reporte_form_screen.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _service = ReporteService();
  late Future<List<Reporte>> _reportes;

  @override
  void initState() {
    super.initState();
    _reportes = _service.obtenerReportes();
  }

  void _refrescar() => setState(() => _reportes = _service.obtenerReportes());

  void _eliminar(int id) async {
    await _service.eliminarReporte(id);
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reportes')),
      body: FutureBuilder<List<Reporte>>(
        future: _reportes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reportes = snapshot.data!;
            return ListView.builder(
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final r = reportes[index];
                return ListTile(
                  title: Text(r.titulo),
                  subtitle: Text('Fecha: ${r.fecha}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReporteFormScreen(reporte: r),
                          ),
                        ).then((_) => _refrescar());
                      }),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(r.id)),
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
            MaterialPageRoute(builder: (_) => ReporteFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
