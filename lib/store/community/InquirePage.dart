import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';

class InquirePage extends StatefulWidget {
  InquirePage({this.user});

  final User? user;

  @override
  _InquirePageState createState() => _InquirePageState();
}

class _InquirePageState extends State<InquirePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  List _categoryList = ['상품', '교환/환불', '계정', '앱 이용', '기타'];
  Map _categoryMap = {'상품': 0, '교환/환불': 1, '계정': 2, '앱 이용': 3, '기타': 4};
  String? _selectedCategory = '상품';

  /// 새로운 문의 글을 등록하는 요청을 하는 작업
  /// @response : 성공 시, '1'
  Future<bool> _registerNewQnA() async {
    String url = '${ApiUtil.API_HOST}arlimi_addQnA.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'uid': widget.user!.uid,
      'category': _categoryMap[_selectedCategory].toString(),
      'title': _titleController.text,
      'content': _contentController.text,
      'date': DateTime.now().toString().split('.')[0]
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  /// 현재 route 를 강제 종료하는 작업
  void _finishThisPage() {
    Navigator.pop(this.context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '문의하기'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.02,
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Text(
                      '제목',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Container(
                  alignment: Alignment.center,
                  width: size.width * 0.8,
                  height: size.height * 0.06,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black)),
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '제목을 입력하세요.',
                        hintStyle: TextStyle(color: Colors.grey)),
                    controller: _titleController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: size.width * 0.2,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Text('카테고리',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  width: size.width * 0.8,
                  height: size.height * 0.06,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black)),
                  child: DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    items: _categoryList.map((value) {
                      return DropdownMenuItem(
                        child: Center(child: Text(value)),
                        value: value,
                      );
                    }).toList(),
                    value: _selectedCategory,
                    onChanged: (dynamic value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Text('본문 내용', style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(
              thickness: 1,
              indent: 5,
              endIndent: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: size.height * 0.7,
                child: TextField(
                  maxLength: 2000,
                  maxLines: 55,
                  controller: _contentController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '본문 내용을 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Divider(
              thickness: 1,
              indent: 5,
              endIndent: 5,
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.lightBlueAccent),
              child: DefaultButtonComp(
                onPressed: () async {
                  var res = await _registerNewQnA();
                  if (res) {
                    await showDialog(
                        context: (context),
                        builder: (ctx) {
                          Future.delayed(Duration(milliseconds: 900), () {
                            Navigator.pop(ctx);
                            _finishThisPage();
                          });
                          return AlertDialog(
                            title: Text('문의하기'),
                            content: Text('문의 글이 등록되었습니다.'),
                          );
                        });
                  } else {
                    Fluttertoast.showToast(
                        msg: '문의 글 등록에 실패하였습니다!',
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT);
                  }
                },
                child: Text(
                  '등록하기',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              width: size.width * 0.8,
              height: size.height * 0.04,
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}
