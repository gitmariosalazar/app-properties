import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_event.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> submitPhotoReading({
  required BuildContext context,
  required List<File> images,
  required int readingId,
  required String cadastralKey,
  String? description,
  required String mode, // 'scan' or 'manual'
}) async {
  // Validaciones condicionales basadas en el modo
  final isManualMode = mode == 'manual';
  if (isManualMode && images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('At least one image is required in manual mode.'),
      ),
    );
    return;
  }
  if (readingId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid Reading ID.')),
    );
    return;
  }
  if (cadastralKey.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cadastral Key is required.')));
    return;
  }

  // Obtener el PhotoReadingBloc
  final photoReadingBloc = context.read<PhotoReadingBloc>();
  photoReadingBloc.add(
    CreatePhotoReadingEvent(
      images: images,
      readingId: readingId,
      cadastralKey: cadastralKey,
      description: description,
    ),
  );

  // Escuchar el resultado asíncronamente
  await for (final state in photoReadingBloc.stream) {
    if (state is PhotoReadingLoading) {
      // Opcional: Podrías mostrar un indicador de carga si lo integras en un widget
    } else if (state is PhotoReadingSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo readings created successfully!')),
      );
      break; // Salir del loop una vez que se complete
    } else if (state is PhotoReadingError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      break; // Salir del loop en caso de error
    }
  }
}
