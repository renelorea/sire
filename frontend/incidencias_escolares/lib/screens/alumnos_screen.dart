import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/alumno.dart';
import '../services/alumno_service.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';
import 'alumno_form_screen.dart';
import 'import_alumnos_screen.dart';
import '../config/api_config.dart';
import '../config/global.dart';

class AlumnosScreen extends StatefulWidget {
  @override
  _AlumnosScreenState createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  final _service = AlumnoService();
  late Future<List<Alumno>> _alumnos;
  List<Alumno> _todos = [];

  final _grupoService = GrupoService();
  List<Grupo> _grupos = [];
  Grupo? _filtroGrupo;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    try {
      final g = await _grupoService.obtenerGrupos();
      setState(() {
        _grupos = g;
      });
    } catch (e) {
      // opcional: manejar error
    }
  }

  Future<void> _cargarAlumnos() async {
    final lista = await _service.obtenerAlumnos();
    setState(() {
      _todos = lista;
      _aplicarFiltro(); // inicializa _alumnos acorde al filtro actual
    });
  }

  void _aplicarFiltro() {
    if (_filtroGrupo == null) {
      _alumnos = Future.value(_todos);
    } else {
      final filtrados = _todos.where((a) => a.grupo?.id == _filtroGrupo!.id).toList();
      _alumnos = Future.value(filtrados);
    }
  }

  Future<void> _pickAndUploadExcel() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true, // importante para web => file.bytes estará disponible
    );
    if (res == null) return;

    final file = res.files.single;

    // marcar busy global y estado local de upload (icono)
    setBusy(true);
    setState(() {
      _uploading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subiendo ${file.name}...')));

    try {
      final uri = Uri.parse('$apiBaseUrl/importar-alumnos');
      final request = http.MultipartRequest('POST', uri);
      if (jwtToken != null && jwtToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $jwtToken';
      }

      // determinar contentType por extensión
      String lower = file.name.toLowerCase();
      final contentType = lower.endsWith('.xls')
          ? MediaType('application', 'vnd.ms-excel')
          : MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');

      // En web file.path suele ser null -> preferir bytes cuando estén disponibles
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        developer.log('Subiendo desde bytes (web/desktop). name=${file.name} size=${file.size}', name: 'AlumnosScreen');
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: contentType,
        ));
      } else if (file.path != null && file.path!.isNotEmpty) {
        developer.log('Subiendo desde path: ${file.path}', name: 'AlumnosScreen');
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
          contentType: contentType,
        ));
      } else {
        throw Exception('No se pudo leer el archivo seleccionado (ni bytes ni path disponibles)');
      }

      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();
      developer.log('ImportarAlumnos response: ${streamed.statusCode} -> $respStr', name: 'AlumnosScreen');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Importación exitosa')));
        await _cargarAlumnos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error import: ${streamed.statusCode}')));
      }
    } catch (e, st) {
      developer.log('Error al subir Excel: $e', name: 'AlumnosScreen', error: e, stackTrace: st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    } finally {
      // quitar busy global y estado local
      setBusy(false);
      setState(() {
        _uploading = false;
      });
    }
  }

  void _refrescar() {
    _cargarAlumnos();
  }

  void _eliminar(int id) async {
    setBusy(true);
    try {
      await _service.eliminarAlumno(id);
      _cargarAlumnos();
    } finally {
      setBusy(false);
    }
  }

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
        title: Text('Alumnos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: _uploading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(Icons.file_upload),
            onPressed: _uploading ? null : _pickAndUploadExcel,
            tooltip: 'Importar Excel',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AlumnoFormScreen()));
              _refrescar();
            },
            tooltip: 'Nuevo alumno',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // filtros por grupo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Grupo?>(
                      value: _filtroGrupo,
                      decoration: InputDecoration(labelText: 'Filtrar por grupo'),
                      items: [
                        DropdownMenuItem<Grupo?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._grupos.map((g) => DropdownMenuItem<Grupo?>(
                          value: g,
                          child: Text('${g.descripcion} - ${g.grado}° (${g.ciclo})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroGrupo = value;
                          _aplicarFiltro();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filtroGrupo = null;
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
              child: FutureBuilder<List<Alumno>>(
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
                          subtitle: Text('Grupo: ${a.grupo?.descripcion ?? 'Sin grupo'} • Ciclo: ${a.grupo?.ciclo ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AlumnoFormScreen(alumno: a)),
                                  ).then((_) => _refrescar());
                                },
                              ),
                              IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(a.id ?? 0)),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
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
