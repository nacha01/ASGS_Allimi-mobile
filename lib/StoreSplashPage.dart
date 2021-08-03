import 'package:asgshighschool/StoreMainPage.dart';
import 'package:flutter/material.dart';

class StoreSplashPage extends StatefulWidget {
  final user;
  StoreSplashPage({this.user});
  @override
  _StoreSplashPageState createState() => _StoreSplashPageState();
}

class _StoreSplashPageState extends State<StoreSplashPage> {
  @override
  void initState() {
    super.initState();
    loading();
  }
  loading() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)
    => StoreMainPage(user: widget.user,)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(color: Color(0xFF9EE1E5),child: Text('텍스트 및 로고'),),
      ],)
    );
  }
}
