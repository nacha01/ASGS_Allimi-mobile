import 'package:flutter/material.dart';
import 'EmailPassword/../SignIn.dart';
import 'EmailPassword/../SignOut.dart';
import 'EmailPassword/../SignUp.dart';

class EmailPasswordAuth extends StatelessWidget {
  EmailPasswordAuth({Key key, this.books}) : super(key: key);
  var books;
  static const routeName = '/EmailPasswordAuth';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.orange),
      home: SignInPage(books: books),
      routes: {
        // '/SignUP': (context) => SignUp(),
        // ======== OR we can Write ======== //
        '/SignIn': (_) => SignInPage(
              books: books,
            ),
        '/SignUp': (_) => SignUpPage(),
        '/SignOut': (_) => SignOutPage(),
      },
    );
  }
}
