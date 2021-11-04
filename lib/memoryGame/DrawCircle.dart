import 'dart:ui';
import 'package:flutter/material.dart';

class CircleShape extends CustomPainter {
  Paint _painter;
  double _size;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBorder = Paint()
    ..color = Colors.grey
    ..strokeWidth = _size * 0.1
    ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(_size, _size), _size, _painter);
    canvas.drawCircle(Offset(_size, _size), _size, paintBorder);

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
