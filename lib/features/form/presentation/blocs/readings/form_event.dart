part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar lecturas desde la API (GET)
class LoadReadingEvent extends FormEvent {
  final String connectionId;

  const LoadReadingEvent(this.connectionId);

  @override
  List<Object> get props => [connectionId];
}

/// Evento para insertar una lectura (POST)
class InsertReadingEvent extends FormEvent {
  final String connectionId;
  final int sector;
  final int account;
  final String cadastralKey;
  final double sewerRate;
  final double previousReading;
  final double currentReading;
  final int incomeCode;
  final double readingValue;
  final int rentalIncomeCode;
  final String novelty;
  final double averageConsumption;

  const InsertReadingEvent({
    required this.connectionId,
    required this.sector,
    required this.account,
    required this.cadastralKey,
    required this.sewerRate,
    required this.previousReading,
    required this.currentReading,
    required this.incomeCode,
    required this.readingValue,
    required this.rentalIncomeCode,
    required this.novelty,
    required this.averageConsumption,
  });

  @override
  List<Object> get props => [
    connectionId,
    sector,
    account,
    cadastralKey,
    sewerRate,
    previousReading,
    currentReading,
    incomeCode,
    readingValue,
    rentalIncomeCode,
    novelty,
    averageConsumption,
  ];
}
