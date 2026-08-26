import 'package:equatable/equatable.dart';

class PendingReadingResponse extends Equatable {
  // ── Identificación del Cliente y Suministro ────────────────────────────────
  final String incomeCode;
  final String? incomeTitleCode;
  final DateTime? readingCaptureDate;
  final String cardId;
  final String name;
  final String lastName;
  final String cadastralKey;
  final String address;
  final String rate;
  final double interestValue;

  // ── Período de Facturación e Ingresos ──────────────────────────────────────
  final String month;
  final int year;
  final String monthDue;
  final int yearDue;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final String incomeStatus;
  final DateTime? incomeDate;

  // ── Lectura del Medidor ────────────────────────────────────────────────────
  final double currentReading;
  final double previousReading;
  final double consumption;
  final String readingStatus;
  final double readingValue;

  // ── Valores de Agua (Servicios Base) ───────────────────────────────────────
  final double epaaValue;
  final double thirdPartyValue;
  final double surcharge;
  final double totalEpaaValue;

  // ── Tasa de Basura y Notas de Crédito ──────────────────────────────────────
  final double trashRateOfficial;
  final double trashRate;
  final double trashRatePrevious;
  final double balanceInFavorCurrentMonth;
  final double balanceInFavorNextMonth;
  final double balanceAgainstNextMonth;
  final double discountTrashRate;
  final double totalTrashRate;

  // ── Totales de la Planilla ─────────────────────────────────────────────────
  final double total;
  final double adjustedTotal;
  final String dueDateStatus;

  const PendingReadingResponse({
    required this.incomeCode,
    this.incomeTitleCode,
    this.readingCaptureDate,
    required this.cardId,
    required this.name,
    required this.lastName,
    required this.cadastralKey,
    required this.address,
    required this.rate,
    required this.interestValue,
    required this.month,
    required this.year,
    required this.monthDue,
    required this.yearDue,
    this.dueDate,
    this.paymentDate,
    required this.incomeStatus,
    this.incomeDate,
    required this.currentReading,
    required this.previousReading,
    required this.consumption,
    required this.readingStatus,
    required this.readingValue,
    required this.epaaValue,
    required this.thirdPartyValue,
    required this.surcharge,
    required this.totalEpaaValue,
    required this.trashRateOfficial,
    required this.trashRate,
    required this.trashRatePrevious,
    required this.balanceInFavorCurrentMonth,
    required this.balanceInFavorNextMonth,
    required this.balanceAgainstNextMonth,
    required this.discountTrashRate,
    required this.totalTrashRate,
    required this.total,
    required this.adjustedTotal,
    required this.dueDateStatus,
  });

  @override
  List<Object?> get props => [
        incomeCode,
        incomeTitleCode,
        readingCaptureDate,
        cardId,
        name,
        lastName,
        cadastralKey,
        address,
        rate,
        interestValue,
        month,
        year,
        monthDue,
        yearDue,
        dueDate,
        paymentDate,
        incomeStatus,
        incomeDate,
        currentReading,
        previousReading,
        consumption,
        readingStatus,
        readingValue,
        epaaValue,
        thirdPartyValue,
        surcharge,
        totalEpaaValue,
        trashRateOfficial,
        trashRate,
        trashRatePrevious,
        balanceInFavorCurrentMonth,
        balanceInFavorNextMonth,
        balanceAgainstNextMonth,
        discountTrashRate,
        totalTrashRate,
        total,
        adjustedTotal,
        dueDateStatus,
      ];

