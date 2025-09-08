import '../repositories/app_repository.dart';
import '../entities/product.dart';

class GetProducts {
  final AppRepository repository;
  GetProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}
