import 'dart:ui';
import 'package:flutter/material.dart';

class RectangleShape extends CustomPainter {
  Paint _painter;
  double _size;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset(0, 0) & Size(_size, _size), _painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  RectangleShape(Color color, double size) {
    this._size = size;
    _painter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

}
