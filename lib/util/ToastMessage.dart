import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage {
  static void show(String message, {bool isLong = false}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: isLong ? Toast.LENGTH_SHORT : Toast.LENGTH_SHORT);
  }
}
