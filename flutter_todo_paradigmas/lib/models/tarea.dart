// ================================================
// 🧱 Modelo orientado a objetos (Paradigma OO)
// ================================================
class Tarea {
  String id;
  String titulo;
  String descripcion;
  bool completada;
  DateTime fechaCreacion;
  DateTime? fechaLimite;
  String prioridad;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.completada = false,
    required this.fechaCreacion,
    this.fechaLimite,
    this.prioridad = 'Media',
  });

  // Convertir a Map para guardar en SharedPreferences
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'completada': completada,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaLimite': fechaLimite?.toIso8601String(),
        'prioridad': prioridad,
      };

  // Convertir desde Map (al leer del almacenamiento)
  factory Tarea.fromMap(Map<String, dynamic> map) => Tarea(
        id: map['id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        completada: map['completada'],
        fechaCreacion: DateTime.parse(map['fechaCreacion']),
        fechaLimite: map['fechaLimite'] != null
            ? DateTime.parse(map['fechaLimite'])
            : null,
        prioridad: map['prioridad'],
      );
}
