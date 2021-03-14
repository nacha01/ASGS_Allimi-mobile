import 'package:flutter/material.dart';
//15분

class ScreenSecond extends StatefulWidget {
  final String payload;
  ScreenSecond({this.payload});

  @override
  _ScreenSecondState createState() => _ScreenSecondState();
}

class _ScreenSecondState extends State<ScreenSecond> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen Second'),
      ),
      body: Center(
        child: Text(widget.payload),
      ),
    );
  }
}
