import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';
import '../dominio/receta.dart';
import 'recetas_json.dart';
import 'recetas_repositorio.dart';
import 'traducir_error.dart';

const recetasPorPagina = 10;

class DummyJsonRepositorio implements RecetasRepositorio {
  DummyJsonRepositorio(this._dio);

  final Dio _dio;

  @override
  Future<PaginaRecetas> buscar({String texto = ''}) async {
    final limpio = texto.trim();

    final Response<dynamic> respuesta;
    try {
      respuesta = await _dio.get<dynamic>(
        limpio.isEmpty ? '/recipes' : '/recipes/search',
        queryParameters: limpio.isEmpty
            ? {'limit': recetasPorPagina}
            : {'q': limpio, 'limit': recetasPorPagina},
      );
    } on DioException catch (e) {
      throw traducirError(e);
    }

    final datos = respuesta.data;
    if (datos is! Map<String, dynamic>) {
      throw const RespuestaInvalida();
    }

    try {
      return paginaDesdeJson(datos);
    } on FormatException {
      throw const RespuestaInvalida();
    }
  }
}
