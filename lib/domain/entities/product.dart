import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String brand;
  final String capacity;
  final double price;
  final double rating;
  final List<String> features;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.brand,
    required this.capacity,
    required this.price,
    required this.rating,
    required this.features,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        capacity,
        price,
        rating,
        features,
        imageUrl,
      ];
}
