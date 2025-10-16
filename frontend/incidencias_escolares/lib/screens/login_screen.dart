import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';
import '../config/global.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _authService = AuthService();
  String? _error;

  void _login() async {
    final loginResponse = await _authService.login(
      _correoController.text,
      _contrasenaController.text,
    );

    if (loginResponse != null) {
      jwtToken = loginResponse.token;
      usuarioRol = loginResponse.usuario.rol;
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      setState(() => _error = 'Credenciales inválidas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Logo institucional
              Image.asset(
                'assets/images/logo.png', // Asegúrate de tener esta imagen en assets
                height: 120,
              ),
              SizedBox(height: 16),

              // 🏫 Nombre institucional
              Text(
                'Sistema de Incidencias Escolares',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 32),

              // 👤 Campo correo
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo institucional',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // 🔒 Campo contraseña
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),

              // ⚠️ Error visual
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 24),

              // 🔘 Botón de acceso
              ElevatedButton(
                onPressed: _login,
                child: Text('Ingresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
