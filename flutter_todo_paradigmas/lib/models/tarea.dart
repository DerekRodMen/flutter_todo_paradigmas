class Tarea {
  String id;
  String titulo;
  String descripcion;
  String encargado;
  DateTime fechaCreacion;
  DateTime fechaLimite;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.encargado = '',
    required this.fechaCreacion,
    required this.fechaLimite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'encargado': encargado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaLimite': fechaLimite.toIso8601String(),
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      encargado: map['encargado'] ?? '',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      fechaLimite: DateTime.parse(map['fechaLimite']),
    );
  }
}
