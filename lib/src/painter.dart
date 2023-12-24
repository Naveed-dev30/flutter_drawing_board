import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';
import 'paint_contents/image.dart';
import 'paint_contents/paint_content.dart';

/// 绘图板
class Painter extends StatefulWidget {
  const Painter({
    super.key,
    required this.drawingController,
    this.clipBehavior = Clip.antiAlias,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
  });

  /// 绘制控制器
  final DrawingController drawingController;

  /// 开始拖动
  final Function(PointerDownEvent pde)? onPointerDown;

  /// 正在拖动
  final Function(PointerMoveEvent pme)? onPointerMove;

  /// 结束拖动
  final Function(PointerUpEvent pue)? onPointerUp;

  /// 边缘裁剪方式
  final Clip clipBehavior;

  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  /// 手指落下
  void _onPointerDown(PointerDownEvent pde) {
    if (!widget.drawingController.couldStart(1)) {
      return;
    }

    widget.drawingController.startDraw(pde.localPosition);
    widget.onPointerDown?.call(pde);
  }

  /// 手指移动
  void _onPointerMove(PointerMoveEvent pme) {
    if (!widget.drawingController.couldDraw) {
      if (widget.drawingController.currentContent != null) {
        widget.drawingController.endDraw();
      }
      return;
    }

    widget.drawingController.drawing(pme.localPosition);
    widget.onPointerMove?.call(pme);
  }

  /// 手指抬起
  void _onPointerUp(PointerUpEvent pue) {
    if (!widget.drawingController.couldDraw ||
        widget.drawingController.currentContent == null) {
      return;
    }

    if (widget.drawingController.startPoint == pue.localPosition) {
      widget.drawingController.drawing(pue.localPosition);
    }

    widget.drawingController.endDraw();
    widget.onPointerUp?.call(pue);
  }

  /// GestureDetector 占位
  void _onPanDown(DragDownDetails ddd) {}

  void _onPanUpdate(DragUpdateDetails dud) {}

  void _onPanEnd(DragEndDetails ded) {}

  Offset? tapPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      behavior: HitTestBehavior.opaque,
      child: ExValueBuilder<DrawConfig>(
        valueListenable: widget.drawingController.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) =>
            p.fingerCount != n.fingerCount,
        builder: (_, DrawConfig config, Widget? child) {
          return GestureDetector(
            onPanDown: config.fingerCount <= 1 ? _onPanDown : null,
            onPanUpdate: config.fingerCount <= 1 ? _onPanUpdate : null,
            onPanEnd: config.fingerCount <= 1 ? _onPanEnd : null,
            child: child,
          );
        },
        child: ClipRect(
          clipBehavior: widget.clipBehavior,
          child: RepaintBoundary(
            child: GestureDetector(
              onTapDown: (details){
                setState(() {
                  tapPosition = details.globalPosition;
                });
              },
              child: CustomPaint(
                painter: _DeepPainter(
                  controller: widget.drawingController,
                  context: context,
                  tapPosition: tapPosition,
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _UpPainter(controller: widget.drawingController),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 表层画板
class _UpPainter extends CustomPainter {
  _UpPainter({required this.controller}) : super(repaint: controller.painter);

  final DrawingController controller;

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.currentContent == null) {
      return;
    }

    controller.currentContent?.draw(canvas, size, false);
  }

  @override
  bool shouldRepaint(covariant _UpPainter oldDelegate) => false;
}

/// 底层画板
class _DeepPainter extends CustomPainter {
  _DeepPainter({
    required this.controller,
    required this.context,
    required this.tapPosition,
  }) : super(repaint: controller.realPainter);

  final DrawingController controller;
  final BuildContext context;
  final Offset? tapPosition; // Tap position provided externally

  @override
  void paint(Canvas canvas, Size size) {
    final List<PaintContent> contents = controller.getHistory;

    if (contents.isEmpty && controller.pictureInfo != null) {
      Future.delayed(Duration(milliseconds: 250)).then((value) {
        controller.addContent(ImageContent(controller.pictureInfo!));
      });
      return;
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    for (int i = 0; i < controller.currentIndex; i++) {
      contents[i].draw(canvas, size, true);
    }

    // Check if a tap occurred at the position of any element
    if (tapPosition != null) {
      for (int i = 0; i < controller.currentIndex; i++) {
        final PaintContent content = contents[i];
        if (content.contains(tapPosition!)) {
          // Change the color of the tapped element
          content.paint.color = Colors.purple;
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepPainter oldDelegate) => false;
}
