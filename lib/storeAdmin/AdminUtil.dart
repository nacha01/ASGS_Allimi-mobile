import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:http/http.dart' as http;

class AdminUtil {
  static Future<bool> certifyAdminAccess(String uid, String inputKey) async {
    String url = '${ApiUtil.API_HOST}arlimi_adminCertified.php';
    final response = await http.post(Uri.parse(url),
        body: <String, String>{'uid': uid, 'key': inputKey});

    if (response.statusCode == 200) {
      if (response.body.contains('CERTIFIED')) {
        return true;
      }
    }
    return false;
  }

}
