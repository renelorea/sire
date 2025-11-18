import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/menu_principal_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/alumnos_screen.dart';
import 'screens/grupos_screen.dart';
import 'screens/tipos_reporte_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/reporte_incidencias_screen.dart';
import 'config/global.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appBusy,
      builder: (context, busy, _) {
        return MaterialApp(
          title: 'Incidencias Escolares',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                if (busy)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Procesando...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          home: LoginScreen(),
          // Opcional: rutas nombradas para navegación global
          routes: {
            '/login': (_) => LoginScreen(),
            '/menu': (_) => MenuPrincipalScreen(),
            '/alumnos': (_) => AlumnosScreen(),
            '/usuarios': (_) => UsuariosScreen(),
            '/grupos': (_) => GruposScreen(),
            '/tipos-reporte': (_) => TiposReporteScreen(),
            '/tipos_reporte': (_) => TiposReporteScreen(), // alias para llamadas con guion_bajo
            '/reportes': (_) => ReportesScreen(),
            '/reporte_incidencias': (context) => const ReporteIncidenciasScreen(),
          },
        );
      },
    );
  }
}
