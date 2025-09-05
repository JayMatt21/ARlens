import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final Duration estimatedDuration;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.estimatedDuration,
  });

  @override
  List<Object?> get props => [
    id, name, description, basePrice, estimatedDuration
  ];
}