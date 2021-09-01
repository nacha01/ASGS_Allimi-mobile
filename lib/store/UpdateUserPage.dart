import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/UpdatePasswordPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

/// visible information
/// 1. uid
/// 2. name[modifiable]
/// 3. identity[modifiable]
/// 4. studentId[modifiable]
/// 5. nickname[modifiable]
/// 6. tel[modifiable]
/// 7. reg_date
/// 8. buy_count
/// 9. point
class UpdateUserPage extends StatefulWidget {
  UpdateUserPage({this.user});
  final User user;
  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final statusReverseList = ['재학생', '학부모', '교사', '졸업생', '기타'];
  TextEditingController _uidController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _studentIDController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _telController = TextEditingController();

  TextEditingController _pwController = TextEditingController();
  final statusList = ['재학생', '학부모', '교사', '졸업생', '기타'];
  final statusMap = {'재학생': 1, '학부모': 2, '교사': 3, '졸업생': 4, '기타': 5};
  var _selectedValue;
  void _initInfo() {
    _uidController.text = widget.user.uid;
    _nameController.text = widget.user.name;
    _studentIDController.text = widget.user.studentId;
    _nicknameController.text = widget.user.nickName;
    _telController.text = widget.user.tel;
    _selectedValue = statusList[widget.user.identity - 1];
  }

  Future<bool> _updateUserInfoRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_updateUser.php';
    final response = await http.post(url, body: <String, String>{
      'uid': widget.user.uid,
      'name': _nameController.text,
      'identity': statusMap[_selectedValue].toString(),
      'studentID': _studentIDController.text,
      'nickname': _nicknameController.text,
      'tel': _telController.text
    });

    if (response.statusCode == 200) {
      print(response.body);
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _certifyMyselfRequest() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_certifyMyself.php';
    final response = await http
        .get(uri + '?uid=${widget.user.uid}&pw=${_pwController.text}');

    if (response.statusCode == 200) {
      print(response.body);
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result.contains('CERTIFIED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _initInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '개인정보 수정하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('dwdw'),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 2),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('아이디')),
                Container(
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: TextField(
                      style: TextStyle(color: Colors.grey),
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: _uidController,
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('이름')),
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.height * 0.05,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: _nameController,
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('신분')),
                Container(
                  width: size.width * 0.8,
                  height: size.height * 0.05,
                  child: DropdownButton(
                    isExpanded: true,
                    iconSize: 50,
                    value: _selectedValue,
                    items: statusList.map((value) {
                      return DropdownMenuItem(
                        child: Center(child: Text(value)),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
                        if (statusMap[_selectedValue] > 1) {
                          _studentIDController.text = '';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('학번')),
                Container(
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: TextField(
                      readOnly: _selectedValue == '재학생' ? false : true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: _studentIDController,
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('닉네임')),
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: _nicknameController,
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('전화번호')),
                Container(
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(border: InputBorder.none),
                      controller: _telController,
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('가입일')),
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: Text('${widget.user.rDate}',
                        style: TextStyle(color: Colors.grey)))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1))),
                    child: Text('구매수')),
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: Text(
                      '${widget.user.buyCount}회',
                      style: TextStyle(color: Colors.grey),
                    ))
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        border: Border(
                            left: BorderSide(color: Colors.black, width: 2),
                            right: BorderSide(color: Colors.black, width: 2),
                            top: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 2))),
                    child: Text('포인트')),
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.width * 0.1,
                    child: Text('${widget.user.point}P',
                        style: TextStyle(color: Colors.grey)))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('비밀번호 입력'),
                                content: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      border: Border.all(
                                          width: 1, color: Colors.black87)),
                                  child: TextField(
                                    obscureText: true,
                                    controller: _pwController,
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('취소')),
                                  FlatButton(
                                      onPressed: () async {
                                        var res = await _certifyMyselfRequest();
                                        if (res) {
                                          var res =
                                              await _updateUserInfoRequest();
                                          if (res) {
                                            Fluttertoast.showToast(
                                                msg: "개인정보 수정이 완료되었습니다.",
                                                gravity: ToastGravity.BOTTOM,
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "개인정보 수정에 실패하였습니다!",
                                                gravity: ToastGravity.BOTTOM,
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          }
                                          Navigator.pop(context);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "비밀번호가 올바르지 않습니다!",
                                              gravity: ToastGravity.BOTTOM,
                                              toastLength: Toast.LENGTH_SHORT);
                                        }
                                      },
                                      child: Text('완료'))
                                ],
                              ));
                    },
                    child: Text('수정하기')),
                FlatButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)
                  => UpdatePasswordPage(user: widget.user,)));
                }, child: Text('비밀번호 변경하기')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
