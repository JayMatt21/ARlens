import '../repositories/app_repository.dart';
import '../entities/service.dart';

class GetServices {
  final AppRepository repository;
  GetServices(this.repository);

  Future<List<Service>> call() {
    return repository.getServices();
  }
}
