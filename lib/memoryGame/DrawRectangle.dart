import 'dart:ui';
import 'package:flutter/material.dart';

class RectangleShape extends CustomPainter {
  Paint _painter;
  double _size;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBorder = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = _size * 0.1;
    canvas.drawRect(Offset(0, 0) & Size(_size, _size), _painter);
    canvas.drawRect(Offset(0,0) & Size(_size, _size), paintBorder);
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
