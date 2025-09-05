import 'package:equatable/equatable.dart';

class ACRecommendation extends Equatable {
  final String id;
  final double recommendedHp;
  final String roomType;
  final String usageLevel;
  final String suggestedModel;
  final String notes;

  const ACRecommendation({
    required this.id,
    required this.recommendedHp,
    required this.roomType,
    required this.usageLevel,
    required this.suggestedModel,
    required this.notes,
  });

  @override
  List<Object?> get props => [
    id, recommendedHp, roomType, usageLevel, suggestedModel, notes
  ];
}