import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  /// 기억력 게임에 대한 모든 유저의 기록을 가져오는 요청
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

  /// 랭킹 리스트들 중에서 본인의 인덱스를 찾는 함수
  /// @return : 리스트에서 본인에 해당하는 인덱스 정수 값
  int _findMyIndexInRankList() {
    for (int i = 0; i < _rankList.length; ++i) {
      if (_rankList[i]['nickname'] == widget.user.nickName) {
        return i;
      }
    }
    return -1;
  }

  /// TOP 3에 해당하는 유저들의 순위 텍스트 색깔 부여하는 함수
  Color _getTop3TextColor(int index) {
    switch (index) {
      case 0:
        return Color(0xFFD5A11E);
      case 1:
        return Color(0xFFA3A3A3);
      case 2:
        return Color(0xFFCD7F32);
      default:
        return Colors.black;
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
        padding: EdgeInsets.all(size.width * 0.15),
        child: ListView.builder(
            itemCount: _rankList.length,
            itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: _getTop3TextColor(index),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    title: Center(
                        child: Text(
                      '${_rankList[index]['nickname']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    )),
                    trailing: Text(
                      '${_rankList[index]['record']}점',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    tileColor: (index == _findMyIndexInRankList())
                        ? Colors.orange[200]
                        : null,
                  ),
                )),
      ),
    );
  }
}
