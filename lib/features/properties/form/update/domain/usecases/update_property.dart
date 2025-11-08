import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';

class UpdatePropertyUseCase {
  final PropertyRepository repository;

  UpdatePropertyUseCase(this.repository);

  Future<void> call({
    required String cadastralKey,
    required UpdatePropertyParams params,
  }) {
    return repository.updateProperty(
      cadastralKey: cadastralKey,
      params: params,
    );
  }
}
