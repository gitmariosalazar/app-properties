import 'package:equatable/equatable.dart';

/// ==================== SUB MODELOS ====================

class ContactPhone extends Equatable {
  final int telefonoId;
  final String numero;

  const ContactPhone({required this.telefonoId, required this.numero});

  @override
  List<Object?> get props => [telefonoId, numero];

  factory ContactPhone.fromJson(Map<String, dynamic> json) {
    return ContactPhone(
      telefonoId: json['telefonoId'] as int? ?? 0,
      numero: json['numero'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'telefonoId': telefonoId, 'numero': numero};
  }
}

class ContactEmail extends Equatable {
  final int emailId;
  final String correo;

  const ContactEmail({required this.emailId, required this.correo});

  @override
  List<Object?> get props => [emailId, correo];

  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      emailId: json['emailId'] as int? ?? 0,
      correo: json['correo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'emailId': emailId, 'correo': correo};
  }
}

class EvidencePhoto extends Equatable {
  final int id;
  final String filePath;
  final String type; // 'REPORTE' | 'RESOLUCION'
  final DateTime createdAt;

  const EvidencePhoto({
    required this.id,
    required this.filePath,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, filePath, type, createdAt];

  factory EvidencePhoto.fromJson(Map<String, dynamic> json) {
    return EvidencePhoto(
      id: json['id'] as int? ?? 0,
      filePath: json['filePath'] as String? ?? '',
      type: json['type'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ManagedByUser {
  final String nombre;
  final String apellido;
  final String correo;
  final String celular;

  ManagedByUser({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.celular,
  });

  factory ManagedByUser.fromJson(Map<String, dynamic> json) {
    return ManagedByUser(
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      celular: json['celular'] ?? '',
    );
  }
}

class IncidentHistory extends Equatable {
  final DateTime dateChange;
  final String? previousStatus;
  final String newStatus;
  final ManagedByUser? managedBy;
  final String? observation;

  const IncidentHistory({
    required this.dateChange,
    this.previousStatus,
    required this.newStatus,
    this.managedBy,
    this.observation,
  });

  @override
  List<Object?> get props => [
    dateChange,
    previousStatus,
    newStatus,
    managedBy,
    observation,
  ];

  factory IncidentHistory.fromJson(Map<String, dynamic> json) {
    return IncidentHistory(
      dateChange: json['dateChange'] != null
          ? DateTime.tryParse(json['dateChange'] as String) ?? DateTime.now()
          : DateTime.now(),
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String? ?? '',
      managedBy: json['managedBy'] != null
          ? ManagedByUser.fromJson(json['managedBy'])
          : null,
      observation: json['observation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateChange': dateChange.toIso8601String(),
      'previousStatus': previousStatus,
      'newStatus': newStatus,
      'managedBy': managedBy,
      'observation': observation,
    };
  }
}

class ReporterCompany extends Equatable {
  final String companyId;
  final String? commercialName;
  final String? businessName;
  final String ruc;
  final String? address;
  final String? parishId;
  final String? country;
  final String clientId;
  final List<ContactPhone> phones;
  final List<ContactEmail> emails;

  const ReporterCompany({
    required this.companyId,
    this.commercialName,
    this.businessName,
    required this.ruc,
    this.address,
    this.parishId,
    this.country,
    required this.clientId,
    this.phones = const [],
    this.emails = const [],
  });

  @override
  List<Object?> get props => [
    companyId,
    commercialName,
    businessName,
    ruc,
    address,
    parishId,
    country,
    clientId,
    phones,
    emails,
  ];

  factory ReporterCompany.fromJson(Map<String, dynamic> json) {
    return ReporterCompany(
      companyId: json['companyId'] as String? ?? '',
      commercialName: json['commercialName'] as String?,
      businessName: json['businessName'] as String?,
      ruc: json['ruc'] as String? ?? '',
      address: json['address'] as String?,
      parishId: json['parishId'] as String?,
      country: json['country'] as String?,
      clientId: json['clientId'] as String? ?? '',
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map((e) => ContactPhone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emails:
          (json['emails'] as List<dynamic>?)
              ?.map((e) => ContactEmail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'commercialName': commercialName,
      'businessName': businessName,
      'ruc': ruc,
      'address': address,
      'parishId': parishId,
      'country': country,
      'clientId': clientId,
      'phones': phones.map((e) => e.toJson()).toList(),
      'emails': emails.map((e) => e.toJson()).toList(),
    };
  }
}

class ReporterPerson extends Equatable {
  final String personId;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final bool isDeceased;
  final int genderId;
  final int civilStatusId;
  final int professionId;
  final String parishId;
  final String? address;
  final String? country;
  final List<ContactPhone> phones;
  final List<ContactEmail> emails;

  const ReporterPerson({
    required this.personId,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.isDeceased,
    required this.genderId,
    required this.civilStatusId,
    required this.professionId,
    required this.parishId,
    this.address,
    this.country,
    this.phones = const [],
    this.emails = const [],
  });

  @override
  List<Object?> get props => [
    personId,
    firstName,
    lastName,
    birthDate,
    isDeceased,
    genderId,
    civilStatusId,
    professionId,
    parishId,
    address,
    country,
    phones,
    emails,
  ];

  factory ReporterPerson.fromJson(Map<String, dynamic> json) {
    return ReporterPerson(
      personId: json['personId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      isDeceased: json['isDeceased'] as bool? ?? false,
      genderId: json['genderId'] as int? ?? 0,
      civilStatusId: json['civilStatusId'] as int? ?? 0,
      professionId: json['professionId'] as int? ?? 0,
      parishId: json['parishId'] as String? ?? '',
      address: json['address'] as String?,
      country: json['country'] as String?,
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map((e) => ContactPhone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emails:
          (json['emails'] as List<dynamic>?)
              ?.map((e) => ContactEmail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personId': personId,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate?.toIso8601String(),
      'isDeceased': isDeceased,
      'genderId': genderId,
      'civilStatusId': civilStatusId,
      'professionId': professionId,
      'parishId': parishId,
      'address': address,
      'country': country,
      'phones': phones.map((e) => e.toJson()).toList(),
      'emails': emails.map((e) => e.toJson()).toList(),
    };
  }
}

class UserRow extends Equatable {
  final String name;
  final String cardId;
  final String userType;

  const UserRow({
    required this.name,
    required this.cardId,
    required this.userType,
  });

  @override
  List<Object?> get props => [name, cardId, userType];

  factory UserRow.fromJson(Map<String, dynamic> json) {
    return UserRow(
      name: json['name'] as String? ?? '',
      cardId: json['cardId'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'cardId': cardId, 'userType': userType};
  }
}

/// ==================== MODELO PRINCIPAL ====================

class IncidentDetailRowResponse extends Equatable {
  final String incidentId;
  final String? connectionId;
  final String incidentCode;
  final int? readingId;

  final String categoryCode;
  final String categoryName;
  final int incidentTypeId;
  final String incidentTypeName;
  final String suggestedPriority;

  final String reportDescription;
  final String? referenceAddress;
  final String status;
  final String reportOrigin;
  final String currentPriority;
  final DateTime reportDate;
  final double? latitude;
  final double? longitude;

  final UserRow reportedBy;
  final ReporterCompany? company;
  final ReporterPerson? person;

  final DateTime? resolutionDate;
  final UserRow? resolvedBy;
  final String? resolutionDescription;

  final bool chargeToUser;
  final double repairCost;

  final List<EvidencePhoto> photosReport;
  final int photosReportCount;
  final List<EvidencePhoto> photosResolution;
  final int photosResolutionCount;

  final List<IncidentHistory> historyRecent;

  final int? openDays;
  final int? pendingDays;

  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidentDetailRowResponse({
    required this.incidentId,
    this.connectionId,
    required this.incidentCode,
    this.readingId,
    required this.categoryCode,
    required this.categoryName,
    required this.incidentTypeId,
    required this.incidentTypeName,
    required this.suggestedPriority,
    required this.reportDescription,
    this.referenceAddress,
    required this.status,
    required this.reportOrigin,
    required this.currentPriority,
    required this.reportDate,
    this.latitude,
    this.longitude,
    required this.reportedBy,
    this.company,
    this.person,
    this.resolutionDate,
    this.resolvedBy,
    this.resolutionDescription,
    required this.chargeToUser,
    required this.repairCost,
    this.photosReport = const [],
    this.photosReportCount = 0,
    this.photosResolution = const [],
    this.photosResolutionCount = 0,
    this.historyRecent = const [],
    this.openDays,
    this.pendingDays,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    incidentId,
    connectionId,
    incidentCode,
    readingId,
    categoryCode,
    categoryName,
    incidentTypeId,
    incidentTypeName,
    suggestedPriority,
    reportDescription,
    referenceAddress,
    status,
    reportOrigin,
    currentPriority,
    reportDate,
    latitude,
    longitude,
    reportedBy,
    company,
    person,
    resolutionDate,
    resolvedBy,
    resolutionDescription,
    chargeToUser,
    repairCost,
    photosReport,
    photosReportCount,
    photosResolution,
    photosResolutionCount,
    historyRecent,
    openDays,
    pendingDays,
    createdAt,
    updatedAt,
  ];

  factory IncidentDetailRowResponse.fromJson(Map<String, dynamic> json) {
    return IncidentDetailRowResponse(
      incidentId: json['incidentId'] as String? ?? '',
      connectionId: json['connectionId'] as String?,
      incidentCode: json['incidentCode'] as String? ?? '',
      readingId: _parseInt(json['readingId']),
      categoryCode: json['categoryCode'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      incidentTypeId: _parseInt(json['incidentTypeId']),
      incidentTypeName: json['incidentTypeName'] as String? ?? '',
      suggestedPriority: json['suggestedPriority'] as String? ?? '',
      reportDescription: json['reportDescription'] as String? ?? '',
      referenceAddress: json['referenceAddress'] as String?,
      status: json['status'] as String? ?? '',
      reportOrigin: json['reportOrigin'] as String? ?? '',
      currentPriority: json['currentPriority'] as String? ?? '',
      reportDate: json['reportDate'] != null
          ? DateTime.tryParse(json['reportDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      reportedBy: UserRow.fromJson(
        json['reportedBy'] as Map<String, dynamic>? ?? {},
      ),
      company: json['company'] != null
          ? ReporterCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      person: json['person'] != null
          ? ReporterPerson.fromJson(json['person'] as Map<String, dynamic>)
          : null,
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.tryParse(json['resolutionDate'] as String)
          : null,
      resolvedBy: json['resolvedBy'] != null
          ? UserRow.fromJson(json['resolvedBy'] as Map<String, dynamic>)
          : null,
      resolutionDescription: json['resolutionDescription'] as String?,
      chargeToUser: json['chargeToUser'] as bool? ?? false,
      repairCost: (json['repairCost'] as num?)?.toDouble() ?? 0.0,
      photosReport:
          (json['photosReport'] as List<dynamic>?)
              ?.map((e) => EvidencePhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      photosReportCount: _parseInt(json['photosReportCount']),
      photosResolution:
          (json['photosResolution'] as List<dynamic>?)
              ?.map((e) => EvidencePhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      photosResolutionCount: _parseInt(json['photosResolutionCount']),
      historyRecent:
          (json['historyRecent'] as List<dynamic>?)
              ?.map((e) => IncidentHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      openDays: _parseInt(json['openDays']),
      pendingDays: _parseInt(json['pendingDays']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Helper para convertir String | int | null a int de forma segura
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'incidentId': incidentId,
      'connectionId': connectionId,
      'incidentCode': incidentCode,
      'readingId': readingId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'incidentTypeId': incidentTypeId,
      'incidentTypeName': incidentTypeName,
      'suggestedPriority': suggestedPriority,
      'reportDescription': reportDescription,
      'referenceAddress': referenceAddress,
      'status': status,
      'reportOrigin': reportOrigin,
      'currentPriority': currentPriority,
      'reportDate': reportDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'reportedBy': reportedBy.toJson(),
      'company': company?.toJson(),
      'person': person?.toJson(),
      'resolutionDate': resolutionDate?.toIso8601String(),
      'resolvedBy': resolvedBy?.toJson(),
      'resolutionDescription': resolutionDescription,
      'chargeToUser': chargeToUser,
      'repairCost': repairCost,
      'photosReport': photosReport.map((e) => e.toJson()).toList(),
      'photosReportCount': photosReportCount,
      'photosResolution': photosResolution.map((e) => e.toJson()).toList(),
      'photosResolutionCount': photosResolutionCount,
      'historyRecent': historyRecent.map((e) => e.toJson()).toList(),
      'openDays': openDays,
      'pendingDays': pendingDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
