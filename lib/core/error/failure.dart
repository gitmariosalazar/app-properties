// lib/core/error/failure.dart
abstract class Failure {
  final String message;
  final int? code; // opcional, útil para HTTP o códigos internos

  Failure({required this.message, this.code});

  @override
  String toString() => message;
}

// Fallos del servidor
class ServerFailure extends Failure {
  ServerFailure({super.message = "Error del servidor", super.code});
}

// Fallos de cache/local
class CacheFailure extends Failure {
  CacheFailure({super.message = "Error de cache", super.code});
}

// Fallos de red
class NetworkFailure extends Failure {
  NetworkFailure({super.message = "Sin conexión a Internet", super.code});
}

// Fallos de validación o datos
class ValidationFailure extends Failure {
  ValidationFailure({super.message = "Error de validación", super.code});
}
