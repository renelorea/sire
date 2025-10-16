import 'grupo.dart';

class Alumno {
  final int id;
  final String matricula;
  final String nombre;
  final String apaterno;
  final String amaterno;
  final String? fechaNacimiento;
  final Grupo grupo;

  Alumno({
    required this.id,
    required this.matricula,
    required this.nombre,
    required this.apaterno,
    required this.amaterno,
    required this.fechaNacimiento,
    required this.grupo,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) => Alumno(
    id: json['id_alumno'] ?? 0,
    matricula: json['matricula'] ?? '',
    nombre: json['nombres'] ?? '',
    apaterno: json['apellido_paterno'] ?? '',
    amaterno: json['apellido_materno'] ?? '',
    fechaNacimiento: json['fecha_nacimiento'],
    grupo: Grupo.fromJson(json['grupo'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id_alumno': id,
    'matricula': matricula,
    'nombres': nombre,
    'apellido_paterno': apaterno,
    'apellido_materno': amaterno,
    'fecha_nacimiento': fechaNacimiento,
    'id_grupo': grupo.id,
  };
}
