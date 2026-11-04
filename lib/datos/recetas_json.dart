import '../dominio/receta.dart';

Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida,
  };
}

Receta recetaDesdeJson(Map<String, dynamic> json) {
  final campos = switch (json) {
    {
      'id': final int id,
      'name': final String nombre,
      'cuisine': final String cocina,
      'prepTimeMinutes': final int minutosPreparacion,
      'cookTimeMinutes': final int minutosCoccion,
      'servings': final int porciones,
      'rating': final num calificacion,
    } =>
      (
        id: id,
        nombre: nombre,
        cocina: cocina,
        minutosPreparacion: minutosPreparacion,
        minutosCoccion: minutosCoccion,
        porciones: porciones,
        calificacion: calificacion,
      ),
    _ => throw const FormatException(
      'Receta con campos obligatorios inválidos',
    ),
  };

  return Receta(
    id: campos.id,
    nombre: campos.nombre,
    cocina: campos.cocina,
    dificultad: dificultadDesdeTexto(json['difficulty']),
    minutosPreparacion: campos.minutosPreparacion,
    minutosCoccion: campos.minutosCoccion,
    porciones: campos.porciones,
    calificacion: campos.calificacion.toDouble(),
    etiquetas: _listaDeTextos(json, 'tags'),
    ingredientes: _listaDeTextos(json, 'ingredients'),
  );
}

PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  final recipes = json['recipes'];
  final total = json['total'];

  if (recipes is! List || total is! int) {
    throw const FormatException('Página con formato inesperado');
  }

  final recetas = <Receta>[];
  for (final elemento in recipes) {
    if (elemento is! Map<String, dynamic>) {
      throw const FormatException('Elemento de recetas con formato inesperado');
    }
    recetas.add(recetaDesdeJson(elemento));
  }

  return PaginaRecetas(recetas: recetas, total: total);
}

List<String> _listaDeTextos(Map<String, dynamic> json, String clave) {
  if (!json.containsKey(clave)) {
    return const [];
  }

  final valor = json[clave];
  if (valor is! List) {
    throw FormatException('$clave no es una lista');
  }

  final textos = <String>[];
  for (final elemento in valor) {
    if (elemento is! String) {
      throw FormatException('$clave contiene un elemento que no es texto');
    }
    textos.add(elemento);
  }
  return textos;
}
