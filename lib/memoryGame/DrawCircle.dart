import 'dart:ui';
import 'package:flutter/material.dart';

class CircleShape extends CustomPainter {
  Paint _painter;
  double _size;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(_size, _size), _size, _painter);
    // 2nd argument : radius!!...
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  CircleShape(Color color, double size) {
    this._size = size;
    _painter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }
}
