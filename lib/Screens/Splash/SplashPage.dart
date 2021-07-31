// Script
import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:asgshighschool/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Plugins
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Flutter Default Setting
import 'package:flutter/cupertino.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key, this.token}) : super(key: key);
  static const routeName = '/SplashPage';
  var token;
  @override
  _SplashPageState createState() => _SplashPageState();
}

String _message = '';

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    loading();
  }

  loading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _message = 'Network Connect...';
    });
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)
    => SignInPage(token: widget.token,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(),
            Text(
              '안산강서고 알리미',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            Text(
              '$_message',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Copyright 테라바이트',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
