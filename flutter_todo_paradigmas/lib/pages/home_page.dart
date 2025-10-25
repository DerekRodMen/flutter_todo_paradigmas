import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarea.dart';
import '../widgets/tarea_card.dart';
import '../widgets/nueva_tarea_modal.dart';

// ======================================================
// 🧩 Paradigma funcional + OO en acción
// ======================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarea> tareas = [];

  @override
  void initState() {
    super.initState();
    cargarTareas();
  }

  Future<void> cargarTareas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('tareas') ?? [];
    setState(() {
      tareas = data
          .map((t) => Tarea.fromMap(jsonDecode(t))) // ← uso funcional
          .toList();
    });
  }

  Future<void> guardarTareas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = tareas.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList('tareas', data);
  }

  void agregarTarea(Tarea tarea) {
    setState(() => tareas.add(tarea));
    guardarTareas();
  }

  void eliminarTarea(String id) {
    setState(() => tareas.removeWhere((t) => t.id == id));
    guardarTareas();
  
  
  
  
  }    


  void toggleCompletada(String id) {
    setState(() {
      tareas = tareas.map((t) {
        if (t.id == id) return Tarea(
          id: t.id,
          titulo: t.titulo,
          descripcion: t.descripcion,
          completada: !t.completada,
          fechaCreacion: t.fechaCreacion,
          fechaLimite: t.fechaLimite,
          prioridad: t.prioridad,
        );
        return t;
      }).toList();
    });
    guardarTareas();
  }

  double promedioCompletadas() {
    if (tareas.isEmpty) return 0;
    final completadas = tareas.where((t) => t.completada).length;
    return (completadas / tareas.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Gestor de Tareas Multiparadigma'),
        centerTitle: true,
      ),
      body: tareas.isEmpty
          ? const Center(child: Text("No hay tareas registradas."))
          : ListView(
              children: [
                ...tareas.map((t) => TareaCard(
                      tarea: t,
                      onDelete: eliminarTarea,
                      onToggle: toggleCompletada,
                    )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "✅ Completadas: ${promedioCompletadas().toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarModalNuevaTarea(context, agregarTarea),
        child: const Icon(Icons.add),
      ),
    );
  }
}
