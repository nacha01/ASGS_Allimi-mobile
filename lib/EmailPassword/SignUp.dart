import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

////////////////// SIGN UP PAGE ////////////////////////////

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String email;
  String password;
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign Up Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              cursorColor: Colors.black,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.orange.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                prefixIcon: Icon(Icons.account_circle),
                labelText: 'Email',
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              obscureText: true,
              cursorColor: Colors.black,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.orange.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                prefixIcon: Icon(Icons.vpn_key),
                labelText: 'Password',
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            RaisedButton(
              onPressed: () async {
                _auth
                    .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                )
                    .then((signedInUser) {
                  _fireStore.collection('users').add(
                      {'email': email, 'password': password}).then((value) {
                    if (signedInUser != null) {
                      Navigator.pushNamed(context, '/SignOut');
                    }
                  }).catchError((e) {
                    print(e);
                  });
                }).catchError((e) {
                  print(e);
                });
              },
              color: Colors.orangeAccent,
              child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
            ),
          ],
        ),
      ),
    );
  }
}

/*RaisedButton(
            onPressed: () async {
              try {
                final newUser = await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                if (newUser != null) {
                  Navigator.pushNamed(context, '/SignIn');
                }
              } catch (e) {
                print(e);
              }
            },
            color: Colors.orangeAccent,
            child: Text('Sign Up ', style: TextStyle(fontSize: 17.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),*/
