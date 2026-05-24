import 'dart:io'; // para SocketException

/// Thrown when the device has no internet or the server is unreachable.
/// DIFFERENT from [ServerException] (which means the server responded with an error).
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexión a Internet']);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? code;

  ServerException(this.message, [this.code]);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache Error']);

  @override
  String toString() => 'CacheException: $message';
}

/// Utility: wraps a Future<T> and converts [SocketException] / [HttpException]
/// into [NetworkException] automatically so callers don't need to know the
/// underlying socket details.
Future<T> guardNetwork<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on SocketException {
    throw NetworkException('Sin conexión a Internet');
  } on HttpException {
    throw NetworkException('Error de red');
  }
}
