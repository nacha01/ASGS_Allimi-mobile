import 'dart:convert';

import 'package:asgshighschool/data/announce.dart';
import '../component/CorporationComp.dart';
import '../data/provider/renew_user.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/DetailAnnouncePage.dart';
import '../storeAdmin/post/AddAnnouncePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AnnouncePage extends StatefulWidget {
  AnnouncePage({this.user});

  final User? user;

  @override
  _AnnouncePageState createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  List<Announce> _announceList = [];
  bool _isFinished = false;
  TextEditingController _searchController = TextEditingController();
  List _searchCategoryList = ['제목', '날짜', '작성자'];
  List<Announce> _searchList = [];
  String? _selectedCategory = '제목';
  bool _isSearch = false;
  bool _isLoading = true; // 로딩 중인지 판단
  bool _corporationInfoClicked = false;

  /// 모든 공지사항 데이터를 요청하는 작업
  Future<bool> _getAnnounceRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAnnounce.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List anList = json.decode(result);
      _announceList.clear();
      for (int i = 0; i < anList.length; ++i) {
        _announceList.add(Announce.fromJson(json.decode(anList[i])));
      }
      setState(() {
        _isFinished = true;
        _isLoading = false;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 특정 공지사항 글에 대해서 조회수 증가 요청
  Future<int> _increaseViewCountRequest(int anID) async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_increaseViewCount.php';
    final response = await http.get(Uri.parse(url + '?anID=$anID'));

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      return int.parse(result);
    } else {
      return -1;
    }
  }

  /// 오늘 날짜와 비교해서 공지글이 최신글인지 판단
  /// @param : 공지글 작성된 비교할 날짜
  bool _compareDateIsNew(String cmpDate) {
    int diff = int.parse(
        DateTime.now().difference(DateTime.parse(cmpDate)).inDays.toString());
    return diff < 3 ? true : false;
  }

  /// parameter로 들어온 검색 기준에 따라 검색 하고자 하는 단어가 포함되는 공지사항 데이터를
  /// List 에 추가하는 작업
  void _searchAnnounceByCategory(String? category, String toSearch) {
    if (toSearch.isEmpty) {
      setState(() {
        _isSearch = false;
      });
      return;
    }
    _searchList.clear();
    switch (category) {
      case '제목':
        for (int i = 0; i < _announceList.length; ++i) {
          if (_announceList[i].title!.contains(toSearch)) {
            _searchList.add(_announceList[i]);
          }
        }
        break;
      case '날짜':
        for (int i = 0; i < _announceList.length; ++i) {
          if (_announceList[i].writeDate!.contains(toSearch)) {
            _searchList.add(_announceList[i]);
          }
        }
        break;
      case '작성자':
        for (int i = 0; i < _announceList.length; ++i) {
          if (_announceList[i].writer!.contains(toSearch)) {
            _searchList.add(_announceList[i]);
          }
        }
        break;
    }
    setState(() {
      _isSearch = true;
    });
  }

  @override
  void initState() {
    _getAnnounceRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var providedUser = Provider.of<RenewUserData>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '두루두루 소식',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: SizedBox(),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _getAnnounceRequest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: size.width,
                height: size.height * 0.05,
                child: Column(
                  children: [
                    //brief 설명 적는 곳
                    Text('' /*이 페이지의 간략한 설명 적는 란*/)
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.55,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.black)),
                    child: TextField(
                      onSubmitted: (value) {
                        _searchAnnounceByCategory(_selectedCategory, value);
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '검색하기',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          )),
                    ),
                  ),
                  Container(
                    width: size.width * 0.1,
                    height: size.height * 0.05,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF9EE1E5), width: 1)),
                    child: IconButton(
                      iconSize: 28,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        _searchAnnounceByCategory(
                            _selectedCategory, _searchController.text);
                      },
                      icon: Icon(
                        Icons.search,
                        color: Color(0xFF9EE1E5),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.07,
                  ),
                  DropdownButton(
                    value: _selectedCategory,
                    items: _searchCategoryList.map((value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (dynamic value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
              Divider(
                indent: 10,
                endIndent: 10,
                thickness: 1,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              providedUser.user!.isAdmin
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: size.height * 0.05,
                            width: size.width * 0.28,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.black54),
                                borderRadius: BorderRadius.circular(8)),
                            child: TextButton(
                                onPressed: () async {
                                  var res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddAnnouncePage(
                                                user: providedUser.user,
                                              )));
                                  if (res) {
                                    await _getAnnounceRequest();
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.add),
                                    Text('글 쓰기'),
                                  ],
                                )),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          endIndent: 10,
                          indent: 10,
                        ),
                      ],
                    )
                  : SizedBox(),
              _isFinished
                  ? _announceList.length == 0
                      ? Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '공지사항이 없습니다!',
                                textAlign: TextAlign.center,
                              )),
                        )
                      : _isSearch
                          ? _searchList.length == 0
                              ? Center(
                                  child: Column(
                                    children: [
                                      _removeSearchResultWidget(size),
                                      SizedBox(
                                        height: size.height * 0.1,
                                      ),
                                      Text(
                                        '검색 결과가 없습니다!',
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) =>
                                        _announceItemLayout(
                                            title: _searchList[index].title!,
                                            writer: _searchList[index].writer!,
                                            date: _searchList[index].writeDate,
                                            isNew: _compareDateIsNew(
                                                _searchList[index].writeDate!),
                                            size: size,
                                            announce: _searchList[index]),
                                    itemCount: _searchList.length,
                                  ),
                                )
                          : Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, index) =>
                                    _announceItemLayout(
                                        title: _announceList[index].title!,
                                        writer: _announceList[index].writer!,
                                        date: _announceList[index].writeDate,
                                        isNew: _compareDateIsNew(
                                            _announceList[index].writeDate!),
                                        size: size,
                                        announce: _announceList[index]),
                                itemCount: _announceList.length,
                              ),
                            )
                  : Expanded(
                      child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('불러오는 중..'),
                          CircularProgressIndicator(),
                        ],
                      ),
                    )),
              CorporationInfo(isOpenable: true)
            ],
          ),
        ),
      ),
    );
  }

  Widget _announceItemLayout(
      {required String title,
      required String writer,
      String? date,
      required bool isNew,
      required Size size,
      Announce? announce}) {
    return GestureDetector(
      onTap: () async {
        int renew = await _increaseViewCountRequest(announce!.announceID);
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailAnnouncePage(
                      announce: announce,
                      user: widget.user,
                      isNew: isNew,
                      newView: renew,
                    )));
        if (res) {
          await _getAnnounceRequest();
        }
      },
      child: Container(
        width: size.width * 0.88,
        height: size.height * 0.12,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(width: 1, color: Colors.black38),
            borderRadius: BorderRadius.circular(9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.1 * 0.4,
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  isNew
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            '신규',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.yellowAccent[100],
                              border: Border.all(
                                  width: 1, color: Colors.redAccent[200]!)),
                          width: size.width * 0.1,
                        )
                      : SizedBox(
                          width: size.width * 0.1,
                        ),
                  VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Text(writer,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        '$date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              height: size.height * 0.1 * 0.4,
            )
          ],
        ),
      ),
    );
  }

  Widget _removeSearchResultWidget(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: size.width * 0.5,
      height: size.height * 0.04,
      decoration: BoxDecoration(
          color: Color(0xFF9EE1E5).withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFF9EE1E5), width: 2)),
      child: TextButton(
        onPressed: () {
          setState(() {
            _isSearch = false;
            _searchController.text = '';
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
            Text('검색 결과창 지우기')
          ],
        ),
      ),
    );
  }
}
