import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Equatable {
  final String id;
  final String brand;
  final String capacity;
  final double price;
  final double rating;
  final List<String> features;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.brand,
    required this.capacity,
    required this.price,
    required this.rating,
    required this.features,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      capacity: json['capacity'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      features: json['features'] != null 
          ? List<String>.from(json['features']['features'] ?? [])
          : [],
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'capacity': capacity,
      'price': price,
      'rating': rating,
      'features': {'features': features},
      'image_url': imageUrl,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      brand: brand,
      capacity: capacity,
      price: price,
      rating: rating,
      features: features,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, brand, capacity, price, rating, features, imageUrl];
}