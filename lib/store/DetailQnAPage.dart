import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailQnAPage extends StatefulWidget {
  DetailQnAPage({this.user, this.data});

  final Map data;
  final User user;

  @override
  _DetailQnAPageState createState() => _DetailQnAPageState();
}

class _DetailQnAPageState extends State<DetailQnAPage> {
  /// 현재 문의 글 데이터의 date field를 사용자에게 더 직관적으로 보여주는 날짜 formatting 작업
  /// format : yyyy년 MM월 dd일 (오후 or 오전) hh시 mm분
  String _formatDate(String originDate) {
    String date = originDate.split(' ')[0];
    String time = originDate.split(' ')[1];
    var dateSuffix = ['년', '월', '일'];
    String fDate = '';
    var dateSplit = date.split('-');
    for (int i = 0; i < dateSplit.length; ++i) {
      fDate += dateSplit[i] + dateSuffix[i] + ' ';
    }

    var timeSplit = time.split(':');
    bool isPM = false;
    int hour = int.parse(timeSplit[0]);
    if (hour >= 12) {
      isPM = true;
      hour = hour == 12 ? hour : hour - 12;
    } else if (hour == 0) {
      isPM = false;
      hour = 12;
    }
    String fTime =
        (isPM ? '오후 ' : '오전 ') + hour.toString() + '시 ' + timeSplit[1] + '분';
    return fDate + fTime;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '세부 문의 내역',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.02,
          ),
          Container(
            height: size.height * 0.06,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black54)),
            child: Row(
              children: [
                Container(
                  child: Text(
                    '제목',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  width: size.width * 0.15,
                  alignment: Alignment.center,
                ),
                VerticalDivider(
                  color: Colors.black54,
                  thickness: 1,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.data['qTitle'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.00001,
          ),
          Container(
            height: size.height * 0.06,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black54)),
            child: Row(
              children: [
                Container(
                  child: Text('작성일',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  width: size.width * 0.15,
                  alignment: Alignment.center,
                ),
                VerticalDivider(
                  color: Colors.black54,
                  thickness: 1,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(_formatDate(widget.data['qDate'])),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Container(
            child: Text(
              '본문 내용',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            width: size.width,
            height: size.height * 0.02,
            alignment: Alignment.center,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Container(
            width: size.width * 0.99,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black54),
                borderRadius: BorderRadius.circular(8)),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                widget.data['qContent'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          int.parse(widget.data['isAnswer']) == 0
              ? Text('답변이 아직 없습니다.')
              : Container(
                  height: size.height * 0.4,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      print(index);
                      var data = jsonDecode(widget.data['answer'][index]);
                      return _answerItemTile(data['awUID'], data['awContent'],
                          data['awDate'], index, size);
                    },
                    itemCount: widget.data['answer'].length,
                  ),
                )
        ],
      ),
    );
  }

  Widget _answerItemTile(
      String uid, String content, String date, int index, Size size) {
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
