import 'package:equatable/equatable.dart';

class ReportClient {
  final String firstName;
  final String lastName;
  final String? email;
  final String? cellPhone;

  ReportClient({
    required this.firstName,
    required this.lastName,
    this.email,
    this.cellPhone,
  });

  // Constructor de utilidad si vas a recibir esto desde un JSON (API)
  factory ReportClient.fromJson(Map<String, dynamic> json) {
    return ReportClient(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      cellPhone: json['cellPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'cellPhone': cellPhone,
    };
  }
}

class IncidentCoordinates extends Equatable {
  final double lat;
  final double lng;

  const IncidentCoordinates({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];

  factory IncidentCoordinates.fromJson(Map<String, dynamic> json) {
    return IncidentCoordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}

class IncidentEvidencePhoto extends Equatable {
  final int photoId;
  final String filePath;
  final String type;

  const IncidentEvidencePhoto({
    required this.photoId,
    required this.filePath,
    required this.type,
  });

  @override
  List<Object?> get props => [photoId, filePath, type];

  factory IncidentEvidencePhoto.fromJson(Map<String, dynamic> json) {
    return IncidentEvidencePhoto(
      photoId: json['photoId'] as int? ?? 0,
      filePath: json['filePath'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'photoId': photoId, 'filePath': filePath, 'type': type};
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

class IncidentStatusHistory extends Equatable {
  final DateTime changeDate;
  final String? previousStatus;
  final String newStatus;
  final ManagedByUser? managedBy;
  final String? observation;

  const IncidentStatusHistory({
    required this.changeDate,
    this.previousStatus,
    required this.newStatus,
    this.managedBy,
    this.observation,
  });

  @override
  List<Object?> get props => [
    changeDate,
    previousStatus,
    newStatus,
    managedBy,
    observation,
  ];

  factory IncidentStatusHistory.fromJson(Map<String, dynamic> json) {
    return IncidentStatusHistory(
      changeDate: json['changeDate'] != null
          ? DateTime.tryParse(json['changeDate'] as String) ?? DateTime.now()
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
      'changeDate': changeDate.toIso8601String(),
      'previousStatus': previousStatus,
      'newStatus': newStatus,
      'managedBy': managedBy,
      'observation': observation,
    };
  }
}

class IncidentModel extends Equatable {
  final String incidentId;
  final String? connectionId;
  final String incidentCode;
  final int? readingId;
  final int incidentTypeId;
  final String reportDescription;
  final String? referenceAddress;
  final String
  status; // 'REPORTADO', 'EN_INSPECCION', 'RESUELTO', 'FALSO_REPORTE'
  final String
  reportOrigin; // 'LECTURISTA', 'ATENCION_AL_CLIENTE', 'INSPECTOR', 'WEB_USUARIO'
  final String priority; // 'BAJA', 'MEDIA', 'ALTA', 'CRITICA'
  final DateTime reportDate;
  final String? reporterUserId;
  final String? clienteUsuarioReportaId;
  final IncidentCoordinates? coordinates;

  // Resolution fields
  final DateTime? resolutionDate;
  final String? resolverUserId;
  final String? resolutionDescription;

  // Financial and billing parameters
  final bool chargeToUser;
  final double repairCost;

  // Rich query-only fields
  final String? categoryName;
  final String? categoryCode;
  final String? incidentTypeName;
  final String? suggestedPriority;
  final String? reportedBy;
  final List<IncidentEvidencePhoto>? evidencePhotos;
  final List<IncidentStatusHistory>? statusHistory;
  final ReportClient? reportClient;

  const IncidentModel({
    required this.incidentId,
    this.connectionId,
    required this.incidentCode,
    this.readingId,
    required this.incidentTypeId,
    required this.reportDescription,
    this.referenceAddress,
    required this.status,
    required this.reportOrigin,
    required this.priority,
    required this.reportDate,
    this.reporterUserId,
    this.clienteUsuarioReportaId,
    this.coordinates,
    this.resolutionDate,
    this.resolverUserId,
    this.resolutionDescription,
    required this.chargeToUser,
    required this.repairCost,
    this.categoryName,
    this.categoryCode,
    this.incidentTypeName,
    this.suggestedPriority,
    this.reportedBy,
    this.evidencePhotos,
    this.statusHistory,
    this.reportClient,
  });

  bool isChargeableToUser() {
    return chargeToUser && repairCost > 0;
  }

  @override
  List<Object?> get props => [
    incidentId,
    connectionId,
    incidentCode,
    readingId,
    incidentTypeId,
    reportDescription,
    referenceAddress,
    status,
    reportOrigin,
    priority,
    reportDate,
    reporterUserId,
    clienteUsuarioReportaId,
    coordinates,
    resolutionDate,
    resolverUserId,
    resolutionDescription,
    chargeToUser,
    repairCost,
    categoryName,
    categoryCode,
    incidentTypeName,
    suggestedPriority,
    reportedBy,
    evidencePhotos,
    statusHistory,
    reportClient,
  ];

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      incidentId: json['incidentId'] as String? ?? '',
      connectionId: json['connectionId'] as String?,
      incidentCode: json['incidentCode'] as String? ?? '',
      readingId: json['readingId'] as int?,
      incidentTypeId: json['incidentTypeId'] as int? ?? 0,
      reportDescription: json['reportDescription'] as String? ?? '',
      referenceAddress: json['referenceAddress'] as String?,
      status: json['status'] as String? ?? '',
      reportOrigin: json['reportOrigin'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      reportDate: json['reportDate'] != null
          ? DateTime.tryParse(json['reportDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      reporterUserId: json['reporterUserId'] as String?,
      clienteUsuarioReportaId: json['clienteUsuarioReportaId'] as String?,
      coordinates: json['coordinates'] != null
          ? IncidentCoordinates.fromJson(
              json['coordinates'] as Map<String, dynamic>,
            )
          : (json['latitude'] != null && json['longitude'] != null)
          ? IncidentCoordinates(
              lat: (json['latitude'] as num).toDouble(),
              lng: (json['longitude'] as num).toDouble(),
            )
          : null,
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.tryParse(json['resolutionDate'] as String)
          : null,
      resolverUserId: json['resolverUserId'] as String?,
      resolutionDescription: json['resolutionDescription'] as String?,
      chargeToUser: json['chargeToUser'] as bool? ?? false,
      repairCost: (json['repairCost'] as num?)?.toDouble() ?? 0.0,
      categoryName: json['categoryName'] as String?,
      categoryCode: json['categoryCode'] as String?,
      incidentTypeName: json['incidentTypeName'] as String?,
      suggestedPriority: json['suggestedPriority'] as String?,
      reportedBy: json['reportedBy'] as String?,
      evidencePhotos: (json['evidencePhotos'] as List<dynamic>?)
          ?.map(
            (e) => IncidentEvidencePhoto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map(
            (e) => IncidentStatusHistory.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      reportClient: json['reportClient'] != null
          ? ReportClient.fromJson(json['reportClient'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incidentId': incidentId,
      'connectionId': connectionId,
      'incidentCode': incidentCode,
      'readingId': readingId,
      'incidentTypeId': incidentTypeId,
      'reportDescription': reportDescription,
      'referenceAddress': referenceAddress,
      'status': status,
      'reportOrigin': reportOrigin,
      'priority': priority,
      'reportDate': reportDate.toIso8601String(),
      'reporterUserId': reporterUserId,
      'clienteUsuarioReportaId': clienteUsuarioReportaId,
      'coordinates': coordinates?.toJson(),
      'latitude': coordinates?.lat,
      'longitude': coordinates?.lng,
      'resolutionDate': resolutionDate?.toIso8601String(),
      'resolverUserId': resolverUserId,
      'resolutionDescription': resolutionDescription,
      'chargeToUser': chargeToUser,
      'repairCost': repairCost,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'incidentTypeName': incidentTypeName,
      'suggestedPriority': suggestedPriority,
      'reportedBy': reportedBy,
      'evidencePhotos': evidencePhotos?.map((e) => e.toJson()).toList(),
      'statusHistory': statusHistory?.map((e) => e.toJson()).toList(),
      'reportClient': reportClient?.toJson(),
    };
  }
}
