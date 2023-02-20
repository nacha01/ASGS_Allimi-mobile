import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/user.dart';
import 'StoreMainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StoreSplashPage extends StatefulWidget {
  final User? user;

  StoreSplashPage({this.user});

  @override
  _StoreSplashPageState createState() => _StoreSplashPageState();
}

class _StoreSplashPageState extends State<StoreSplashPage> {
  @override
  void initState() {
    super.initState();
    loading();
  }

  /// Splash 페이지의 로딩 process
  loading() async {
    var res = await _checkExistCart();
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StoreMainPage(
                  user: widget.user,
                  existCart: res,
                )));
  }

  /// 장바구니에 데이터가 존재하는지 체크 요청을 하는 작업
  Future<bool> _checkExistCart() async {
    String url = '${ApiUtil.API_HOST}arlimi_checkCart.php';
    final response =
        await http.get(Uri.parse(url + '?uid=${widget.user!.uid}'));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (int.parse(result) >= 1) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            alignment: Alignment.center,
            color: Color(0xFF9EE1E5),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/duruduru_logo.png',
                          fit: BoxFit.fill,
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Text(
                          widget.user!.isAdmin ? '관리자 권한으로 접근합니다...' : '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(
                          height: size.height * 0.06,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
