// features/form/presentation/blocs/readings/form_bloc.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'dart:convert';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  FormBloc() : super(FormInitial()) {
    on<InsertReadingEvent>((event, emit) async {
      emit(FormLoading());
      try {
        final String baseUrl = Environment.apiUrl;
        debugPrint('Enviando a: $baseUrl/Readings/create-reading');
        final response = await http.post(
          Uri.parse('$baseUrl/Readings/create-reading'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "connectionId": event.connectionId,
            "sector": event.sector,
            "account": event.account,
            "cadastralKey": event.cadastralKey,
            "previousReading": event.previousReading,
            "currentReading": event.currentReading,
            "incomeCode": event.incomeCode,
            "rentalIncomeCode": event.rentalIncomeCode,
            "readingValue": event.readingValue,
            "novelty": event.novelty,
            "sewerRate": event.sewerRate,
            "averageConsumption": event.averageConsumption,
          }),
        );
        debugPrint(
          'Respuesta API (save): ${response.statusCode} - ${response.body}',
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final data =
              responseData['data']
                  as Map<String, dynamic>?; // Extraer el objeto data
          if (data == null) {
            emit(FormFailure(message: 'No se recibió los datos de la lectura'));
          } else {
            debugPrint('Respuesta exitosa: $data');
            emit(FormSuccess(data));
          }
        } else {
          emit(
            FormFailure(
              message: 'Error al guardar la lectura: ${response.statusCode}',
            ),
          );
        }
      } catch (e) {
        String errorMessage = 'Error: $e';
        if (e is SocketException) {
          errorMessage =
              'Error de conexión: No se pudo conectar al servidor en baseURL. Verifica que el servidor esté activo, usa la IP correcta y que el puerto 3005 esté abierto.';
        }
        emit(FormFailure(message: errorMessage));
      }
    });
  }
}
