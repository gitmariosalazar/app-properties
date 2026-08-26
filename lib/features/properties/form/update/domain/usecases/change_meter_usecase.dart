import 'package:app_properties/features/properties/form/update/data/models/dto/request/change_meter_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';

class ChangeMeterUseCase {
  final ConnectionRepository repository;

  ChangeMeterUseCase(this.repository);

  Future<void> call(ChangeMeterRequest request) async {
    return await repository.changeMeter(request);
  }
}
