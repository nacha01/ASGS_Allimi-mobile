import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 게임코드
/// 1 : 기억력 게임(Memory game)
class RecordListPage extends StatefulWidget {
  final int gameCode;
  final User user;
  RecordListPage({this.gameCode, this.user});
  @override
  _RecordListPageState createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  String _appBarTitle;
  List _rankList = [];
  @override
  void initState() {
    super.initState();
    switch (widget.gameCode) {
      case 1:
        _appBarTitle = '기억력 게임 랭킹';
    }
    _getRankingListOnGameCode();
  }

  Future<void> _getRankingListOnGameCode() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getRankOnMemory.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();

      List tmp = jsonDecode(result);
      for (int i = 0; i < tmp.length; ++i) {
        tmp[i] = jsonDecode(tmp[i]);
      }
      setState(() {
        _rankList = tmp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$_appBarTitle',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.1),
        child: ListView.builder(
            itemCount: _rankList.length,
            itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Text('${index + 1}'),
                    title: Text('${_rankList[index]['nickname']}'),
                    trailing: Text('${_rankList[index]['record']}점'),
                  ),
                )),
      ),
    );
  }
}
