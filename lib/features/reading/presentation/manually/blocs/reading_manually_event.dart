abstract class ReadingManuallyEvent {}

class LoadReadingManuallyInfo extends ReadingManuallyEvent {
  final String cadastralKey;
  LoadReadingManuallyInfo(this.cadastralKey);
}
