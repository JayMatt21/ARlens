import '../entities/service.dart';
import '../repositories/app_repository.dart';

class GetServices {
  final AppRepository repository;

  GetServices(this.repository);

  Future<List<Service>> call() {
    return repository.getServices();
  }
}