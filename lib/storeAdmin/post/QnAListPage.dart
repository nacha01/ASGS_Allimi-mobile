import 'dart:convert';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/user.dart';
import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../util/DateFormatter.dart';
import 'AnswerQnAPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///문의 글 목록 페이지
/// 실시간 리스트 업데이트 기능 추가 요망
/// 정렬 기능 추가 요망
class QnAListPage extends StatefulWidget {
  QnAListPage({this.user});

  final User? user;

  @override
  _QnAListPageState createState() => _QnAListPageState();
}

class _QnAListPageState extends State<QnAListPage> {
  List<Map?> _qnaDateList = [];
  List<Map?> _noneQnAList = [];
  bool _isChecked = true;
  bool _isFinished = false;
  Map _categoryMap = {0: '상품', 1: '교환/환불', 2: '계정', 3: '앱 이용', 4: '기타'};

  /// 문의 글을 날짜 순으로 정렬하는 작업
  void _sortListOrderByTime() {
    _qnaDateList.sort(
        (a, b) => b!['qDate'].toString().compareTo(a!['qDate'].toString()));
    _noneQnAList.sort(
        (a, b) => b!['qDate'].toString().compareTo(a!['qDate'].toString()));
  }

  /// 모든 문의 글 데이터를 요청하는 작업
  /// 답변이 된 글과 되지 않은 글을 각 List에 구분하여 추가
  Future<bool> _getAllQnAData() async {
    String url = '${ApiUtil.API_HOST}arlimi_getAllQnA.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);

      List map = jsonDecode(result);
      _qnaDateList.clear();
      _noneQnAList.clear();

      for (int i = 0; i < map.length; ++i) {
        _qnaDateList.add(jsonDecode(map[i]));
        if (int.parse(_qnaDateList[i]!['isAnswer']) == 0) {
          _noneQnAList.add(_qnaDateList[i]);
        } else {
          for (int j = 0; j < _qnaDateList[i]!['answer'].length; ++j) {
            _qnaDateList[i]!['answer'][j] =
                jsonDecode(_qnaDateList[i]!['answer'][j]);
          }
        }
      }
      setState(() {
        _sortListOrderByTime();
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _getAllQnAData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '문의 글 목록'),
      body: RefreshIndicator(
        onRefresh: _getAllQnAData,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: DefaultButtonComp(
                    child: Row(
                      children: [
                        Icon(
                          _isChecked
                              ? Icons.check_box
                              : Icons.check_box_outlined,
                          color: Colors.blue,
                        ),
                        Text('답변 완료 안보기')
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                  ),
                )
              ],
            ),
            _isFinished
                ? _isChecked
                    ? _noneQnAList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text(
                              '업로드된 문의 글이 없습니다!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))
                        : Expanded(
                            child: ListView.builder(
                            itemBuilder: (context, index) {
                              return _itemTile(
                                  _noneQnAList[index]!['qTitle'],
                                  _noneQnAList[index]!['qUID'],
                                  _noneQnAList[index]!['qDate'],
                                  _categoryMap[int.parse(
                                      _noneQnAList[index]!['qCategory'])],
                                  int.parse(_noneQnAList[index]!['isAnswer']) ==
                                          1
                                      ? true
                                      : false,
                                  _noneQnAList[index],
                                  size);
                            },
                            itemCount: _noneQnAList.length,
                          ))
                    : _qnaDateList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text(
                              '업로드된 문의 글이 없습니다!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))
                        : Expanded(
                            child: ListView.builder(
                            itemBuilder: (context, index) {
                              return _itemTile(
                                  _qnaDateList[index]!['qTitle'],
                                  _qnaDateList[index]!['qUID'],
                                  _qnaDateList[index]!['qDate'],
                                  _categoryMap[int.parse(
                                      _qnaDateList[index]!['qCategory'])],
                                  int.parse(_qnaDateList[index]!['isAnswer']) ==
                                          1
                                      ? true
                                      : false,
                                  _qnaDateList[index],
                                  size);
                            },
                            itemCount: _qnaDateList.length,
                          ))
                : Expanded(
                    child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('불러오는 중..'),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget _itemTile(String? title, String? uid, String date, String? category,
      bool isAnswer, Map? data, Size size) {
    return DefaultButtonComp(
      onPressed: () async {
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AnswerQnAPage(
                      user: widget.user,
                      data: data,
                    )));
        if (res) {
          await _getAllQnAData();
        }
      },
      child: Container(
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              endIndent: 10,
              indent: 10,
              thickness: 0.8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '[$category] ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '$title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  DateFormatter.formatDateTimeCmp(date),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.pink),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Row(
              children: [
                Text('작성자 ID : '),
                Text(
                  '$uid',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            isAnswer
                ? Container(
                    width: size.width * 0.23,
                    height: size.height * 0.1 * 0.28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green),
                    child: Text(
                      '답변 완료',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
