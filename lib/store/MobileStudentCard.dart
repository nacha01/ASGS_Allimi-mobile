import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MobileStudentCard extends StatefulWidget {
  @override
  _MobileStudentCardState createState() => _MobileStudentCardState();
}

class _MobileStudentCardState extends State<MobileStudentCard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text('Mobile Student Card')
      ),
      body : QrImage(
        data : 'https://www.google.com',
        size : 250,
      )
    );
  }
}