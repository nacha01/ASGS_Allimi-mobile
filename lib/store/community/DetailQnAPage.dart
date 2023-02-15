import 'dart:convert';

import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:flutter/material.dart';

class DetailQnAPage extends StatefulWidget {
  DetailQnAPage({this.user, this.data});

  final Map? data;
  final User? user;

  @override
  _DetailQnAPageState createState() => _DetailQnAPageState();
}

class _DetailQnAPageState extends State<DetailQnAPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '세부 문의 내역'),
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
                      widget.data!['qTitle'],
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
                    child:
                        Text(DateFormatter.formatDateMidday(widget.data!['qDate'])),
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
                widget.data!['qContent'],
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
          int.parse(widget.data!['isAnswer']) == 0
              ? Text('답변이 아직 없습니다.')
              : Container(
                  height: size.height * 0.4,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      print(index);
                      var data = jsonDecode(widget.data!['answer'][index]);
                      return _answerItemTile(data['awUID'], data['awContent'],
                          data['awDate'], index, size);
                    },
                    itemCount: widget.data!['answer'].length,
                  ),
                )
        ],
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
