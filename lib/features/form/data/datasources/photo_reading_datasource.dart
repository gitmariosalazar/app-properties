// lib/features/form/data/datasources/photo_reading_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:mime/mime.dart' as mime;
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/form/data/models/photo_reading_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PhotoReadingDataSource {
  static const String baseUrl = 'https://dev.sigepaa-aa.com:8443/photo-reading';

  Future<Either<Failure, List<PhotoReadingModel>>> createPhotoReadings({
    required List<File> images,
    required int readingId,
    required String cadastralKey,
    String? description,
  }) async {
    if (images.isEmpty) {
      return Left(ServerFailure(message: 'At least one image is required.'));
    }

    // Validación adicional: Verificar que los archivos existan y sean accesibles
    for (var image in images) {
      if (!await image.exists()) {
        return Left(
          ServerFailure(message: 'Image file not found: ${image.path}'),
        );
      }
      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB límite
        return Left(
          ServerFailure(
            message:
                'Image too large: ${image.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)',
          ),
        );
      }
      developer.log(
        'File validated: ${image.path}, size: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB',
      );
    }

    final uri = Uri.parse('$baseUrl/create-photo-readings');
    var request = http.MultipartRequest('POST', uri);

    // Añadir campos de formulario
    request.fields['readingId'] = readingId.toString();
    request.fields['cadastralKey'] = cadastralKey;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    developer.log(
      'Fields added: readingId=$readingId, cadastralKey=$cadastralKey',
    );

    // Añadir archivos con MIME type explícito
    for (var image in images) {
      try {
        // Detectar el MIME type basado en la extensión del archivo
        final fileName = image.path.split('/').last;
        final mimeType = mime.lookupMimeType(fileName) ?? 'image/jpeg';
        final fileSize = await image.length();

        developer.log(
          'Adding file: ${image.path}, filename: $fileName, mimeType: $mimeType, size: ${(fileSize / 1024).toStringAsFixed(0)}KB',
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Coincide con el campo esperado en el backend
            image.path,
            contentType: MediaType.parse(
              mimeType,
            ), // Especificar explícitamente el MIME type
          ),
        );
      } catch (e) {
        developer.log('Error adding file ${image.path}: $e');
        return Left(
          ServerFailure(
            message: 'Failed to add image: ${image.path}. Error: $e',
          ),
        );
      }
    }

    developer.log(
      'MultipartRequest built successfully with ${images.length} files. Sending to $uri...',
    );

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      developer.log('Response status: ${streamedResponse.statusCode}');
      developer.log(
        'Response body preview: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
      );

      if (streamedResponse.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final List<dynamic> data = jsonResponse['data'] ?? [];
        if (data.isEmpty) {
          return Left(ServerFailure(message: 'No data returned from server.'));
        }
        final List<PhotoReadingModel> models = data
            .map((json) => PhotoReadingModel.fromJson(json))
            .toList();
        developer.log('Parsed ${models.length} models successfully.');
        return Right(models);
      } else if (streamedResponse.statusCode == 500) {
        developer.log('Server internal error (500): $responseBody');
        return Left(ServerFailure(message: 'Server error: $responseBody'));
      } else if (streamedResponse.statusCode == 413) {
        return Left(
          ServerFailure(
            message:
                'Request too large. Please reduce image size or contact admin.',
          ),
        );
      } else {
        developer.log('Server error response: $responseBody');
        return Left(
          ServerFailure(
            message:
                'Server returned ${streamedResponse.statusCode}: $responseBody',
          ),
        );
      }
    } catch (e) {
      developer.log('Network or parsing error: $e');
      return Left(NetworkFailure(message: 'Network error: $e'));
    }
  }
}
