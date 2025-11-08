import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';

class AddObservationConnectionUseCase {
  final ObservationConnectionRepository repository;

  AddObservationConnectionUseCase(this.repository);
  Future<void> call({required CreateObservationParams params}) async {
    return await repository.addObservationConnection(params: params);
  }
}