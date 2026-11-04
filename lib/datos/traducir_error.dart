import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';

FallaRed traducirError(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const TiempoAgotado(),
    DioExceptionType.badResponse => _porCodigo(e.response?.statusCode),
    DioExceptionType.unknown =>
      e.error is FormatException
          ? const RespuestaInvalida()
          : const SinConexion(),
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.connectionError => const SinConexion(),
  };
}

FallaRed _porCodigo(int? codigo) {
  if (codigo == null) {
    return const SinConexion();
  }
  if (codigo >= 500) {
    return ErrorDelServidor(codigo);
  }
  return PeticionRechazada(codigo);
}
