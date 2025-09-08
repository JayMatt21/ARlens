import 'package:flutter_bloc/flutter_bloc.dart';
import 'products_event.dart';
import 'products_state.dart';
import '../../../domain/usecases/get_products.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  ProductsBloc({required this.getProducts}) : super(ProductsInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final products = await getProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
