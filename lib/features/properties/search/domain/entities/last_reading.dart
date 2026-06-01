import 'package:equatable/equatable.dart';

class LastReadingEntity extends Equatable {
  final String cadastralKey;
  final DateTime? readingDate;
  final String? readingTime;
  final String? readingMonth;
  final double? readingValueCurrent;
  final double? readingValuePreview;
  final String? novelty;

  const LastReadingEntity({
    required this.cadastralKey,
    required this.readingDate,
    required this.readingTime,
    required this.readingMonth,
    required this.readingValueCurrent,
    required this.readingValuePreview,
    required this.novelty,
  });

  @override
  List<Object?> get props => [
    cadastralKey,
    readingDate,
    readingTime,
    readingMonth,
    readingValueCurrent,
    readingValuePreview,
    novelty,
  ];
}
