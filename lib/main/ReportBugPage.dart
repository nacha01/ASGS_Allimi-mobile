import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ReportBugPage extends StatefulWidget {
  @override
  _ReportBugPageState createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Future<void> _sendErrorReport() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addReport.php';
    final response = await http.post(url, body: <String, String>{
      'errorMessage': _titleController.text,
      'date': DateTime.now().toString(),
      'extra': _contentController.text,
      'isRunning': '0'
    });
    if (response.statusCode == 200) {
      print('성공');
    }
  }

  void _terminateScreen() {
    Navigator.pop(this.context);
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
          '버그 제보하기',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: Text(
                '앱을 이용하다 내가 원하지 않는 결과 혹은 오류가 발생했을 때\n또는 이 앱에 있어서 건의할 내용을 작성하는 페이지입니다.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                '* 원하는지 않는 결과 예시',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 로그인이 되지 않는 경우, 회원가입이 되지 않는 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 다음 페이지로 넘어가지 않는 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 목록들이 제대로 보여지지 않는 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 버튼 클릭 시 앱이 멈춘 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 버튼등 클릭, 터치가 안되는 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text('- 화면 전체가 빨간색 배경이 상단에 작은 영어가 적혀 있는 경우',
                  style: TextStyle(fontSize: 12, color: Colors.red)),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                '* 건의 제목 또는 제보 내용을 요약한 제목',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 13),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  width: size.width * 0.95,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.black)),
                  child: TextField(
                    controller: _titleController,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '작성할 내용의 큰 제목을 작성하세요.',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Text(
                '* 건의할 내용 또는 제보할 구체적인 내용',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 13),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  width: size.width * 0.95,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Colors.black)),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '제보하고 하는 내용 혹은 상황을 작성하세요.',
                        hintStyle: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Text(
                  '문제를 해결하기 위해서는 내용에는 반드시 구체적인 상황이 들어가야합니다.(위치, 동작 등 원인에 대한 정보)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 12)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.005),
              child: Text('ex) ~에서 ~를 ~클릭 시 ~한 문제가 있었습니다.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12)),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Text('※ 계정 관련한 내용일 경우 아이디와 비밀번호를 함께 작성해주세요.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12)),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty ||
                          _contentController.text.isEmpty) {
                        Fluttertoast.showToast(msg: '입력하지 않은 란이 존재합니다.');
                        return;
                      }
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('제출 준비 완료',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                content: Text('정말로 제출하시겠습니까?',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('아니오')),
                                  TextButton(
                                      onPressed: () async {
                                        await _sendErrorReport();
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                    '제출 완료',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Text(
                                                    '성공적으로 제보가 제출되었습니다.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _terminateScreen();
                                                        },
                                                        child: Text('확인'))
                                                  ],
                                                ));
                                      },
                                      child: Text('예'))
                                ],
                              ));
                    },
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      width: size.width * 0.25,
                      alignment: Alignment.center,
                      child: Text(
                        '제출하기',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.teal),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
