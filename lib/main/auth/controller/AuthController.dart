import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import '../../../data/status.dart';
import '../../../data/user.dart';
import 'package:http/http.dart' as http;

import '../../../util/GlobalVariable.dart';

class AuthController {
  Future<User?> requestLogin(String uid, String password) async {
    String url = '${ApiUtil.API_HOST}arlimi_login.php?uid=$uid&pw=$password';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (utf8.decode(response.bodyBytes).contains('NOT EXIST ACCOUNT')) {
        return null;
      }

      String result = ApiUtil.getPureBody(response.bodyBytes);
      return User.fromJson(json.decode(result));
    } else {
      return null;
    }
  }

  Future<bool> updateEmailRequest(String uid, String email) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateEmail.php';
    final response = await http.post(Uri.parse(url),
        body: <String, String>{'uid': uid, 'email': email});

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('UPDATED')) {
        return true;
      }
    }
    return false;
  }

  Future<String> judgeIsAdminAccount(String uid) async {
    String url = '${ApiUtil.API_HOST}arlimi_isAdmin.php?uid=$uid';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body.contains('ADMIN')) {
        String result = ApiUtil.getPureBody(response.bodyBytes);
        result = result.replaceAll('ADMIN', '').trim();
        return result;
      }
    }
    return "";
  }

  Future<String> getFoundUserID(String name, String email, String grade) async {
    String url = '${ApiUtil.API_HOST}arlimi_findUserID.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'name': name,
      'email': email,
      'grade': grade.isEmpty ? 'X' : grade
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('NOT FOUND')) {
        return '해당하는 ID가 존재하지 않습니다!';
      } else {
        return result;
      }
    } else {
      return '아이디 요청 실패';
    }
  }

  Future<bool> changeRandomPassword(
      String uid, String email, String name, String grade, String pw) async {
    String url = '${ApiUtil.API_HOST}arlimi_changePasswordForFind.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'uid': uid,
      'email': email,
      'name': name,
      'grade': grade.isEmpty ? 'X' : grade,
      'password': pw
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('UPDATED')) {
        return true;
      }
    }
    return false;
  }

  Future<bool> postRegisterRequest(String uid, String password, String name,
      String nickname, String status, String grade, String email) async {
    String url = '${ApiUtil.API_HOST}arlimi_register.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'uid': uid,
      'pw': password,
      'token': GlobalVariable.token,
      'name': name,
      'nickname': nickname,
      'identity': Status.statusMap[status].toString(),
      'student_id': grade,
      'email': email
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('PRIMARY') && result.contains('Duplicate entry')) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
}
