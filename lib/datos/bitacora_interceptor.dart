import 'dart:developer' as developer;

import 'package:dio/dio.dart';

const _claveCronometro = 'bitacora_cronometro';

class BitacoraInterceptor extends Interceptor {
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? _registrar;

  final void Function(String linea) _escribir;

  static void _registrar(String linea) {
    developer.log(linea, name: 'recetario');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_claveCronometro] = Stopwatch()..start();
    _escribir('→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final peticion = response.requestOptions;
    final ms = _milisegundos(peticion);
    _escribir(
      '← ${response.statusCode} ${peticion.method} ${peticion.path} ($ms ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final peticion = err.requestOptions;
    final ms = _milisegundos(peticion);
    final codigo = err.response?.statusCode;
    final detalle = codigo == null ? err.type.name : '${err.type.name} $codigo';
    _escribir('✗ $detalle ${peticion.method} ${peticion.path} ($ms ms)');
    handler.next(err);
  }

  int _milisegundos(RequestOptions peticion) {
    final cronometro = peticion.extra[_claveCronometro];
    if (cronometro is Stopwatch) {
      cronometro.stop();
      return cronometro.elapsedMilliseconds;
    }
    return 0;
  }
}
