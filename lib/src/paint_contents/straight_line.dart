import 'package:flutter/painting.dart';
import '../paint_extension/ex_offset.dart';
import '../paint_extension/ex_paint.dart';

import 'paint_content.dart';

/// 直线
class StraightLine extends PaintContent {
  StraightLine();

  StraightLine.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory StraightLine.fromJson(Map<String, dynamic> data) {
    return StraightLine.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  late Offset startPoint;
  late Offset endPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) =>
      canvas.drawLine(startPoint, endPoint, paint);

  @override
  StraightLine copy() => StraightLine();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }

  @override
  bool contains(Offset point) {
    final double threshold = 5.0; // Adjust as needed

    double distance = pointLineDistance(point, startPoint, endPoint);

    return distance <= threshold;
  }

  double pointLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    double lengthSquared = (lineEnd - lineStart).distanceSquared;
    if (lengthSquared == 0.0) {
      return (point - lineStart).distance;
    }

    double t = ((point - lineStart).dx * (lineEnd - lineStart).dx +
            (point - lineStart).dy * (lineEnd - lineStart).dy) /
        lengthSquared;

    t = t.clamp(0.0, 1.0);

    Offset projection = Offset.lerp(lineStart, lineEnd, t)!;

    return (point - projection).distance;
  }
}
