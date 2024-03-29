import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asgshighschool/data/foreground_noti.dart';
import 'package:asgshighschool/main/LibraryQrPage.dart';
import 'package:asgshighschool/main/MealsAPI.dart';
import 'package:asgshighschool/notification/NotificationAction.dart';
import 'package:asgshighschool/util/GlobalVariable.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/ApiUtil.dart';
import '../component/DefaultButtonComp.dart';
import '../data/provider/exist_cart.dart';
import '../data/provider/renew_user.dart';
import 'package:asgshighschool/games/GameListPage.dart';
import 'package:asgshighschool/main/banner/SelectImagePage.dart';
import 'package:asgshighschool/main/auth/SignIn.dart';
import 'package:asgshighschool/store/user/UpdateUserPage.dart';
import 'package:asgshighschool/main/MobileStudentCard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../store/StoreSplashPage.dart';
import 'SettingPage.dart';
import '../data/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../WebViewPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ScrollController? _scrollViewController;
  static TabController? tabController;
  late int _numberOfTabs;
  var mainImage;
  final nameHolder = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isWebLoading = true;
  bool _isAndroid = true;
  bool _isMoved = false;
  bool _controllerWaiting = true;
  String _prefixImgUrl = 'http://nacha01.dothome.co.kr/sin/arlimi_image/';
  List<String?> _bannerImgNameList = [];
  var _swiperController = SwiperController();
  TextEditingController _withdrawPasswordController = TextEditingController();
  late SharedPreferences _pref;
  String _todayMeals = "";

  @override
  void initState() {
    GlobalVariable.isAuthorized = true;
    _initMeals();
    super.initState();
    _getBannerImage();
    _checkUserToken(widget.user!.uid);

    _numberOfTabs = 3;
    tabController = TabController(vsync: this, length: _numberOfTabs);

    if (Platform.isAndroid) {
      _isAndroid = true;
    } else if (Platform.isIOS) {
      _isAndroid = false;
    }
    tabController!.addListener(() {
      if (tabController!.index == 1 && !_isMoved) {
        _isMoved = true;
        _goDuruDuru();
      }
    });
  }

  Future<void> _initMeals() async {
    var result = await MealsAPI().fetchTodayMealInfo();
    setState(() {
      _todayMeals = result;
    });
  }

  Future<bool> _checkUserToken(String? uid) async {
    String url = '${ApiUtil.API_HOST}arlimi_checkUserToken.php';
    final response = await http.post(Uri.parse(url),
        body: <String, String?>{'uid': uid, 'token': GlobalVariable.token});
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (!result.contains('SAME')) {}
      return true;
    } else {
      return false;
    }
  }

  Future<void> _getBannerImage() async {
    String url = '${ApiUtil.API_HOST}main_getAllSelectedImage.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      _bannerImgNameList.clear();
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
        _bannerImgNameList.add(map1st[i]['imgName']);
      }
      setState(() {
        _controllerWaiting = false;
      });
      callNotificationPayload();
    }
  }

  void callNotificationPayload() {
    if (NotificationPayload.isTap) {
      NotificationPayload.isTap = false;
      NotificationAction.selectLocation(NotificationPayload.payload!);
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
    tabController!.index = 0;
    _isMoved = false;
  }

  @override
  void dispose() {
    _scrollViewController?.dispose();
    tabController?.dispose();
    super.dispose();
  }

  Future<bool> _checkExistCart() async {
    String uri = '${ApiUtil.API_HOST}arlimi_checkCart.php';
    final response =
        await http.get(Uri.parse(uri + '?uid=${widget.user!.uid}'));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (int.parse(result) >= 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> _withdrawAccount(String pw) async {
    String url = '${ApiUtil.API_HOST}arlimi_withdrawAccount.php';

    final response = await http.post(Uri.parse(url),
        body: <String, String?>{'uid': widget.user!.uid, 'pw': pw});

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);

      if (result == 'DELETED') {
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
    Size size = MediaQuery.of(context).size;
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
                        imageUrl: _prefixImgUrl + _bannerImgNameList[index]!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Text('이미지를 불러오는데 실패하였습니다.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12));
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
                        'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3406&bbsId=1215'),
                    ink(context, '학교 행사', Icons.text_fields,
                        'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3407&bbsId=1216'),
                    ink(context, '학습 자료실', Icons.question_answer,
                        'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3423&bbsId=1227'),
                    ink(context, '학교 앨범', Icons.book,
                        'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3410&bbsId=1218'),
                  ])),
          Container(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: Text('자주 보는 목록',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Container(color: Color(0xFF105AA1), height: 2.5))
                  ])),
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 5, bottom: 5, top: 5, right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.03),
                    child: Text(
                      '오늘의 급식',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  DefaultButtonComp(
                    onPressed: () {
                      var siteUrl =
                          "https://asgs-h.goeas.kr/asgs-h/ad/fm/foodmenu/selectFoodMenuView.do?mi=3432";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewPage(
                                    title: '오늘의 급식 메뉴',
                                    baseUrl: _isAndroid
                                        ? siteUrl
                                        : 'http://nacha01.dothome.co.kr/school/redirect_22.php?${siteUrl!.split('?')[1].isEmpty ? "" : siteUrl.split('?')[1]}',
                                  )));
                    },
                    child: Container(
                      child: Text(_todayMeals),
                      padding: EdgeInsets.all(size.width * 0.02),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          boxShadow: [BoxShadow(blurRadius: 1)],
                          color: Colors.grey[200],
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      belowBox(
                          context: context,
                          title: '푸러푸러 퀴즈',
                          organizer: '푸러푸러 퀴즈',
                          imageUrl: 'assets/images/quiz.jpg',
                          siteUrl:
                              'http://puhaha.pe.kr/quiz/puhaha_quiz.php?s_id=${widget.user!.uid}',
                          upTitle: '푸러푸러 퀴즈'),
                      belowBox(
                          context: context,
                          title: '설문 조사',
                          organizer: '설문 조사',
                          imageUrl: 'assets/images/sulmun.jpg',
                          siteUrl:
                              'http://puhaha.pe.kr/quiz/sulmun.php?sulmun=${widget.user!.uid}',
                          upTitle: '설문 조사'),
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
                              'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3408&bbsId=1217',
                          upTitle: '가정 통신문'),
                      belowBox(
                          context: context,
                          title: '강서 도서 검색',
                          organizer: '강서 도서 검색',
                          imageUrl: 'assets/images/doseosil.jpg',
                          siteUrl:
                              'https://reading.gglec.go.kr/r/newReading/search/schoolSearchOnlyForm.jsp?schoolCode=895&kind=1',
                          upTitle: '도서 검색')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      belowBox(
                          context: context,
                          title: '이 달의 일정',
                          organizer: '이 달의 일정',
                          imageUrl: 'assets/images/haengsa.jpg',
                          siteUrl:
                              'https://asgs-h.goeas.kr/asgs-h/ps/schdul/selectSchdulMainList.do?mi=3409',
                          upTitle: '이달의 일정'),
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
          resizeToAvoidBottomInset: false,
          // keyboard not slide
          drawer: slidePage(size),
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.account_box_rounded,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MobileStudentCard(
                          user: widget.user,
                        ))),
            backgroundColor: Colors.lightBlueAccent,
          ),
          body: NestedScrollView(
            controller: _scrollViewController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    centerTitle: true,
                    background: Column(children: <Widget>[
                      appBarAbove(),
                    ]),
                  ),
                  leading: Container(),
                  expandedHeight: 100,
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    labelStyle: TextStyle(fontSize: 13),
                    onTap: (index) async {
                      if (index == 2) {
                        tabController!.index = 0;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameListPage(
                                      user: widget.user,
                                    )));
                      }
                    },
                    labelColor: Colors.black,
                    indicatorColor: Colors.blueAccent,
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

  Future<bool> _onBackPressed() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                '정말로 종료하시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              actions: [
                DefaultButtonComp(
                    onPressed: () {
                      while (Navigator.canPop(context)) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text('예',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DefaultButtonComp(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('아니오',
                        style: TextStyle(fontWeight: FontWeight.bold)))
              ],
            )) as bool;
  }

  Widget slidePage(Size size) {
    return Container(
        width: size.width / 1.2,
        height: size.height,
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      children: <Widget>[
                        Text('안산강서 알리미',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.1,
                  child: Center(
                      child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                  'assets/images/asgs_mark_sqare.png'))),
                    ),
                    title: Text(widget.user!.nickName!),
                    subtitle: Text(widget.user!.uid!),
                    trailing: IconButton(
                      icon: Icon(Icons.power_settings_new, size: 30),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('정말로 종료하시겠습니까?'),
                                  actions: [
                                    DefaultButtonComp(
                                        onPressed: () async {
                                          exit(0);
                                        },
                                        child: Text('예')),
                                    DefaultButtonComp(
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
                    DefaultButtonComp(
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
                        child: Text('내 정보 가기',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    DefaultButtonComp(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MobileStudentCard(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(width: 1, color: Colors.black54)),
                        child: Text('모바일 학생증 바로 가기',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
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
                          child: Text('안산강서고',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                      ListTile(
                        title: Text(
                          '학교행사',
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                      title: '학교 행사',
                                      baseUrl:
                                          'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3407&bbsId=1216')));
                        },
                      ),
                      ListTile(
                        title: Text('학습자료실', style: TextStyle(fontSize: 18)),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                      title: '학습 자료',
                                      baseUrl:
                                          'https://asgs-h.goeas.kr/asgs-h/na/ntt/selectNttList.do?mi=3423&bbsId=1227')));
                        },
                      ),
                      ListTile(
                        title: Text('급식 메뉴', style: TextStyle(fontSize: 18)),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                      title: '안산강서고 급식 메뉴',
                                      baseUrl:
                                          'https://asgs-h.goeas.kr/asgs-h/ad/fm/foodmenu/selectFoodMenuView.do?mi=3432')));
                        },
                      ),
                      widget.user!.isAdmin
                          ? ListTile(
                              title: Text('배너 사진 관리',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.red),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectImagePage()));
                              },
                            )
                          : SizedBox(),
                      widget.user!.isAdmin
                          ? ListTile(
                              title: Text('도서관 출입 QR 스캐너',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.red),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LibraryAttendanceQrPage(
                                              admin: widget.user!,
                                            )));
                              },
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(size.width * 0.008),
                    child: Row(children: [
                      DefaultButtonComp(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('로그아웃'),
                                      content: Text('정말로 로그아웃 하시겠습니까?'),
                                      actions: [
                                        DefaultButtonComp(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('취소')),
                                        DefaultButtonComp(
                                            onPressed: () async {
                                              GlobalVariable.isAuthorized =
                                                  false;
                                              _pref = await SharedPreferences
                                                  .getInstance();
                                              await _pref.setBool(
                                                  'checked', false);
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignInPage()));
                                            },
                                            child: Text('로그아웃'))
                                      ],
                                    ));
                          },
                          child: Text('로그아웃',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13))),
                      DefaultButtonComp(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: Text('회원 탈퇴'),
                                        content: Text('정말로 계정을 탈퇴하시겠습니까?'),
                                        actions: [
                                          DefaultButtonComp(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('취소')),
                                          DefaultButtonComp(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title:
                                                              Text('비밀번호 확인'),
                                                          content: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black54,
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .black87)),
                                                            child: TextField(
                                                              obscureText: true,
                                                              controller:
                                                                  _withdrawPasswordController,
                                                              decoration: InputDecoration(
                                                                  hintText:
                                                                      '비밀번호를 입력하세요.',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            ),
                                                          ),
                                                          actions: [
                                                            DefaultButtonComp(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child:
                                                                    Text('취소')),
                                                            DefaultButtonComp(
                                                                onPressed:
                                                                    () async {
                                                                  var result = await _withdrawAccount(
                                                                      _withdrawPasswordController
                                                                          .text
                                                                          .toString());
                                                                  if (result)
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                SignInPage()));
                                                                  else
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                '비밀번호가 옳지 않거나 예상치 못한 문제가 발생하였습니다.');
                                                                },
                                                                child:
                                                                    Text('완료'))
                                                          ],
                                                        ));
                                              },
                                              child: Text('탈퇴',
                                                  style: TextStyle(
                                                      color: Colors.red)))
                                        ]));
                          },
                          child: Text('회원 탈퇴',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)))
                    ])),
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
                      icon:
                          Icon(Icons.menu, size: 40, color: Colors.blueAccent),
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      }),
                  Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.all(6),
                      width: 100,
                      child: Image(
                          image: AssetImage('assets/images/asgs_mark.png'),
                          fit: BoxFit.fitHeight)),
                  Container()
                ])));
  }

  Widget ink(BuildContext context, String title, IconData icon, String url) {
    return InkWell(
        child: Column(children: <Widget>[
          Icon(icon, size: 50),
          Text(title, style: TextStyle(fontSize: 12))
        ]),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewPage(
                        title: title,
                        baseUrl: _isAndroid
                            ? url
                            : 'http://nacha01.dothome.co.kr/school/redirect_22.php?${url.split('?')[1].isEmpty ? "" : url.split('?')[1]}',
                      )));
        });
  }

  Widget belowBox(
      {BuildContext? context,
      String? title,
      required String organizer,
      required String imageUrl,
      String? siteUrl,
      required String upTitle}) {
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
                        context!,
                        MaterialPageRoute(
                            builder: (context) => WebViewPage(
                                  title: title,
                                  baseUrl: _isAndroid
                                      ? siteUrl
                                      : 'http://nacha01.dothome.co.kr/school/redirect_22.php?${siteUrl!.split('?')[1].isEmpty ? "" : siteUrl.split('?')[1]}',
                                )));
                  },
                  child: Stack(alignment: Alignment.topLeft, children: <Widget>[
                    Image(
                      height: 80,
                      width: 300,
                      image: AssetImage(imageUrl),
                    ),
                    Container(
                        padding: EdgeInsets.all(3),
                        color: Color(0xFF646464),
                        child: Text(upTitle,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)))
                  ])),
              Row(children: <Widget>[
                Container(height: 10, width: percentBar, color: Colors.blue)
              ])
            ]));
  }
}
