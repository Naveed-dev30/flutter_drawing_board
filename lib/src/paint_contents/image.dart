import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';

import '../../paint_contents.dart';

class ImageContent extends PaintContent {
  ImageContent(this.info);

  final PictureInfo info;

  @override
  PaintContent copy() {
    return ImageContent(info);
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    canvas.drawPicture(info.picture);
  }

  @override
  void drawing(Offset nowPoint) {}

  @override
  void startDraw(Offset startPoint) {}

  @override
  Map<String, dynamic> toContentJson() {
    return {};
  }

  @override
  bool contains(Offset point) {
    return false;
  }
}
