import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:asgshighschool/main/GameListPage.dart';
import 'package:asgshighschool/memoryGame/MemoryGamePage.dart';
import 'package:provider/provider.dart';

import '../store/StoreSplashPage.dart';
import 'SettingPage.dart';
import '../data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../WebView.dart';

final List<String> imgList = [
  'main_img_1.jpg',
  'main_img_2.jpg',
  'main_img_3.jpg'
];

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.user,
  }) : super(key: key);
  static const routeName = '/home';
  final User user;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ScrollController _scrollViewController;
  static TabController tabController;
  int _numberOfTabs;
  var mainImage;
  final nameHolder = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isWebLoading = true;

  @override
  void initState() {
    super.initState();
    //getMainImage();
    _numberOfTabs = 4;
    tabController = TabController(vsync: this, length: _numberOfTabs);
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void getMainImage() async {
    await Firestore.instance
        .collection('main_img')
        .getDocuments()
        .then((value) {
      mainImage = value;
      print(mainImage.documents[0]['img_url']);
      print(mainImage.documents[0]['img_url2']);
      print(mainImage.documents[0]['img_url3']);

      for (int i = 0; i < 3; ++i) {
        imgList.add(
            mainImage.documents[0][i == 0 ? 'img_url' : 'img_url${i + 1}']);
      }
      print(imgList.length);
    });
  }

  Future<bool> _checkExistCart() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_checkCart.php';
    final response = await http.get(uri + '?uid=${widget.user.uid}');

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (int.parse(result) >= 1) {
        // Provider.of<ExistCart>(this.context).setExistCart(true);
        return true;
      } else {
        // Provider.of<ExistCart>(this.context).setExistCart(false);
        return false;
      }
    } else {
      return false;
    }
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
    final Size size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
    var providedUser = Provider.of<RenewUserData>(context);
    Widget homeTab = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 210,
            child: Swiper(
              control: SwiperControl(),
              autoplay: true,
              pagination: SwiperPagination(alignment: Alignment.bottomCenter),
              itemCount: imgList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {},
                  child: Image(
                    image: AssetImage('assets/images/' + imgList[index]),
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 6, right: 6, top: 10, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ink(context, '공지사항', Icons.search,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030100&searchMasterSid=3'),
                ink(context, '학교 행사', Icons.text_fields,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4'),
                ink(context, '학습 자료실', Icons.question_answer,
                    'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D'),
                ink(context, '학교 앨범', Icons.book,
                    'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030600&searchMasterSid=6'),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 12),
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
              padding:
                  EdgeInsets.only(left: 10, bottom: 10, top: 20, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      belowBox(
                          context: context,
                          title: '오늘의 급식 메뉴',
                          organizer: '오늘의 급식 메뉴',
                          imageUrl: 'assets/images/geubsig.jpg',
                          siteUrl:
                              'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801',
                          upTitle: '오늘의 식단'),
                      belowBox(
                          context: context,
                          title: '이 달의 일정',
                          organizer: '이 달의 일정',
                          imageUrl: 'assets/images/haengsa.jpg',
                          siteUrl:
                              'http://www.asgs.hs.kr/diary/formList.do?menugrp=030500&searchMasterSid=1',
                          upTitle: '이달의 일정'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      belowBox(
                          context: context,
                          title: '가정 통신문',
                          organizer: '가정 통신문',
                          imageUrl: 'assets/images/gajungtongsinmun.jpg',
                          siteUrl:
                              'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030400&searchMasterSid=49',
                          upTitle: '가정 통신문'),
                      belowBox(
                          context: context,
                          title: '강서 도서 검색',
                          organizer: '강서 도서 검색',
                          imageUrl: 'assets/images/doseosil.jpg',
                          siteUrl:
                              'https://reading.gglec.go.kr/r/newReading/search/schoolCodeSetting.jsp?schoolCode=895&returnUrl=',
                          upTitle: '도서 검색')
                    ],
                  ),
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
                      text: ' 안산강서고 알림방입니다.',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      // text: '(교내용입니다.)',
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
        /*
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
                                // titleTestss(index),
                                //'${widget.books.documents[index]['author']}
                                '강서고 컴퓨터 동아리(테라바이트)가 만들어가는 알리미입니다. 많은 기대와 관심 부탁드립니다.',
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
        */
      ],
    );

    /*
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
  */
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
                        //appBarBelow(),
                      ],
                    ),
                  ),
                  leading: Container(), // hambuger menu hide
                  expandedHeight: 100, // space area between appbar and tabbar
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    labelStyle: TextStyle(fontSize: 13),
                    onTap: (index) async {
                      if (index == 1) {
                        tabController.index = 0;
                        var res = await _checkExistCart();
                        data.setExistCart(res);
                        providedUser.setNewUser(widget.user);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StoreSplashPage(
                                      user: widget.user,
                                    )));
                      } else if (index == 3) {
                        tabController.index = 0;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameListPage(
                                      user: widget.user,
                                    )));
                      }
                    },
                    labelColor: Colors.black,
                    indicatorColor: Colors.blueAccent, // 현재 보고 있는 탭을 가리키는 지시자
                    indicatorWeight: 6.0,
                    tabs: <Tab>[
                      Tab(text: "Home"),
                      Tab(text: "두루두루"),
                      Tab(text: "알리미 공지사항"),
                      Tab(
                        text: '게임',
                      )
                    ],
                    controller: tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: [
                homeTab,
                movingToStorePage(),
                asgsMovieTab,
                movingToGamePage()
              ],
            ),
          )),
    );
  }

  Widget movingToStorePage() {
    return Stack();
  }

  Widget movingToGamePage() {
    return Stack();
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
                      if (FirebaseAuth.instance != null)
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
                        Text(
                          '안산강서 알리미',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 15,
                        ),
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
                            image:
                                AssetImage('assets/images/asgs_mark_sqare.png'),
                          )),
                    ),
                    title: Text(widget.user.nickName),
                    subtitle: Text(widget.user.uid),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.power_settings_new,
                        size: 30,
                      ),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('정말로 종료하시겠습니까?'),
                                  actions: [
                                    FlatButton(
                                        onPressed: () async {
                                          if (FirebaseAuth.instance != null)
                                            await FirebaseAuth.instance
                                                .signOut();
                                          exit(0);
                                        },
                                        child: Text('예')),
                                    FlatButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('아니오'))
                                  ],
                                ));
                      },
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
                          height: 45,
                          child: Padding(
                            padding: EdgeInsets.only(left: 60),
                            child: Text(
                              '안산강서고',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )),
                      ListTile(
                        title: Text(
                          '학교행사',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
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
                        title: Text('학습자료실',
                            style: TextStyle(
                              fontSize: 18,
                            )),
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
                        title: Text('급식 메뉴',
                            style: TextStyle(
                              fontSize: 18,
                            )),
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
                      // ElevatedButton(
                      //   child: Text("설문조사 바로가기"),
                      //   // color: Colors.white,
                      //   onPressed: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => WebViewPage(
                      //                   title: '강서 설문조사',
                      //                   baseUrl:
                      //                       'https://docs.google.com/forms/d/1Ql4kIHZduTRZ4pExAoImEQr6IaVDI0mQ8dm-nuMtQU8/edit',
                      //                 )));
                      //   },
                      // ),
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
                                leading: IconButton(
                                  icon: Icon(Icons.settings),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingPage()));
                                  },
                                ),
                                title: Text('제작 : 컴퓨터동아리(테라바이트)')),
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
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                size: 40,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            Container(
              margin: EdgeInsets.only(right: 15),
              padding: EdgeInsets.all(6),
              width: 100,
              child: Image(
                image: AssetImage('assets/images/asgs_mark.png'),
                fit: BoxFit.fitHeight,
              ),
            ),
            Container()
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

Widget belowBox(
    {BuildContext context,
    String title,
    String organizer,
    String imageUrl,
    String siteUrl,
    @required String upTitle}) {
  double percentBar = 166;
  return Container(
    height: 150,
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
                padding: EdgeInsets.all(3),
                color: Color(0xFF646464),
                child: Text(
                  upTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
          ],
        ),
      ],
    ),
  );
}
