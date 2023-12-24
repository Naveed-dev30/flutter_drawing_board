import 'package:flutter/material.dart';

abstract class PaintContent {
  PaintContent();

  PaintContent.paint(this.paint);

  late Paint paint;

  PaintContent copy();

  void draw(Canvas canvas, Size size, bool deeper);

  void drawing(Offset nowPoint);

  void startDraw(Offset startPoint);

  Map<String, dynamic> toContentJson();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
      ...toContentJson(),
    };
  }

  // Add the contains method to check if a point is within the content area
  bool contains(Offset point);
}
