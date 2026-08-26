// lib/features/scan/presentation/blocs/reading_event.dart
abstract class ReadingScanEvent {}

class LoadReadingScanInfo extends ReadingScanEvent {
  final String cadastralKey;
  LoadReadingScanInfo(this.cadastralKey);
}

class ResetReadingScan extends ReadingScanEvent {}
