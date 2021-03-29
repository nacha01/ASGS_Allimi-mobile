import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignOutPage extends StatefulWidget {
  @override
  _SignOutPageState createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign Out Page'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            FirebaseAuth.instance
                .signOut()
                .then((value) => {
                      Navigator.pop(context),
                    })
                .catchError((e) {
              print(e);
            });
          },
          color: Colors.orangeAccent,
          child: Text('Logout ', style: TextStyle(fontSize: 17.0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}
