class TipoReporte {
  final int id;
  final String nombre;
  final String descripcion;

  TipoReporte({required this.id, required this.nombre, required this.descripcion});

  factory TipoReporte.fromJson(Map<String, dynamic> json) => TipoReporte(
    id: json['id'] ?? 0,
    nombre: json['nombre'] ?? '',
    descripcion: json['descripcion'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
  };
}
