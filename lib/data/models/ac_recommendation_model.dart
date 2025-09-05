import 'package:arlens/domain/entities/ac_recommendation.dart' as entity;

class ACRecommendationModel {
  final String id;
  final double recommendedHp;
  final String roomType;
  final String usageLevel;
  final String suggestedModel;
  final String notes;

  ACRecommendationModel({
    required this.id,
    required this.recommendedHp,
    required this.roomType,
    required this.usageLevel,
    required this.suggestedModel,
    required this.notes,
  });

  factory ACRecommendationModel.fromJson(Map<String, dynamic> json) =>
      ACRecommendationModel(
        id: json['id'] as String,
        recommendedHp: (json['recommended_hp'] as num).toDouble(),
        roomType: json['room_type'] as String,
        usageLevel: json['usage_level'] as String,
        suggestedModel: json['suggested_model'] as String,
        notes: (json['notes'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'recommended_hp': recommendedHp,
        'room_type': roomType,
        'usage_level': usageLevel,
        'suggested_model': suggestedModel,
        'notes': notes,
      };

  // convert to domain entity
  entity.ACRecommendation toEntity() => entity.ACRecommendation(
        id: id,
        recommendedHp: recommendedHp,
        roomType: roomType,
        usageLevel: usageLevel,
        suggestedModel: suggestedModel,
        notes: notes,
      );

  // create model from entity
  factory ACRecommendationModel.fromEntity(entity.ACRecommendation e) =>
      ACRecommendationModel(
        id: e.id,
        recommendedHp: e.recommendedHp,
        roomType: e.roomType,
        usageLevel: e.usageLevel,
        suggestedModel: e.suggestedModel,
        notes: e.notes,
      );
}
