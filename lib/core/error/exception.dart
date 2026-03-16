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
