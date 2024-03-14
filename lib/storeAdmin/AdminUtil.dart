import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../component/DefaultButtonComp.dart';
import '../data/user.dart';
import '../util/ToastMessage.dart';

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

  static void showCertifyDialog(
      {required BuildContext context,
      required TextEditingController keyController, // 입력 컨트롤러
      required User admin, // 어드민 계정
      required Future<void> Function() afterProcess // 인증 후 처리
      }) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('관리자 Key 인증'),
              content: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.orange[200]!),
                    color: Colors.blue[100]),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Admin Key',
                  ),
                  obscureText: true,
                  controller: keyController,
                ),
              ),
              actions: [
                DefaultButtonComp(
                    onPressed: () => Navigator.pop(ctx), child: Text('취소')),
                DefaultButtonComp(
                    onPressed: () async {
                      var result = await AdminUtil.certifyAdminAccess(
                          admin.uid!, keyController.text);
                      if (result) {
                        Navigator.pop(ctx);
                        await afterProcess();
                      } else {
                        ToastMessage.show("경고: 인증에 실패했습니다.");
                      }
                      keyController.clear();
                    },
                    child: Text('인증')),
              ],
            ));
  }
}
