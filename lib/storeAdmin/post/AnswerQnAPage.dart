import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';

/// 문의글에 답변하기
/// 답변 시
/// arlimi_answer DB에 record 추가
/// 그 문의글에 대해 'isAnswer' 필드 값 업데이트
class AnswerQnAPage extends StatefulWidget {
  AnswerQnAPage({this.data, this.user});

  final Map? data;
  final User? user;

  @override
  _AnswerQnAPageState createState() => _AnswerQnAPageState();
}

class _AnswerQnAPageState extends State<AnswerQnAPage> {
  bool _isAnswer = false;
  TextEditingController _answerController = TextEditingController();

  /// 특정 문의 글에 대해 답변을 등록하는 요청을 하는 작업
  Future<bool> _registerAnswerToDB() async {
    String url = '${ApiUtil.API_HOST}arlimi_addAnswer.php';

    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'qid': widget.data!['qID'],
      'uid': widget.user!.uid,
      'date': DateTime.now().toString(),
      'content': _answerController.text
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _isAnswer = int.parse(widget.data!['isAnswer']) == 1 ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(
            barTitle: '답변하기', leadingClick: () => Navigator.pop(context, true)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Container(
                height: size.height * 0.07,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black45)),
                child: Row(
                  children: [
                    Container(
                      child: Text(
                        '제목',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      width: size.width * 0.2,
                      alignment: Alignment.center,
                    ),
                    VerticalDivider(
                      thickness: 2,
                    ),
                    Expanded(
                        child: Container(
                      child: Text('${widget.data!['qTitle']}'),
                      alignment: Alignment.center,
                    ))
                  ],
                ),
              ),
              Container(
                height: size.height * 0.07,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black45)),
                child: Row(
                  children: [
                    Container(
                      child: Text('작성일',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      width: size.width * 0.2,
                      alignment: Alignment.center,
                    ),
                    VerticalDivider(
                      thickness: 2,
                    ),
                    Expanded(
                        child: Container(
                      child: Text('${widget.data!['qDate']}'),
                      alignment: Alignment.center,
                    ))
                  ],
                ),
              ),
              Container(
                height: size.height * 0.07,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black45)),
                child: Row(
                  children: [
                    Container(
                      child: Text('작성자 ID',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      width: size.width * 0.2,
                      alignment: Alignment.center,
                    ),
                    VerticalDivider(
                      thickness: 2,
                    ),
                    Expanded(
                        child: Container(
                      child: Text('${widget.data!['qUID']}'),
                      alignment: Alignment.center,
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Divider(
                thickness: 5,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                '문의 내용',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Container(
                alignment: Alignment.topCenter,
                width: size.width * 0.95,
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: Colors.black),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${widget.data!['qContent']}'),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Divider(
                thickness: 5,
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              _isAnswer
                  ? Container(
                      height: size.height * 0.2,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return _answerItemTile(
                              widget.data!['answer'][index]['awUID'],
                              widget.data!['answer'][index]['awContent'],
                              widget.data!['answer'][index]['awDate'],
                              index,
                              size);
                        },
                        itemCount: widget.data!['answer'].length,
                      ),
                    )
                  : SizedBox(),
              Divider(
                thickness: 2,
              ),
              Container(
                padding: EdgeInsets.all(size.width * 0.015),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '답변하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                          width: size.width * 0.73,
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300]),
                          child: TextField(
                            maxLines: null,
                            maxLength: 2000,
                            controller: _answerController,
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: size.width * 0.17,
                      height: size.height * 0.05,
                      child: DefaultButtonComp(
                        onPressed: () async {
                          var res = await _registerAnswerToDB();
                          if (res) {
                            Fluttertoast.showToast(
                                msg: '성공적으로 답변이 완료되었습니다.',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: '답변에 실패하였습니다!',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        },
                        child: Text(
                          '완료',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(8)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerItemTile(
      String? uid, String content, String? date, int index, Size size) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2, color: Colors.grey)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '답변 ${index + 1}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.redAccent),
              ),
              Text(
                '$date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(size.width * 0.035),
                width: size.width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300]),
                child: Text(content),
              ),
            ],
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Row(
            children: [
              Container(
                  child: Text(
                '답변자 ID :  $uid',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
            ],
          )
        ],
      ),
    );
  }
}
