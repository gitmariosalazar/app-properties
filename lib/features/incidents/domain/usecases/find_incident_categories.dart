import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentCategoriesUseCase
    implements UseCase<List<IncidentCategoryModel>, NoParams> {
  final IncidentRepository repository;

  FindIncidentCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentCategoryModel>>> call(NoParams params) {
    return repository.findIncidentCategories();
  }
}
