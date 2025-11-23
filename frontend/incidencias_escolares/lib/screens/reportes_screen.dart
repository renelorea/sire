import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../models/alumno.dart';
import '../models/tipo_reporte.dart';
import '../services/reporte_service.dart';
import '../services/alumno_service.dart';
import '../services/tipo_reporte_service.dart';
import 'reporte_form_screen.dart'; // Asegúrate de tener esta pantalla creada
import 'reporte_detail_screen.dart'; // <-- agregado

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _service = ReporteService();
  Future<List<Reporte>> _reportes = Future.value([]);
  List<Reporte> _todos = [];

  List<Alumno> _alumnos = []; // lista completa
  List<Alumno> _alumnosFiltrados = []; // lista para el dropdown (filtrada por búsqueda)
  List<TipoReporte> _tipos = [];
  final List<String> _estatuses = ['Abierto', 'En Seguimiento', 'Cerrado'];

  Alumno? _filtroAlumno;
  TipoReporte? _filtroTipo;
  String? _filtroEstatus;

  final TextEditingController _alumnoBusquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _alumnoBusquedaCtrl.addListener(_aplicarFiltroAlumnos);
  }

  Future<void> _cargarDatos() async {
    final reportes = await _service.obtenerReportes();
    final alumnos = await AlumnoService().obtenerAlumnos();
    final tipos = await TipoReporteService().obtenerTipos();

    setState(() {
      _todos = reportes;
      _reportes = Future.value(reportes);
      _alumnos = alumnos;
      _alumnosFiltrados = List.from(alumnos);
      _tipos = tipos;
    });

    // 👇 Log para verificar contenido
    print('📋 Reportes cargados:');
    for (var r in reportes) {
      print('Folio: ${r.folio}, Alumno: ${r.alumno.id} ${r.alumno.nombre} ${r.alumno.apaterno}, Tipo: ${r.tipoReporte.id} ${r.tipoReporte.nombre}, Estatus: ${r.estatus}');
    }
  }

  void _aplicarFiltroAlumnos() {
    final q = _alumnoBusquedaCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _alumnosFiltrados = List.from(_alumnos);
      } else {
        _alumnosFiltrados = _alumnos.where((a) {
          final full = '${a.nombre} ${a.apaterno} ${a.amaterno} ${a.matricula}'.toLowerCase();
          return full.contains(q);
        }).toList();
      }
      // si la selección actual no está en la lista filtrada, resetear para evitar error en Dropdown
      if (_filtroAlumno != null) {
        final existe = _alumnosFiltrados.any((a) => a.id == _filtroAlumno!.id);
        if (!existe) _filtroAlumno = null;
      }
    });
  }

  void _filtrar() {
    final idAlumno = _filtroAlumno?.id;
    final idTipo = _filtroTipo?.id;
    final estatus = _filtroEstatus;

    final filtrados = _todos.where((r) {
      final coincideAlumno = idAlumno == null || r.alumno.id == idAlumno;
      final coincideTipo = idTipo == null || r.tipoReporte.id == idTipo;
      final coincideEstatus = estatus == null || r.estatus == estatus;

      return coincideAlumno && coincideTipo && coincideEstatus;
    }).toList();

    setState(() {
      _reportes = Future.value(filtrados);
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroAlumno = null;
      _filtroTipo = null;
      _filtroEstatus = null;
      _alumnoBusquedaCtrl.clear();
      _alumnosFiltrados = List.from(_alumnos);
      _reportes = Future.value(_todos);
    });
  }

  @override
  void dispose() {
    _alumnoBusquedaCtrl.removeListener(_aplicarFiltroAlumnos);
    _alumnoBusquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // asegura que la flecha de retorno (íconos del AppBar) sea blanca
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
        title: Text('Reportes de Incidencia', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Campo de búsqueda para alumnos (nuevo)
                TextField(
                  controller: _alumnoBusquedaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar alumno',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<Alumno>(
                  value: _filtroAlumno,
                  decoration: InputDecoration(labelText: 'Filtrar por alumno'),
                  items: _alumnosFiltrados.map((a) {
                    return DropdownMenuItem(
                      value: a,
                      child: Text('${a.nombre} ${a.apaterno}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroAlumno = value);
                    _filtrar();
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TipoReporte>(
                  value: _filtroTipo,
                  decoration: InputDecoration(labelText: 'Filtrar por tipo de reporte'),
                  items: _tipos.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroTipo = value);
                    _filtrar();
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _filtroEstatus,
                  decoration: InputDecoration(labelText: 'Filtrar por estatus'),
                  items: _estatuses.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtroEstatus = value);
                    _filtrar();
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _limpiarFiltros,
                  child: Text('Restablecer filtros'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reporte>>(
              future: _reportes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los reportes'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay reportes registrados'));
                }

                final reportes = snapshot.data!;
                return ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final r = reportes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('Folio: ${r.folio}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alumno: ${r.alumno.nombre} ${r.alumno.apaterno}'),
                            Text('Tipo: ${r.tipoReporte.nombre} (${r.tipoReporte.gravedad})'),
                            Text('Fecha: ${r.fechaIncidencia.split(' ')[0]}'),
                            Text('Estatus: ${r.estatus}'),
                          ],
                        ),
                        isThreeLine: true,
                        // <-- agregado: botón/acción para ver detalle
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward),
                          tooltip: 'Ver detalle',
                          onPressed: () async {
                            final actualizado = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ReporteDetailScreen(reporte: r)),
                            );
                            if (actualizado == true) {
                              await _cargarDatos();
                            }
                          },
                        ),
                        onTap: () async {
                          final actualizado = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReporteDetailScreen(reporte: r)),
                          );
                          if (actualizado == true) {
                            await _cargarDatos();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final creado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReporteFormScreen()),
          );
          if (creado == true) {
            await _cargarDatos();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        tooltip: 'Crear nuevo reporte',
      ),
    );
  }
}