  factory PendingReadingResponse.fromJson(Map<String, dynamic> json) {
    return PendingReadingResponse(
      incomeCode: json['incomeCode'] as String? ?? '',
      incomeTitleCode: json['incomeTitleCode'] as String?,
      readingCaptureDate: json['readingCaptureDate'] != null
          ? DateTime.tryParse(json['readingCaptureDate'] as String)
          : null,
      cardId: json['cardId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      cadastralKey: json['cadastralKey'] as String? ?? '',
      address: json['address'] as String? ?? '',
      rate: json['rate'] as String? ?? '',
      interestValue: (json['interestValue'] as num?)?.toDouble() ?? 0.0,
      month: json['month'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      monthDue: json['monthDue'] as String? ?? '',
      yearDue: json['yearDue'] as int? ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'] as String)
          : null,
      incomeStatus: json['incomeStatus'] as String? ?? '',
      incomeDate: json['incomeDate'] != null
          ? DateTime.tryParse(json['incomeDate'] as String)
          : null,
      currentReading: (json['currentReading'] as num?)?.toDouble() ?? 0.0,
      previousReading: (json['previousReading'] as num?)?.toDouble() ?? 0.0,
      consumption: (json['consumption'] as num?)?.toDouble() ?? 0.0,
      readingStatus: json['readingStatus'] as String? ?? '',
      readingValue: (json['readingValue'] as num?)?.toDouble() ?? 0.0,
      epaaValue: (json['epaaValue'] as num?)?.toDouble() ?? 0.0,
      thirdPartyValue: (json['thirdPartyValue'] as num?)?.toDouble() ?? 0.0,
      surcharge: (json['surcharge'] as num?)?.toDouble() ?? 0.0,
      totalEpaaValue: (json['totalEpaaValue'] as num?)?.toDouble() ?? 0.0,
      trashRateOfficial: (json['trashRateOfficial'] as num?)?.toDouble() ?? 0.0,
      trashRate: (json['trashRate'] as num?)?.toDouble() ?? 0.0,
      trashRatePrevious: (json['trashRatePrevious'] as num?)?.toDouble() ?? 0.0,
      balanceInFavorCurrentMonth:
          (json['balanceInFavorCurrentMonth'] as num?)?.toDouble() ?? 0.0,
      balanceInFavorNextMonth:
          (json['balanceInFavorNextMonth'] as num?)?.toDouble() ?? 0.0,
      balanceAgainstNextMonth:
          (json['balanceAgainstNextMonth'] as num?)?.toDouble() ?? 0.0,
      discountTrashRate: (json['discountTrashRate'] as num?)?.toDouble() ?? 0.0,
      totalTrashRate: (json['totalTrashRate'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      adjustedTotal: (json['adjustedTotal'] as num?)?.toDouble() ?? 0.0,
      dueDateStatus: json['dueDateStatus'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incomeCode': incomeCode,
      'incomeTitleCode': incomeTitleCode,
      'readingCaptureDate': readingCaptureDate?.toIso8601String(),
      'cardId': cardId,
      'name': name,
      'lastName': lastName,
      'cadastralKey': cadastralKey,
      'address': address,
      'rate': rate,
      'interestValue': interestValue,
      'month': month,
      'year': year,
      'monthDue': monthDue,
      'yearDue': yearDue,
      'dueDate': dueDate?.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'incomeStatus': incomeStatus,
      'incomeDate': incomeDate?.toIso8601String(),
      'currentReading': currentReading,
      'previousReading': previousReading,
      'consumption': consumption,
      'readingStatus': readingStatus,
      'readingValue': readingValue,
      'epaaValue': epaaValue,
      'thirdPartyValue': thirdPartyValue,
      'surcharge': surcharge,
      'totalEpaaValue': totalEpaaValue,
      'trashRateOfficial': trashRateOfficial,
      'trashRate': trashRate,
      'trashRatePrevious': trashRatePrevious,
      'balanceInFavorCurrentMonth': balanceInFavorCurrentMonth,
      'balanceInFavorNextMonth': balanceInFavorNextMonth,
      'balanceAgainstNextMonth': balanceAgainstNextMonth,
      'discountTrashRate': discountTrashRate,
      'totalTrashRate': totalTrashRate,
      'total': total,
      'adjustedTotal': adjustedTotal,
      'dueDateStatus': dueDateStatus,
    };
  }
}
