// lib/shared/files/presentation/providers/file_providers.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/shared/files/domain/repositories/file_repository.dart';
import 'package:app_properties/shared/files/data/repositories/file_repository_impl.dart';
import 'package:app_properties/shared/files/usecases/preview_file_use_case.dart';

// ==================== PROVIDERS BASE ====================

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🔄 Interceptor activado para: ${options.uri}');

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('CACHED_AUTH_TOKEN');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('✅ Token agregado correctamente');
        } else {
          print('⚠️ No se encontró token');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          print('❌ 401 Unauthorized - Token inválido o expirado');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// ==================== FILE PROVIDERS ====================

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FileRepositoryImpl(dio);
});

final previewFileUseCaseProvider = Provider<PreviewFileUseCase>((ref) {
  final repo = ref.watch(fileRepositoryProvider);
  return PreviewFileUseCase(repo);
});

// ==================== USE FILE PREVIEW (FAMILY) ====================

// Provider familiar: uno por cada filename (evita que todas las fotos compartan el mismo estado)
final useFilePreviewFamilyProvider =
    StateNotifierProvider.family<
      UseFilePreviewNotifier,
      UseFilePreviewResult,
      String
    >((ref, filename) {
      final useCase = ref.watch(previewFileUseCaseProvider);
      return UseFilePreviewNotifier(useCase);
    });

class UseFilePreviewResult {
  final Uint8List? bytes;
  final bool loading;
  final String? error;

  const UseFilePreviewResult({this.bytes, this.loading = false, this.error});
}

class UseFilePreviewNotifier extends StateNotifier<UseFilePreviewResult> {
  final PreviewFileUseCase _useCase;

  UseFilePreviewNotifier(this._useCase) : super(const UseFilePreviewResult());

  Future<void> load(FileCategory type, String filename) async {
    state = const UseFilePreviewResult(loading: true);
    try {
      final bytes = await _useCase.execute(type: type, filename: filename);
      state = UseFilePreviewResult(bytes: bytes);
      print('✅ Preview cargado: ${bytes.length} bytes para $filename');
    } catch (e) {
      state = UseFilePreviewResult(error: e.toString());
      print('❌ Error preview $filename: $e');
    }
  }

  void clear() {
    state = const UseFilePreviewResult();
  }
}
