import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/menu_principal_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/alumnos_screen.dart';
import 'screens/grupos_screen.dart';
import 'screens/tipos_reporte_screen.dart';
import 'screens/reportes_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    primaryColor: Colors.green[700],
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incidencias Escolares',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/menu': (context) => MenuPrincipalScreen(),
        '/usuarios': (context) => UsuariosScreen(),
        '/alumnos': (context) => AlumnosScreen(),
        '/grupos': (context) => GruposScreen(),
        '/tipos_reporte': (context) => TiposReporteScreen(),
        '/reportes': (context) => ReportesScreen(),
      },
    );
  }
}
