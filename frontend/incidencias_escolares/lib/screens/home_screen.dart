import 'package:flutter/material.dart';
import '../models/usuario.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Text('Rol: ${usuario.rol}'),
      ),
    );
  }
}
