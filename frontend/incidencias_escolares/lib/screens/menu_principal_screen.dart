import 'package:flutter/material.dart';

class MenuPrincipalScreen extends StatelessWidget {
  final List<_OpcionMenu> opciones = [
    _OpcionMenu('Usuarios', Icons.person, '/usuarios'),
    _OpcionMenu('Alumnos', Icons.school, '/alumnos'),
    _OpcionMenu('Grupos', Icons.group, '/grupos'),
    _OpcionMenu('Tipos de Reporte', Icons.report, '/tipos_reporte'),
    _OpcionMenu('Reportes', Icons.assignment, '/reportes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: opciones.map((opcion) {
          return Card(
            color: Colors.grey[200],
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, opcion.ruta),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(opcion.icono, size: 48, color: Colors.green[700]),
                  SizedBox(height: 10),
                  Text(opcion.titulo, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OpcionMenu {
  final String titulo;
  final IconData icono;
  final String ruta;

  _OpcionMenu(this.titulo, this.icono, this.ruta);
}
