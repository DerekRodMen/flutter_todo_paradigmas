import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarea.dart';
import '../widgets/tarea_card.dart';
import '../widgets/nueva_tarea_modal.dart';

// ======================================================
// 🧩 Gestor de Tareas Multiparadigma (OO + Funcional)
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

  // ===============================================
  // 📦 Persistencia con SharedPreferences (paradigma OO)
  // ===============================================
  Future<void> cargarTareas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('tareas') ?? [];
    setState(() {
      tareas = data.map((t) => Tarea.fromMap(jsonDecode(t))).toList();
    });
  }

  Future<void> guardarTareas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = tareas.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList('tareas', data);
  }

  // ===============================================
  // 🧮 Funciones funcionales (filter, map, where)
  // ===============================================
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
        if (t.id == id) {
          return Tarea(
            id: t.id,
            titulo: t.titulo,
            descripcion: t.descripcion,
            completada: !t.completada,
            fechaCreacion: t.fechaCreacion,
            fechaLimite: t.fechaLimite,
            prioridad: t.prioridad,
          );
        }
        return t;
      }).toList();
    });
    guardarTareas();
  }

  double porcentajeCompletadas() {
    if (tareas.isEmpty) return 0;
    final completadas = tareas.where((t) => t.completada).length;
    return (completadas / tareas.length) * 100;
  }

  // ===============================================
  // 🖥️ Interfaz principal
  // ===============================================
  @override
  Widget build(BuildContext context) {
    final completadas = porcentajeCompletadas();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('📋 Gestor de Tareas Multiparadigma'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tareas.isEmpty
            ? const Center(
                child: Text(
                  "No hay tareas registradas todavía 📝",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progreso de tareas completadas
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Progreso general",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completadas / 100,
                            backgroundColor: Colors.grey[300],
                            color: Colors.indigo,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "✅ ${completadas.toStringAsFixed(1)}% completadas",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Lista de tareas
                  Expanded(
                    child: ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final t = tareas[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TareaCard(
                            tarea: t,
                            onDelete: eliminarTarea,
                            onToggle: toggleCompletada,
                          ),
                        );
                      },
                    ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text("Nueva tarea"),
        onPressed: () => mostrarModalNuevaTarea(context, agregarTarea),
      ),
    );
  }
}
