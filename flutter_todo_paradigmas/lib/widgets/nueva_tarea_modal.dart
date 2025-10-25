import 'package:flutter/material.dart';
import '../models/tarea.dart';

void mostrarModalNuevaTarea(
  BuildContext context,
  Function(Tarea) onAgregar,
) {
  final tituloCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String prioridad = 'Media';

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Agregar nueva tarea'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
          DropdownButton<String>(
            value: prioridad,
            items: ['Alta', 'Media', 'Baja']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => prioridad = v!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (tituloCtrl.text.isEmpty) return;
            final tarea = Tarea(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              titulo: tituloCtrl.text,
              descripcion: descCtrl.text,
              fechaCreacion: DateTime.now(),
              prioridad: prioridad,
            );
            onAgregar(tarea);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
