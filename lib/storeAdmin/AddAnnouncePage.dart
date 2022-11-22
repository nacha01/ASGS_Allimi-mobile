import 'dart:convert';

import 'package:asgshighschool/data/announce_data.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// 공지사항 추가 및 수정 페이지
/// [isUpdate] ? modify : add
class AddAnnouncePage extends StatefulWidget {
  AddAnnouncePage({this.user, this.isUpdate = false, this.announce});

  final User user;
  final bool isUpdate;
  final Announce announce;

  @override
  _AddAnnouncePageState createState() => _AddAnnouncePageState();
}

enum Writer { ADMIN, NAME, NICKNAME }

class _AddAnnouncePageState extends State<AddAnnouncePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  Writer _writer = Writer.ADMIN; // Radio 버튼 초기 값
  Announce _updatedAnnounceObj; // Update 모드시 넘겨받을 Announce 객체

  /// 공지사항 등록을 서버에 요청하는 작업
  /// @response : 정상적인 성공 시, 문자열 1 응답
  /// @return : 정상적인 등록시 true, 그렇지 않으면 false
  Future<bool> _registerAnnounceRequest(RenewUserData providedUser) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addAnnounce.php';
    final response = await http.post(url, body: <String, String>{
      'writer': _getWriterToString(_writer, providedUser),
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

  /// 공지사항을 서버에 수정을 요청하는 작업
  /// @response : none
  /// @return : 정상적인 업데이트 시 true, 그렇지 않으면 false
  Future<bool> _updateAnnounceRequest(RenewUserData providedUser) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_updateAnnounce.php';
    final response = await http.post(url, body: <String, String>{
      'anID': widget.announce.announceID.toString(),
      'writer': _getWriterToString(_writer, providedUser),
      'date': DateTime.now().toString().split('.')[0],
      'title': _titleController.text,
      'content': _contentController.text
    });
    if (response.statusCode == 200) {
      print(response.body);
      await _getUpdatedAnnounceObj();
      return true;
    } else {
      return false;
    }
  }

  /// 공지사항 업데이트 시, 업데이트 된 그 공지사항 하나를 가져오는 요청
  /// 가져온 json 파일을 Announce.fromJson 생성자로 Announce 객체 생성해서 리턴
  Future<bool> _getUpdatedAnnounceObj() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_getOneAnnounce.php';
    final response =
        await http.get(uri + '?anID=${widget.announce.announceID}');
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      _updatedAnnounceObj = Announce.fromJson(json.decode(result));
      return true;
    } else {
      return false;
    }
  }

  /// 공지사항을 추가, 수정할 때, ENUM 값에 의해 mapping 되는 작성자를 리턴
  /// @param : 작성자 ENUM 값
  /// @return : mapping 된 작성자 문자열
  String _getWriterToString(Writer writer, RenewUserData providedUser) {
    if (writer == Writer.ADMIN) {
      return '관리자';
    } else if (writer == Writer.NAME) {
      return providedUser.user.name;
    } else if (writer == Writer.NICKNAME) {
      return providedUser.user.nickName;
    }
    return 'ERROR';
  }

  /// Update 모드시 받아온 객체에 대해서 작성자를 초기화 해주는 작업
  void _updateInitialize() {
    _titleController.text = widget.announce.title;
    _contentController.text = widget.announce.content;
    if (widget.announce.writer == '관리자') {
      _writer = Writer.ADMIN;
    } else if (widget.announce.writer == widget.user.name) {
      _writer = Writer.NAME;
    } else {
      _writer = Writer.NICKNAME;
    }
  }

  /// 토스트 메세지를 뿌려주는 작업
  /// @param : 뿌려줄 메세지 문자열
  void showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _updateInitialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final providedUser = Provider.of<RenewUserData>(context);
    return WillPopScope(
      // WillPopScope 위젯으로 뒤로가기 버튼 event 제어해서 데이터 전달
      onWillPop: () async {
        Navigator.pop(context, widget.isUpdate ? _updatedAnnounceObj : true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(
                context, widget.isUpdate ? _updatedAnnounceObj : true),
          ),
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            widget.isUpdate ? '공지사항 수정하기' : '공지사항 글 쓰기',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '* 제목, 작성자, 내용을 필수로 작성해주세요.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text('* 본문 내용을 입력하는 공간은 입력하는 내용의 양에 따라 달라집니다'),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text('* 작성자의 경우 어떤 신분으로 작성할지 설정할 수가 있습니다.'),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text('※ 익명으로 작성하고 싶으면 "관리자"를 선택하십시오.'),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    '공지사항 제목 작성하기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  TextField(
                    maxLines: null,
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
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text('작성자 설정',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text('공지사항 내용 작성하기 (최대 3000자)',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    width: size.width * 0.98,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: TextField(
                      onChanged: (value) {
                        if (value.length > 3000) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('최대 글자를 초과하였습니다.'),
                                  ));
                        }
                      },
                      maxLines: null,
                      maxLength: 3000,
                      controller: _contentController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '글 내용',
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    child: Container(
                        decoration: BoxDecoration(color: Colors.lightBlue),
                        width: size.width * 0.5,
                        child: FlatButton(
                          child: Text(
                            widget.isUpdate ? '수정하기' : '등록하기',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (widget.isUpdate) {
                              var res =
                                  await _updateAnnounceRequest(providedUser);
                              if (res) {
                                showToastMessage('공지사항 수정에 성공하였습니다.');
                                Navigator.pop(context, _updatedAnnounceObj);
                              } else {
                                showToastMessage('공지사항 수정에 실패하였습니다.');
                              }
                            } else {
                              var res =
                                  await _registerAnnounceRequest(providedUser);
                              if (res) {
                                showToastMessage('공지사항 등록에 성공하였습니다.');
                                Navigator.pop(context);
                              } else {
                                showToastMessage('공지사항 등록에 실패하였습니다.');
                              }
                            }
                          },
                        )),
                    width: size.width,
                    alignment: Alignment.center,
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
