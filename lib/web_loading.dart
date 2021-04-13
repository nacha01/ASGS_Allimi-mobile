import 'package:flutter/foundation.dart';
import 'package:intl/number_symbols_data.dart';

class LoadingData with ChangeNotifier {
  bool _loading = false;
  get loading => _loading;

  void toggle() {
    _loading = !_loading;
    notifyListeners();
  }
}
