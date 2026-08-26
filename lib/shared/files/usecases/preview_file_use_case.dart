import 'package:flutter/foundation.dart';

import 'package:app_properties/shared/files/domain/repositories/file_repository.dart';

class PreviewFileUseCase {
  final FileRepository repository;

  PreviewFileUseCase(this.repository);

  Future<Uint8List> execute({
    required FileCategory type,
    required String filename,
  }) async {
    print(
      '🔄 PreviewFileUseCase.execute → Type: ${type.value}, Filename: $filename',
    );

    if (filename.trim().isEmpty) {
      throw ArgumentError('Filename cannot be empty');
    }

    try {
      final bytes = await repository.preview(type: type, filename: filename);
      print('✅ Preview exitoso: ${bytes.length} bytes recibidos');
      return bytes;
    } catch (e, stack) {
      print('❌ Error en PreviewFileUseCase: $e');
      print(stack);
      rethrow;
    }
  }
}
