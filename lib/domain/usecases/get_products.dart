import '../entities/product.dart';
import '../repositories/app_repository.dart';

class GetProduct {
  final AppRepository repository;

  GetProduct(this.repository);

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}