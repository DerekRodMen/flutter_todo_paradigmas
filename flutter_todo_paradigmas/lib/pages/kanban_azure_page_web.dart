import 'dart:convert';
import 'dart:html' as html;

Future<void> guardarEnLocalStorageWeb(Map<String, dynamic> data) async {
  html.window.localStorage['kanban_data'] = jsonEncode(data);
  print('💾 Datos guardados en localStorage (Web)');
}

Future<void> cargarDesdeLocalStorageWeb() async {
  final data = html.window.localStorage['kanban_data'];
  if (data != null && data.isNotEmpty) {
    print('✅ Datos cargados desde localStorage (Web)');
  }
}
