import 'package:arlens/domain/entities/service.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final Duration estimatedDuration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.estimatedDuration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        basePrice: (json['base_price'] as num).toDouble(),
        estimatedDuration: Duration(minutes: json['estimated_duration']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'base_price': basePrice,
        'estimated_duration': estimatedDuration.inMinutes,
      };

  /// 🔑 Convert to domain entity
  Service toEntity() => Service(
        id: id,
        name: name,
        description: description,
        basePrice: basePrice,
        estimatedDuration: estimatedDuration,
      );
}
