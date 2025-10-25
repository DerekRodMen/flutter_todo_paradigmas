import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TareaCard extends StatelessWidget {
  final Tarea tarea;
  final Function(String) onDelete;
  final Function(String) onToggle;

  const TareaCard({
    super.key,
    required this.tarea,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: tarea.completada,
          onChanged: (_) => onToggle(tarea.id),
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            decoration:
                tarea.completada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${tarea.descripcion}\nPrioridad: ${tarea.prioridad}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDelete(tarea.id),
        ),
      ),
    );
  }
}
   








   