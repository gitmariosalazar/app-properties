// data/repositories/file_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final Dio _dio;

  FileRepositoryImpl(this._dio); // ← Usa el Dio inyectado

  @override
  Future<Uint8List> preview({
    required FileCategory type,
    required String filename,
  }) async {
    final response = await _dio.get<Uint8List>(
      '/files/${type.value}/${Uri.encodeComponent(filename)}/preview',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  @override
  Future<Uint8List> download({
    required FileCategory type,
    required String filename,
  }) async {
    final response = await _dio.get<Uint8List>(
      '/files/${type.value}/${Uri.encodeComponent(filename)}/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
