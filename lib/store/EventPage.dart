import 'package:asgshighschool/store/qr_test.dart';
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
      body: Column(
        children: [
          QrImage(data: '테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트'
              '테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트'
              '테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트테스트',),
          Center(
            child: FlatButton(
              child: Text('go'),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => QRTest())),
            ),
          ),
        ],
      ),
    );
  }
}
