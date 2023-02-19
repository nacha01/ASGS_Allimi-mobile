import 'package:flutter/material.dart';

class AuthFrameComp extends StatefulWidget {
  const AuthFrameComp({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  State<AuthFrameComp> createState() => _AuthFrameCompState();
}

class _AuthFrameCompState extends State<AuthFrameComp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color(0xFFF9F7F8),
              Color(0xFFF9F7F8),
              Colors.lightBlue[100]!
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.children)),
    );
  }
}
