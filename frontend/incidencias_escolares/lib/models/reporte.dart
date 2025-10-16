class Reporte {
  final int id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final int alumnoId;
  final int grupoId;
  final int tipoReporteId;

  Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.alumnoId,
    required this.grupoId,
    required this.tipoReporteId,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
    id: json['id'] ?? 0,
    titulo: json['titulo'] ?? '',
    descripcion: json['descripcion'] ?? '',
    fecha: json['fecha'] ?? '',
    alumnoId: json['alumno_id'] ?? 0,
    grupoId: json['grupo_id'] ?? 0,
    tipoReporteId: json['tipo_reporte_id'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha,
    'alumno_id': alumnoId,
    'grupo_id': grupoId,
    'tipo_reporte_id': tipoReporteId,
  };
}
