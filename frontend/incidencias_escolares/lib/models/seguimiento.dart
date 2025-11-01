class Seguimiento {
  int? idSeguimiento;
  int idReporte;
  String responsable;
  String fechaSeguimiento; // YYYY-MM-DD
  String descripcion;
  String? evidenciaUrl;
  String estado; // 'pendiente','en revision','solucionado'
  int validado; // 0 o 1

  Seguimiento({
    this.idSeguimiento,
    required this.idReporte,
    required this.responsable,
    required this.fechaSeguimiento,
    required this.descripcion,
    this.evidenciaUrl,
    this.estado = 'pendiente',
    this.validado = 0,
  });

  Map<String, dynamic> toJson() => {
        if (idSeguimiento != null) 'id_seguimiento': idSeguimiento,
        'id_reporte': idReporte,
        'responsable': responsable,
        'fecha_seguimiento': fechaSeguimiento,
        'descripcion': descripcion,
        'evidencia_url': evidenciaUrl,
        'estado': estado,
        'validado': validado,
      };

  factory Seguimiento.fromJson(Map<String, dynamic> json) => Seguimiento(
        idSeguimiento: json['id_seguimiento'],
        idReporte: json['id_reporte'],
        responsable: json['responsable'],
        fechaSeguimiento: json['fecha_seguimiento'],
        descripcion: json['descripcion'],
        evidenciaUrl: json['evidencia_url'],
        estado: json['estado'] ?? 'pendiente',
        validado: json['validado'] ?? 0,
      );
}
