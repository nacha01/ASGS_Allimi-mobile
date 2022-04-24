import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:asgshighschool/main/GameListPage.dart';
import 'package:asgshighschool/main/SelectImagePage.dart';
import 'package:asgshighschool/store/UpdateUserPage.dart';
import 'package:asgshighschool/store/MobileStudentCard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../store/StoreSplashPage.dart';
import 'SettingPage.dart';
import '../data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import '../WebView.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.user, this.token}) : super(key: key);
  final User user;
  final String token;

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
  bool _isAndroid = true;
  bool _isMoved = false;
  bool _controllerWaiting = true;
  String _prefixImgUrl = 'http://nacha01.dothome.co.kr/sin/arlimi_image/';
  List<String> _bannerImgNameList = [];
  var _swiperController = SwiperController();

  @override
  void initState() {
    super.initState();
    _getBannerImage();
    _checkUserToken(widget.user.uid);
    _numberOfTabs = 3;
    tabController = TabController(vsync: this, length: _numberOfTabs);

    if (Platform.isAndroid) {
      _isAndroid = true;
    } else if (Platform.isIOS) {
      _isAndroid = false;
    }
    tabController.addListener(() {
      if (tabController.index == 1 && !_isMoved) {
        _isMoved = true;
        _goDuruDuru();
      }
    });
  }

  Future<bool> _checkUserToken(String uid) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_checkUserToken.php';
    final response = await http
        .post(url, body: <String, String>{'uid': uid, 'token': widget.token});
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      print(result);
      if (!result.contains('SAME')) {}
      return true;
    } else {
      return false;
    }
  }

  Future<void> _getBannerImage() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/main_getAllSelectedImage.php';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      _bannerImgNameList.clear();
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
        _bannerImgNameList.add(map1st[i]['imgName']);
      }
      setState(() {
        _controllerWaiting = false;
      });
    }
  }

  void _goDuruDuru() async {
    var res = await _checkExistCart();
    var data = Provider.of<ExistCart>(context, listen: false);
    data.setExistCart(res);
    var data2 = Provider.of<RenewUserData>(context, listen: false);
    data2.setNewUser(widget.user);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StoreSplashPage(
                  user: widget.user,
                )));
    tabController.index = 0;
    _isMoved = false;
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    tabController.dispose();
    super.dispose();
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
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
    var providedUser = Provider.of<RenewUserData>(context);
    Widget homeTab = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 210,
            child: _controllerWaiting
                ? SizedBox()
                : Swiper(
                    controller: _swiperController,
                    autoplay: true,
                    pagination:
                        SwiperPagination(alignment: Alignment.bottomCenter),
                    itemCount: _bannerImgNameList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CachedNetworkImage(
                        imageUrl: _prefixImgUrl + _bannerImgNameList[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Text(
                            '이미지를 불러오는데 실패하였습니다.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          );
                        },
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
                      if (index == 2) {
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
                      Tab(text: '게임')
                    ],
                    controller: tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: [homeTab, movingToStorePage(), movingToGamePage()],
            ),
          )),
    );
  }

  Widget movingToStorePage() {
    return Stack(
      children: [
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('잠시만 기다려주세요. 화면 전환 대기 중...'),
            CircularProgressIndicator()
          ],
        ))
      ],
    );
  }

  Widget movingToGamePage() {
    return Stack();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                '정말로 종료하시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      while (Navigator.canPop(context)) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text('예',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('아니오',
                        style: TextStyle(fontWeight: FontWeight.bold)))
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
                Row(
                  children: [
                    TextButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateUserPage(
                                        user: widget.user,
                                      )));
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(width: 1, color: Colors.black54)),
                          child: Text(
                            '내 정보 가기',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MobileStudentCard(
                                  user: widget.user,
                                )
                        ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(width: 1, color: Colors.black54)),
                        child: Text(
                          '모바일 학생증 바로 가기',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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
                                        baseUrl: _isAndroid
                                            ? 'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4'
                                            : 'http://nacha01.dothome.co.kr/school/redirect_22.php?menugrp=030200&searchMasterSid=4',
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
                                        baseUrl: _isAndroid
                                            ? 'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D'
                                            : 'http://nacha01.dothome.co.kr/school/redirect_22.php?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D',
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
                                        baseUrl: _isAndroid
                                            ? 'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801'
                                            : 'http://nacha01.dothome.co.kr/school/redirect_22.php?menugrp=040801',
                                      )));
                        },
                      ),
                      widget.user.isAdmin
                          ? ListTile(
                              title: Text('배너 사진 관리',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.red,
                              ),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectImagePage()));
                              },
                            )
                          : SizedBox(),
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
                        baseUrl: _isAndroid
                            ? url
                            : 'http://nacha01.dothome.co.kr/school/redirect_22.php?${url.split('?')[1]}',
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
                            baseUrl: _isAndroid
                                ? siteUrl
                                : 'http://nacha01.dothome.co.kr/school/redirect_22.php?${siteUrl.split('?')[1]}',
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
}
