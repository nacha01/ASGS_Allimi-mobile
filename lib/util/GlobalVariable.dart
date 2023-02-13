import 'package:flutter/material.dart';

class GlobalVariable {
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey();
  static bool isAuthorized = false;
  static Color appThemeColor = Color(0xFF9EE1E5);
}
