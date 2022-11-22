import 'package:flutter/cupertino.dart';

class ExistCart extends ChangeNotifier {
  bool _isExistCart = false;

  bool get isExistCart => _isExistCart;

  set isExistCart(bool value) {
    _isExistCart = value;
    notifyListeners();
  }

  void setExistCart(bool value) {
    _isExistCart = value;
    notifyListeners();
  }

  void toggle() {
    _isExistCart = !_isExistCart;
    notifyListeners();
  }
}
