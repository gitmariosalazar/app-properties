import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:app_properties/config/environments/environment.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart' as mime;
import '../../domain/entities/photo_connection.dart';
import '../../../../../../core/error/failure.dart';

abstract class PropertyImageRemoteDataSource {
  Future<Either<Failure, List<PhotoConnection>>> addPropertyImages({
    required String connectionId,
    required List<XFile> images,
    String? description,
  });
}

class PropertyImageRemoteDataSourceImpl
    implements PropertyImageRemoteDataSource {
  final http.Client client;
  final String baseUrl = Environment.apiUrl;

  PropertyImageRemoteDataSourceImpl(this.client);

  @override
  Future<Either<Failure, List<PhotoConnection>>> addPropertyImages({
    required String connectionId,
    required List<XFile> images,
    String? description,
  }) async {
    if (images.isEmpty) {
      return Left(ServerFailure(message: 'At least one image is required.'));
    }

    // Validar archivos antes de enviarlos
    for (final image in images) {
      final file = File(image.path);
      if (!await file.exists()) {
        return Left(ServerFailure(message: 'Image not found: ${image.path}'));
      }
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return Left(
          ServerFailure(
            message:
                'Image too large: ${image.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)',
          ),
        );
      }
      developer.log(
        'Validated image: ${image.path}, ${(fileSize / 1024).toStringAsFixed(0)}KB',
      );
    }

    final uri = Uri.parse('$baseUrl/photo-connection/create-photo-connection');
    final request = http.MultipartRequest('POST', uri);

    request.fields['connectionId'] = connectionId;
    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

    developer.log('📦 Building request for connectionId=$connectionId');

    // Añadir archivos con MIME type correcto
    for (final image in images) {
      try {
        final file = File(image.path);
        final fileName = image.path.split('/').last;
        final mimeType = mime.lookupMimeType(fileName) ?? 'image/jpeg';

        developer.log('Adding file: $fileName ($mimeType)');

        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      } catch (e) {
        developer.log('❌ Error adding image ${image.path}: $e');
        return Left(ServerFailure(message: 'Failed to add image: $e'));
      }
    }

    developer.log('Sending ${request.files.length} images to $uri...');

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      developer.log('Response status: ${streamedResponse.statusCode}');
      developer.log(
        'Response body: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
      );

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final List<dynamic> data = jsonResponse['data'] ?? [];

        if (data.isEmpty) {
          return Left(ServerFailure(message: 'No data returned from server.'));
        }

        final List<PhotoConnection> models = data
            .map((e) => PhotoConnection.fromJson(e))
            .toList();

        developer.log('✅ Uploaded ${models.length} photo connections.');
        return Right(models);
      } else if (streamedResponse.statusCode == 500) {
        developer.log('❌ Server internal error (500): $responseBody');
        return Left(ServerFailure(message: 'Server error: $responseBody'));
      } else if (streamedResponse.statusCode == 413) {
        return Left(
          ServerFailure(
            message:
                'Request too large. Please reduce image size or contact admin.',
          ),
        );
      } else {
        developer.log('❌ Server returned ${streamedResponse.statusCode}');
        return Left(
          ServerFailure(
            message:
                'Server returned ${streamedResponse.statusCode}: $responseBody',
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Network or parsing error: $e');
      return Left(NetworkFailure(message: 'Network error: $e'));
    }
  }
}
