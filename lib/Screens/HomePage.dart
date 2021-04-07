import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../WebView.dart';
// ignore: unused_import
import 'Insert/BookPage.dart';

final List<String> imgList = [
  'http://www.asgs.hs.kr/design/html/images/img_010800_01.gif',
  'http://www.asgs.hs.kr/design/html/images/img_010300_01.gif',
  'http://www.asgs.hs.kr/design/html/images/20200420_YK_001.png'
];

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.user,
    this.books,
  }) : super(key: key);
  static const routeName = '/home';
  final FirebaseUser user;
  var books;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ScrollController _scrollViewController;
  TabController _tabController;
  int _numberOfTabs;

  final nameHolder = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ignore: unused_field
  String _keyword = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.books);
    _numberOfTabs = 3;
    _tabController = TabController(vsync: this, length: _numberOfTabs);
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<List> gets() async {
    String url = 'https://www.googleapis.com/youtube/v3/search?';
    String query = 'q=플러터';
    String key = '[Your API Key]';
    String part = 'snippet';
    String maxResults = '7';
    String type = 'video';

    List jsonData = [];

    url = '$url$query&key=$key&part=$part&maxResults=$maxResults&type=$type';
    await http.get(url, headers: {"Accept": "application/json"}).then((value) {
      var data = json.decode(value.body);
      for (var c in data['items']) {
        jsonData.add(c);
      }
    });
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder asgs_movieTab() {
      return FutureBuilder(
          //future: gets(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 15),
            ),
          );
        } else {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: '인기 강의들 ',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Picks 추천 [sample]',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ])),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                          title: snapshot.data[index]['snippet']
                                              ['title'],
                                          baseUrl: 'http://google.com/',
                                        )));
                          },
                          child: Card(
                              child: Container(
                            margin: EdgeInsets.all(10),
                            height: 90,
                            child: Row(
                              children: [
                                Container(
                                  width: 150,
                                  child: Image.network(
                                    snapshot.data[index]['snippet']
                                        ['thumbnails']['medium']['url'],
                                  ),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data[index]['snippet']
                                            ['title'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        snapshot.data[index]['snippet']
                                            ['channelTitle'],
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        snapshot.data[index]['snippet']
                                            ['publishTime'],
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )));
                    }),
              )
            ],
          );
        }
      });
    }

    Widget homeTab = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 210,
            child: Swiper(
                autoplay: true,
                viewportFraction: 0.8,
                control: SwiperControl(),
                pagination: SwiperPagination(alignment: Alignment.bottomRight),
                itemCount: imgList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.network(imgList[index]);
                }),
          ),
          Padding(
            padding: EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ink(context, '공지사항_', Icons.search,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030100&searchMasterSid=3'),
                ink(context, '학교 행사', Icons.text_fields,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4'),
                ink(context, '가정 통신문', Icons.share,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030400&searchMasterSid=49'),
                ink(context, '학습 자료실', Icons.question_answer,
                    'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D'),
                ink(context, '학교 앨범', Icons.book,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030600&searchMasterSid=6'),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10, left: 10),
                    child: Text(
                      '자주 보는 목록',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Container(
                      color: Color(0xFF105AA1),
                      height: 2.5,
                    ),
                  )
                ],
              )),
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  metting(
                      context,
                      '이 달의 일정',
                      '이 달의 일정',
                      true,
                      'assets/images/we_make_book1.JPG',
                      'http://www.asgs.hs.kr/diary/formList.do?menugrp=030500&searchMasterSid=1',
                      57,
                      false),
                  metting(
                      context,
                      '오늘의 급식 메뉴',
                      '오늘의 급식 메뉴',
                      false,
                      'assets/images/we_make_book2.JPG',
                      'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801',
                      100,
                      true)
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget asgsMovieTab = Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: '강서 디지털 영상 모음 ',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '(교내용입니다.)',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ])),
              Spacer(),
              //Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.books.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => BookPage(
                  //               user: widget.user,
                  //               Book_data: widget.books,
                  //               number: index)));
                  // },
                  child: Card(
                      child: Container(
                    margin: EdgeInsets.all(10),
                    width: 140,
                    height: 140,
                    child: Row(
                      children: [
                        Image.network(widget.books.documents[index]['img_url']),
                        SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '강서고 컴퓨터에서 만들어진 영상을 모아 디지털 역사관을 만들고 있습니다.',
                                //widget.books.documents[index]['name'],
                                style: TextStyle(fontSize: 15),
                              ),
                              Spacer(),
                              Text(
                                '안산강서고',
                                //widget.books.documents[index]['author'],
                                style: TextStyle(color: Colors.grey),
                              ),
                              //Text(widget.books.documents[index]['publisher']),
                              //Text(
                              //'${numberWithComma(widget.books.documents[index]['value'])}원',
                              //style:
                              //  TextStyle(color: Colors.blue, fontSize: 18),
                              //),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                );
              }),
        ),
      ],
    );

    Widget interviewTab = Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: '수시 면접 기출 문제 모음 ',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '(교내용입니다.)',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ])),

              Spacer(),
              //Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.books.documents.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => BookPage(
                  //               user: widget.user,
                  //               Book_data: widget.books,
                  //               number: index)));
                  // },
                  child: Card(
                      child: Container(
                    margin: EdgeInsets.all(10),
                    width: 140,
                    height: 140,
                    child: Row(
                      children: [
                        Image.network(widget.books.documents[index]['img_url']),
                        SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '수시에 지원한 선배들이 남긴 자료입니다. 이 자료는 안산강서고 교내에서만 열람이 가능합니다.',
                                //widget.books.documents[index]['name'],
                                style: TextStyle(fontSize: 15),
                              ),
                              Spacer(),
                              Text(
                                '안산강서고',
                                //widget.books.documents[index]['author'],
                                style: TextStyle(color: Colors.grey),
                              ),
                              //Text(widget.books.documents[index]['publisher']),
                              //Text(
                              //'${numberWithComma(widget.books.documents[index]['value'])}원',
                              //style:
                              //  TextStyle(color: Colors.blue, fontSize: 18),
                              //),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                );
              }),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomInset: false, // keyboard not slide
          drawer: slidePage(),
          key: _scaffoldKey,
          body: NestedScrollView(
            controller: _scrollViewController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white, // app bar color
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    centerTitle: true,
                    background: Column(
                      children: <Widget>[
                        appBarAbove(),
                        appBarBelow(),
                      ],
                    ),
                  ),
                  leading: Container(), // hambuger menu hide
                  expandedHeight: 140, // 탭바의 높이
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Colors.blueAccent, // 현재 보고 있는 탭을 가리키는 지시자
                    indicatorWeight: 6.0,
                    tabs: <Tab>[
                      Tab(text: "Home"),
                      Tab(text: "면접 후기"),
                      Tab(text: "영상 모음"),
                    ],
                    controller: _tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                homeTab,
                interviewTab,
                asgsMovieTab,

                //asgs_movieTab(),
              ],
            ),
          )),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('정말로 종료하시겠습니까?'),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text('예')),
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('아니오'))
              ],
            ));
  }

  Widget slidePage() {
    return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        Text('테라바이트 프로젝트'),
                        Spacer(),
                        SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          icon: Icon(Icons.power_settings_new),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/signin', (route) => false,
                                arguments: widget.books);
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  child: Center(
                      child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              'http://www.asgs.hs.kr/design/html/images/img_010800_01.gif',
/*widget.user.photoUrl*/
                            ),
                          )),
                    ),
                    title: Text(' ' /*widget.user.displayName*/),
                    subtitle: Text('' /*widget.user.email*/),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                    ),
                  )),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          color: Color(0xFFF2F2F2),
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              '안산강서고',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          )),
                      ListTile(
                        title: Text('학교행사 ham'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                        title: '학교 행사',
                                        baseUrl:
                                            'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4',
                                      )));
                        },
                      ),
                      ListTile(
                        title: Text('학습자료실'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                        title: '학습 자료',
                                        baseUrl:
                                            'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D',
                                      )));
                        },
                      ),
                      ListTile(
                        title: Text('급식 메뉴'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                        title: '안산강서고 급식 메뉴',
                                        baseUrl:
                                            'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801',
                                      )));
                        },
                      ),
                      ElevatedButton(
                        child: Text("설문조사 바로가기"),
                        // color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                        title: '인프런 보안 프로젝트',
                                        baseUrl: 'http://nacha01.dotname.co.kr',
                                      )));
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                            child: Column(
                          children: <Widget>[
                            Divider(),
                            ListTile(
                                leading: Icon(Icons.settings),
                                title: Text('Settings')),
                            ListTile(
                                onTap: () {},
                                leading: Icon(Icons.help),
                                title: Text('Developer Blog'))
                          ],
                        ))))
              ],
            )));
  }

  Widget appBarAbove() {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, right: 4.5, left: 4.5),
      child: Container(
        height: 36,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                size: 28,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 8),
                width: 100,
                child: Image(
                  image: AssetImage('assets/images/bp.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget appBarBelow() {
    return Padding(
        padding: EdgeInsets.only(top: 0, right: 17, left: 17),
        child: TextField(
          controller: nameHolder,
          autocorrect: true,
        ));
  }
}

