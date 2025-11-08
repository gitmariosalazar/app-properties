abstract class ObservationConnectionRepository {
  Future<void> addObservationConnection({
    required CreateObservationParams params,
  });
}

class CreateObservationParams {
  final String connectionId;
  final String observationTitle;
  final String observationDetails;

  CreateObservationParams({
    required this.connectionId,
    required this.observationTitle,
    required this.observationDetails,
  });
}
