import 'package:flutter/material.dart';

class DefaultButtonComp extends StatefulWidget {
  const DefaultButtonComp(
      {Key? key,
      required this.onPressed,
      required this.child,
      this.padding,
      this.onLongPress})
      : super(key: key);
  final void Function()? onPressed;
  final Widget child;
  final double? padding;
  final void Function()? onLongPress;

  @override
  State<DefaultButtonComp> createState() => _DefaultButtonCompState();
}

class _DefaultButtonCompState extends State<DefaultButtonComp> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: widget.child,
      style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          padding:
              widget.padding == null ? null : EdgeInsets.all(widget.padding!)),
    );
  }
}
