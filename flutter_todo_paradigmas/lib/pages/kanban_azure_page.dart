import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tarea.dart';

class KanbanAzurePage extends StatefulWidget {
  const KanbanAzurePage({super.key});

  @override
  State<KanbanAzurePage> createState() => _KanbanAzurePageState();
}

class _KanbanAzurePageState extends State<KanbanAzurePage> {
  final List<String> estados = ['Por hacer', 'En progreso', 'En revisión', 'Terminado'];
  late Map<String, List<Tarea>> columnas;
  List<String> usuarios = [];
  late File dataFile;

  @override
  void initState() {
    super.initState();
    columnas = {
      'Por hacer': [],
      'En progreso': [],
      'En revisión': [],
      'Terminado': [],
    };
    inicializarArchivo();
  }

  // 📂 Inicializa archivo de datos
  Future<void> inicializarArchivo() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      dataFile = File('${dir.path}/kanban_data.json');

      if (await dataFile.exists()) {
        await cargarDesdeJson();
      } else {
        await dataFile.create(recursive: true);
        await guardarEnJson();
      }
    } catch (e) {
      debugPrint('❌ Error inicializando archivo: $e');
    }
  }

  // 🧾 Cargar datos desde JSON
  Future<void> cargarDesdeJson() async {
    try {
      final contenido = await dataFile.readAsString();
      if (contenido.isEmpty) return;

      final decoded = jsonDecode(contenido);
      setState(() {
        usuarios = List<String>.from(decoded['usuarios'] ?? []);
        final tareas = decoded['tareas'] as Map<String, dynamic>;
        columnas = tareas.map((key, value) {
          return MapEntry(
            key,
            (value as List).map((t) => Tarea.fromMap(t)).toList(),
          );
        });
      });

      debugPrint('✅ Datos cargados desde ${dataFile.path}');
    } catch (e) {
      debugPrint('❌ Error cargando JSON: $e');
    }
  }

  // 💾 Guardar datos en JSON
  Future<void> guardarEnJson() async {
    try {
      final data = {
        'usuarios': usuarios,
        'tareas': columnas.map((k, v) => MapEntry(k, v.map((t) => t.toMap()).toList())),
      };

      await dataFile.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      debugPrint('💾 Datos guardados en ${dataFile.path}');
    } catch (e) {
      debugPrint('❌ Error guardando JSON: $e');
    }
  }

  // 👤 Agregar usuario
  void agregarUsuario() async {
    final nombre = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Añadir nuevo usuario'),
        content: TextField(
          controller: nombre,
          decoration: const InputDecoration(labelText: 'Nombre del usuario'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombre.text.trim().isEmpty) return;
              setState(() {
                usuarios.add(nombre.text.trim());
              });
              await guardarEnJson();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ➕ Agregar tarea
  void agregarTarea() async {
    final titulo = TextEditingController();
    final desc = TextEditingController();
    String? encargado;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titulo, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: encargado,
              hint: const Text('Seleccionar encargado'),
              items: usuarios.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => encargado = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (titulo.text.trim().isEmpty) return;
              setState(() {
                columnas['Por hacer']!.add(
                  Tarea(
                    id: Random().nextInt(100000).toString(),
                    titulo: titulo.text,
                    descripcion: desc.text,
                    encargado: encargado ?? '',
                    fechaCreacion: DateTime.now(),
                    fechaLimite: DateTime.now(),
                  ),
                );
              });
              await guardarEnJson();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // 🔄 Mover tareas
  void moverTarea(Tarea tarea, String estadoActual, bool haciaAdelante) async {
    final index = estados.indexOf(estadoActual);
    if (index == -1) return;

    String nuevoEstado = estadoActual;
    if (haciaAdelante && index < estados.length - 1) {
      nuevoEstado = estados[index + 1];
    } else if (!haciaAdelante && index > 0) {
      nuevoEstado = estados[index - 1];
    }

    if (nuevoEstado != estadoActual) {
      setState(() {
        columnas[estadoActual]!.remove(tarea);
        columnas[nuevoEstado]!.add(tarea);
      });
      await guardarEnJson();
    }
  }

  // 📝 Editar tarea
  void editarTarea(Tarea tarea, String estadoActual) async {
    final titulo = TextEditingController(text: tarea.titulo);
    final desc = TextEditingController(text: tarea.descripcion);
    String? encargado = tarea.encargado.isEmpty ? null : tarea.encargado;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titulo, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: encargado,
              hint: const Text('Seleccionar encargado'),
              items: usuarios.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => encargado = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar cambios'),
            onPressed: () async {
              setState(() {
                tarea.titulo = titulo.text.trim();
                tarea.descripcion = desc.text.trim();
                tarea.encargado = encargado ?? '';
              });
              await guardarEnJson();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 🗑️ Eliminar tarea
  void eliminarTarea(Tarea tarea, String estadoActual) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que deseas eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        columnas[estadoActual]!.remove(tarea);
      });
      await guardarEnJson();
    }
  }

  // 📋 UI
  Widget _buildColumna(String estado, Color color) {
    final tareas = columnas[estado]!;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(estado, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  if (estado == 'Por hacer')
                    IconButton(
                      onPressed: agregarTarea,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: tareas.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Sin tareas',
                                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                          )
                        ]
                      : tareas.map((t) => _tareaCard(t, estado)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tareaCard(Tarea tarea, String estadoActual) {
    final index = estados.indexOf(estadoActual);
    final puedeRetroceder = index > 0;
    final puedeAvanzar = index < estados.length - 1;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(tarea.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tarea.descripcion),
            if (tarea.encargado.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('👤 ${tarea.encargado}',
                    style: const TextStyle(color: Colors.indigo, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => editarTarea(tarea, estadoActual)),
            if (puedeRetroceder)
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.orange), onPressed: () => moverTarea(tarea, estadoActual, false)),
            if (puedeAvanzar)
              IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.green), onPressed: () => moverTarea(tarea, estadoActual, true)),
            IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () => eliminarTarea(tarea, estadoActual)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        title: const Text('📋 Gestor de Tareas - Escritorio'),
        backgroundColor: const Color(0xff0078d7),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Añadir usuario',
            onPressed: agregarUsuario,
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumna('Por hacer', Colors.blue),
          _buildColumna('En progreso', Colors.orange),
          _buildColumna('En revisión', Colors.purple),
          _buildColumna('Terminado', Colors.green),
        ],
      ),
    );
  }
}
