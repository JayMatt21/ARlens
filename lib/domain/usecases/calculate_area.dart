import 'package:arlens/domain/entities/point_entity.dart';

class CalculateAreaUseCase {

  double execute(List<PointEntity> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length]; 
      area += (p1.x * p2.y) - (p2.x * p1.y);
    }

    return area.abs() / 2.0;
  }
}
