import 'dart:ui';
import 'package:flutter/material.dart';

class TriangleShape extends CustomPainter {
  Paint _painter;
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();

    canvas.drawPath(path, _painter);

    Paint paintBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    canvas.drawPath(path, paintBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  TriangleShape(Color color) {
    _painter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }
}
