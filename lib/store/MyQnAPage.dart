import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyQnAPage extends StatefulWidget {
  MyQnAPage({this.user});
  final User user;
  @override
  _MyQnAPageState createState() => _MyQnAPageState();
}

class _MyQnAPageState extends State<MyQnAPage> {
  List _qnaList = [];
  Map _categoryMap = {0: '상품', 1: '교환/환불', 2: '계정', 3: '앱 이용', 4: '기타'};

  Future<bool> _getMyQnAData() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getUserQnA.php';
    final response = await http.get(url + '?uid=${widget.user.uid}');

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map = json.decode(result);
      for (int i = 0; i < map.length; ++i) {
        _qnaList.add(json.decode(map[i]));
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _getMyQnAData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '내 문의내역',
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
          Text('테스트'),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return _itemTile(
                  _qnaList[index]['qTitle'],
                  _qnaList[index]['qDate'],
                  _categoryMap[int.parse(_qnaList[index]['qCategory'])],
                  int.parse(_qnaList[index]['isAnswer']) == 1 ? true : false,
                  size);
            },
            itemCount: _qnaList.length,
          ))
        ],
      ),
    );
  }

  Widget _itemTile(
      String title, String date, String category, bool isAnswer, Size size) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.all(3),
        height: size.height * 0.11,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.5, color: Colors.black38),
            color: Colors.white24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isAnswer
                      ? Container(
                          alignment: Alignment.center,
                          width: size.width * 0.25,
                          height: size.height * 0.04,
                          child: Text(
                            '답변 완료',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 1, color: Colors.orange),
                              color: Colors.yellow),
                        )
                      : Container(
                          width: size.width * 0.25,
                          height: size.height * 0.04,
                        ),
                  VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Text(
                      date,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    width: size.width * 0.63,
                    alignment: Alignment.centerRight,
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '[$category] ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
