import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:flutter/material.dart';

class ThemeAppBar extends AppBar {
  ThemeAppBar(
      {Key? key,
      required this.barTitle,
      this.leadingClick,
      this.actions,
      this.allowLeading = true})
      : super(key: key);
  final String barTitle;
  final void Function()? leadingClick;
  final List<Widget>? actions;

  final bool allowLeading;

  @override
  State<ThemeAppBar> createState() => _ThemeAppBarState();
}

class _ThemeAppBarState extends State<ThemeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: GlobalVariable.appThemeColor,
      title: Text(
        widget.barTitle,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      centerTitle: true,
      leading: widget.allowLeading
          ? IconButton(
              onPressed: widget.leadingClick ?? () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            )
          : SizedBox(),
      actions: widget.actions,
    );
  }
}
