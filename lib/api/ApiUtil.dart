import 'dart:convert';
import 'dart:typed_data';

class ApiUtil {
  static const API_HOST = "http://nacha01.dothome.co.kr/sin/";

  static String getPureBody(Uint8List bodyBytes) {
    return utf8
        .decode(bodyBytes)
        .replaceAll(
            '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
            '')
        .trim();
  }
}
