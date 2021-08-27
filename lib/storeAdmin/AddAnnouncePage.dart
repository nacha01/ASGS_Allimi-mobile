import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddAnnouncePage extends StatefulWidget {
  AddAnnouncePage({this.user});
  final User user;
  @override
  _AddAnnouncePageState createState() => _AddAnnouncePageState();
}

enum Writer { ADMIN, NAME, NICKNAME }

class _AddAnnouncePageState extends State<AddAnnouncePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  var _selectedWriter;
  Writer _writer = Writer.ADMIN;
  Future<bool> _registerAnnounceRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addAnnounce.php';

    final response = await http.post(url, body: <String, String>{
      'writer': _getWriterToString(_writer),
      'date': DateTime.now().toString().split('.')[0],
      'title': _titleController.text,
      'content': _contentController.text
    });

    if (response.statusCode == 200) {
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

  String _getWriterToString(Writer writer) {
    if (writer == Writer.ADMIN) {
      return '관리자';
    } else if (writer == Writer.NAME) {
      return widget.user.name;
    } else if (writer == Writer.NICKNAME) {
      return widget.user.nickName;
    }
    return 'ERROR';
  }

  @override
  void initState() {
    super.initState();
    print(DateTime.now().toString());
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '공지사항 글 쓰기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: size.height * 0.1,
              ),
              Divider(
                thickness: 2,
                indent: 5,
                endIndent: 5,
              ),
              Text('공지사항 제목 작성하기'),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '제목',
                    hintStyle: TextStyle(color: Colors.grey)),
              ),
              Divider(
                thickness: 2,
                indent: 5,
                endIndent: 5,
              ),
              Text('작성자 설정'),
              RadioListTile(
                  title: Text('관리자(익명)로 작성'),
                  value: Writer.ADMIN,
                  groupValue: _writer,
                  onChanged: (value) {
                    setState(() {
                      _writer = value;
                    });
                  }),
              RadioListTile(
                  title: Text('실명으로 작성'),
                  value: Writer.NAME,
                  groupValue: _writer,
                  onChanged: (value) {
                    setState(() {
                      _writer = value;
                    });
                  }),
              RadioListTile(
                  title: Text('닉네임으로 작성'),
                  value: Writer.NICKNAME,
                  groupValue: _writer,
                  onChanged: (value) {
                    setState(() {
                      _writer = value;
                    });
                  }),
              Divider(
                thickness: 2,
                indent: 5,
                endIndent: 5,
              ),
              Text('공지사항 내용 작성하기'),
              Container(
                width: size.width * 0.98,
                height: size.height * 0.4,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey)),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '글 내용',
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              Container(
                child: Container(
                    decoration: BoxDecoration(color: Colors.lightBlue),
                    width: size.width * 0.6,
                    child: FlatButton(
                      child: Text('글 등록하기'),
                      onPressed: () async {
                        var res = await _registerAnnounceRequest();
                        if (res) {
                          Fluttertoast.showToast(
                              msg: '공지사항 등록에 성공하였습니다.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        } else {
                          Fluttertoast.showToast(
                              msg: '공지사항 등록에 실패하였습니다.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      },
                    )),
                width: size.width,
                alignment: Alignment.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
