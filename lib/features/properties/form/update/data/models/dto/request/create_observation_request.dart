import 'package:json_annotation/json_annotation.dart';

part 'create_observation_request.g.dart';

@JsonSerializable()
class CreateObservationRequest {
  final String connectionId;
  final String observationTitle;
  final String observationDetails;

  CreateObservationRequest({
    required this.connectionId,
    required this.observationTitle,
    required this.observationDetails,
  });

  factory CreateObservationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateObservationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateObservationRequestToJson(this);
}
