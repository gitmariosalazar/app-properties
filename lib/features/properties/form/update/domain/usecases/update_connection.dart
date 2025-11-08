import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';

class UpdateConnectionUseCase {
  final ConnectionRepository repository;

  UpdateConnectionUseCase(this.repository);

  Future<void> call({
    required String connectionId,
    required UpdateConnectionParams params,
  }) {
    return repository.updateConnection(
      connectionId: connectionId,
      params: params,
    );
  }
}
