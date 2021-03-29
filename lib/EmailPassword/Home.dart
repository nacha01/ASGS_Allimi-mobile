import 'package:flutter/material.dart';
import 'SignIn.dart';
import 'SignOut.dart';
import 'SignUp.dart';

class EmailPasswordAuth extends StatelessWidget {
  //  /EmailPasswordAuth/SignIn
  //  /home
  static const routeName = '/EmailPasswordAuth';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.orange),
      home: SignInPage(),
      // routes: {
      //   // '/SignUP': (context) => SignUp(),
      //   // ======== OR we can Write ======== //
      //   // '/SignIn': (_) => SignInPage(),
      //   // '/SignUp': (_) => SignUpPage(),
      //   // '/SignOut': (_) => SignOutPage(),
      // },
    );
  }
}
