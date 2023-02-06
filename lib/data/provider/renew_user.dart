import 'package:asgshighschool/data/user.dart';
import 'package:flutter/widgets.dart';

class RenewUserData extends ChangeNotifier {
  User _user;

  User get user => _user;

  RenewUserData(this._user);

  void setNewUser(User value) {
    _user = value;
    notifyListeners();
  }
}
