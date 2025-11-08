// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_observation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateObservationRequest _$CreateObservationRequestFromJson(
  Map<String, dynamic> json,
) => CreateObservationRequest(
  connectionId: json['connectionId'] as String,
  observationTitle: json['observationTitle'] as String,
  observationDetails: json['observationDetails'] as String,
);

Map<String, dynamic> _$CreateObservationRequestToJson(
  CreateObservationRequest instance,
) => <String, dynamic>{
  'connectionId': instance.connectionId,
  'observationTitle': instance.observationTitle,
  'observationDetails': instance.observationDetails,
};