String numberWithComma(int param) {
  return NumberFormat('###,###,###,###').format(param).replaceAll(' ', '');
}

Widget ink(BuildContext context, String title, IconData icon, String url) {
  return InkWell(
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 50,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(
                      title: title,
                      baseUrl: url,
                    )));
      });
}

Widget metting(
    BuildContext context,
    String title,
    String organizer,
    bool status,
    String imageUrl,
    String siteUrl,
    int percent,
    bool participation) {
  double percentBar = 166 * percent / 100;
  return Container(
    height: 210,
    width: 170,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewPage(
                          title: title,
                          baseUrl: siteUrl,
                        )));
          },
          child: Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              Image(
                height: 80,
                width: 300,
                image: AssetImage(
                  imageUrl,
                ),
              ),
              Container(
                  height: 30,
                  width: 80,
                  color: Color(0xFF646464),
                  child: Center(
                    child: status
                        ? Text(
                            '이 달 일정',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '오늘의 식단',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                overflow: TextOverflow.ellipsis,
                strutStyle: StrutStyle(fontSize: 12.0),
                text: TextSpan(
                    style: TextStyle(color: Colors.black), text: title),
              ),
              Text(organizer, style: TextStyle(color: Color(0xFF8D8D8D))),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              height: 10,
              width: percentBar,
              color: Colors.blue,
            ),
            Container(
              height: 10,
              width: 166 - percentBar,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    ),
  );
}
