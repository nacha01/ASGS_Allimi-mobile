import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

class AnnouncePage extends StatefulWidget {
  AnnouncePage({this.user});
  final User user;
  @override
  _AnnouncePageState createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('소식'),),
    );
  }
}
