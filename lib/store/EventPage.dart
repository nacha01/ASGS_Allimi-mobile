import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('이벤트가 없습니다!'),
      ),
    );
  }
}
