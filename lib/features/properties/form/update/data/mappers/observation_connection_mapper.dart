import 'package:app_properties/features/properties/form/update/data/models/dto/request/create_observation_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';

class ObservationConnectionMapper {
  static Map<String, dynamic> toJson(CreateObservationRequest request) {
    return {
      'connectionId': request.connectionId,
      'observationTitle': request.observationTitle,
      'observationDetails': request.observationDetails,
      // Map other fields as needed
    };
  }

  static CreateObservationRequest fromJson(Map<String, dynamic> json) {
    return CreateObservationRequest(
      connectionId: json['connectionId'],
      observationTitle: json['observationTitle'],
      observationDetails: json['observationDetails'],
      // Map other fields as needed
    );
  }

  static CreateObservationRequest toCreateObservationConnectionRequest(
    CreateObservationParams params,
  ) {
    return CreateObservationRequest(
      connectionId: params.connectionId,
      observationTitle: params.observationTitle,
      observationDetails: params.observationDetails,
    );
  }
}
