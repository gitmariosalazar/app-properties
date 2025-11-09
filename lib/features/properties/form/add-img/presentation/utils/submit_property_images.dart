// lib/features/properties/form/add-img/presentation/utils/submit_property_images.dart
import 'dart:io';

import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_event.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

Future<void> submitPropertyImages({
  required BuildContext context,
  required String connectionId,
  String? description,
}) async {
  final bloc = context.read<AddPropertyImageBloc>();
  final state = bloc.state;

  // === OBTENER IMÁGENES DESDE EL BLOC (no desde parámetro) ===
  final List<XFile> images = state is AddPropertyImagePicked
      ? state.imagePaths.map((path) => XFile(path)).toList()
      : [];

  // === VALIDACIONES ===
  if (images.isEmpty) {
    _showSnackBar(context, 'Al menos una imagen es requerida.');
    return;
  }

  if (connectionId.isEmpty) {
    _showSnackBar(context, 'Connection ID inválido.');
    return;
  }

  // === DISPARAR EVENTO CORRECTO ===
  bloc.add(UploadAllImagesEvent(connectionId, description));

  // === ESCUCHAR RESULTADO ===
  await for (final s in bloc.stream) {
    if (s is AddPropertyImageSuccess) {
      _showSnackBar(context, 'Imágenes subidas exitosamente.', success: true);
      break;
    } else if (s is AddPropertyImageError) {
      _showSnackBar(context, s.message);
      break;
    }
  }
}

void _showSnackBar(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : null,
      duration: const Duration(seconds: 3),
    ),
  );
}
