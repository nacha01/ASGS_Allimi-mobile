import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/AddProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/product_data.dart';

class StoreMainPage extends StatefulWidget {
  StoreMainPage({this.user, this.product});
  final User user;
  List<Product> product;
  @override
  _StoreMainPageState createState() => _StoreMainPageState();
}

class _StoreMainPageState extends State<StoreMainPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollViewController;
  TextEditingController _searchController = TextEditingController();
  int _currentNav = 0;
  List<Widget> _productLayoutList = [];
  List<Product> _productList;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollViewController = ScrollController();
    _productList = widget.product;
    for (int i = 0; i < _productList.length; ++i) {
      var tmp = _productList[i];
      _productLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false));
    }
  }

  List<Widget> bottomTapWidgets = [];

  Future<List<Product>> _getProducts() async {
    print('음?');
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        print('일일 트래픽 모두 사용');
        // 임시 유저로 이동
        return [];
      }
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List productList = json.decode(result);
      List<Product> prodObjects = [];
      for (int i = 0; i < productList.length; ++i) {
        prodObjects.add(Product.fromJson(json.decode(productList[i])));
      }
      _productList = prodObjects;
      _productLayoutList.clear();
      for (int i = 0; i < _productList.length; ++i) {
        var tmp = _productList[i];
        _productLayoutList
            .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false));
        setState(() {});
      }
      return prodObjects;
      // 디코딩의 디코딩 작업 필요 (두번의 json 디코딩)
      // 가장 바깥쪽 array를 json으로 변환하고
      // 내부 데이터를 json으로 변환
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(child: getWidgetAccordingIndex(_currentNav, size)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNav,
        onTap: (index) {
          setState(() {
            _currentNav = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm_rounded), label: '알림'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: '장바구니'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지')
        ],
      ),
    );
  }

  Widget getWidgetAccordingIndex(int index, Size size) {
    switch (index) {
      case 0:
        return NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.white,
                expandedHeight: 110,
                forceElevated: innerBoxIsScrolled,
                leadingWidth: size.width * 0.18,
                centerTitle: true,
                title: aboveTap(size),
                leading: Container(
                    margin: EdgeInsets.only(left: 9),
                    alignment: Alignment.center,
                    child: Text(
                      '나래',
                      style: TextStyle(
                        color: Color(0xFF9EE1E5),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    )),
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: 'BEST',
                    ),
                    Tab(
                      text: 'NEW',
                    ),
                    Tab(
                      text: 'EVENT',
                    ),
                    Tab(
                      text: 'MENU',
                    )
                  ],
                  labelColor: Colors.black,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  indicatorColor: Color(0xFF9EE1E5),
                  indicatorWeight: 6.0,
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
            ];
          },
          body: TabBarView(controller: _tabController, children: [
            _productLayoutList.length == 0
                ? RefreshIndicator(
                    onRefresh: _getProducts,
                    child: Column(
                      children: [
                        addProductForAdmin(size),
                        SizedBox(
                          height: size.width * 0.02,
                        ),
                        Center(
                            child: Text(
                          '상품이 없습니다.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        )),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _getProducts,
                    child: Column(
                      children: [
                        addProductForAdmin(size),
                        SizedBox(
                          height: size.width * 0.02,
                        ),
                        Expanded(
                          child: Container(
                            height: size.height * 1.07,
                            child: GridView.count(
                                padding: EdgeInsets.all(10),
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 15,
                                crossAxisCount: 2,
                                children: _productLayoutList),
                          ),
                        ),
                      ],
                    ),
                  ),
            RefreshIndicator(
              onRefresh: _getProducts,
              child: Column(
                children: [
                  addProductForAdmin(size),
                  SizedBox(
                    height: size.width * 0.02,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.blue,
            ),
            RefreshIndicator(
              onRefresh: _getProducts,
              child: Column(
                children: [
                  addProductForAdmin(size),
                  SizedBox(
                    height: size.width * 0.02,
                  ),
                  Container(
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ]),
        );
      case 1: // 알림
        return Center();
      case 2: // 장바구니
        return Center();
      case 3: // 마이페이지
        return StoreMyPage(
          user: widget.user,
        );
      default: // 없음
        return Center();
    }
  }

  Widget itemTile(String imgUrl, int price, String prodName, bool isWish) {
    return GestureDetector(
      onTap: () {
        print('클릭함');
      },
      onLongPress: () {},
      child: Column(
        children: [
          Expanded(
            //핵심.... Stack의 높이는 정해져있지 않아서 Expanded로?..
            child: Stack(
              children: [
                ClipRRect(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, object, stackTrace) {
                      return Container(
                          alignment: Alignment.center,
                          color: Colors.grey[400],
                          child: Text('No Image'));
                    },
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                Positioned(
                    bottom: 8,
                    right: 8,
                    child:
                        Icon(isWish ? Icons.favorite : Icons.favorite_border))
              ],
            ),
          ),
          Text('$price'),
          Text(prodName)
        ],
      ),
    );
  }

  Widget aboveTap(Size size) {
    return Container(
      margin: EdgeInsets.all(5),
      width: size.width * 0.78,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Color(0xFF9EE1E5)),
      child: TextField(
        onSubmitted: (text) {
          //완료 버튼 눌렀을 때
          print(text);
        },
        decoration: InputDecoration(
            hintText: 'search',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
            )),
        controller: _searchController,
      ),
    );
  }

  Widget managerAddingProductLayout(Size size) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      width: size.width * 0.98,
      height: size.height * 0.05,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: GestureDetector(
        onTap: () {
          // print('누름');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddingProductPage()));
        },
        child: Text(
          '상품 추가하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget addProductForAdmin(Size size) {
    return widget.user.isAdmin ? managerAddingProductLayout(size) : SizedBox();
  }
}
