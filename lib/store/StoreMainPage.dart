import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/AnnouncePage.dart';
import 'package:asgshighschool/store/CartPage.dart';
import 'package:asgshighschool/store/DetailProductPage.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/AddProduct.dart';
import 'package:asgshighschool/storeAdmin/UpdateProduct.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../data/product_data.dart';

class StoreMainPage extends StatefulWidget {
  StoreMainPage({this.user, this.product, this.existCart});
  final User user;
  final List<Product> product;
  final bool existCart;
  @override
  _StoreMainPageState createState() => _StoreMainPageState();
}

class _StoreMainPageState extends State<StoreMainPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollViewController;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _adminKeyController = TextEditingController();
  int _currentNav = 0;
  List<Product> _productList = [];
  List<Widget> _productLayoutList = [];

  List<Product> _newProductList = [];
  List<Widget> _newProductLayoutList = [];

  List<Product> _bestProductList = [];
  List<Widget> _bestProductLayoutList = [];

  List<Product> _foodProductList = [];
  List<Widget> _foodProductLayoutList = [];

  List<Product> _snackProductList = [];
  List<Widget> _snackProductLayoutList = [];

  List<Product> _beverageProductList = [];
  List<Widget> _beverageProductLayoutList = [];

  List<Product> _stationeryProductList = [];
  List<Widget> _stationeryProductLayoutList = [];

  List<Product> _handmadeProductList = [];
  List<Widget> _handmadeProductLayoutList = [];

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollViewController = ScrollController();
    _productList = widget.product;
    for (int i = 0; i < _productList.length; ++i) {
      var tmp = _productList[i];
      _productLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
    _groupingProduct();
  }

  void _groupingProduct() {
    for (int i = 0; i < _productList.length; ++i) {
      if (_productList[i].isBest == 1 && _productList[i].isNew == 1) {
        _bestProductList.add(_productList[i]);
        _newProductList.add(_productList[i]);
      } else if (_productList[i].isBest == 1) {
        _bestProductList.add(_productList[i]);
      } else if (_productList[i].isNew == 1) {
        _newProductList.add(_productList[i]);
      }
      switch (_productList[i].category) {
        case 0: // 음식류
          _foodProductList.add(_productList[i]);
          break;
        case 1: // 간식류
          _snackProductList.add(_productList[i]);
          break;
        case 2: // 음료류
          _beverageProductList.add(_productList[i]);
          break;
        case 3: // 문구류
          _stationeryProductList.add(_productList[i]);
          break;
        case 4: // 핸드메이드
          _handmadeProductList.add(_productList[i]);
          break;
      }
    }
    getBestProdLayout();
    getNewProdLayout();
    getFoodProdLayout();
    getSnackProdLayout();
    getBeverageProdLayout();
    getStationeryProdLayout();
    getHandmadeProdLayout();
  }

  String _formatPrice(int price) {
    String p = price.toString();
    String newFormat = '';
    int count = 0;
    for (int i = p.length - 1; i >= 0; --i) {
      if ((count + 1) % 4 == 0) {
        newFormat += ',';
        ++i;
      } else
        newFormat += p[i];
      ++count;
    }
    return _reverseString(newFormat);
  }

  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  void getNewProdLayout() {
    for (int i = 0; i < _newProductList.length; ++i) {
      var tmp = _newProductList[i];
      _newProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getBestProdLayout() {
    for (int i = 0; i < _bestProductList.length; ++i) {
      var tmp = _bestProductList[i];
      _bestProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getFoodProdLayout() {
    for (int i = 0; i < _foodProductList.length; ++i) {
      var tmp = _foodProductList[i];
      _foodProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getSnackProdLayout() {
    for (int i = 0; i < _snackProductList.length; ++i) {
      var tmp = _snackProductList[i];
      _snackProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getBeverageProdLayout() {
    for (int i = 0; i < _beverageProductList.length; ++i) {
      var tmp = _beverageProductList[i];
      _beverageProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getStationeryProdLayout() {
    for (int i = 0; i < _stationeryProductList.length; ++i) {
      var tmp = _stationeryProductList[i];
      _stationeryProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  void getHandmadeProdLayout() {
    for (int i = 0; i < _handmadeProductList.length; ++i) {
      var tmp = _handmadeProductList[i];
      _handmadeProductLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
    }
  }

  int _getLengthOfCurrentCategory(int position) {
    switch (position) {
      case 0:
        return _productLayoutList.length;
      case 1:
        return _foodProductLayoutList.length;
      case 2:
        return _snackProductLayoutList.length;
      case 3:
        return _beverageProductLayoutList.length;
      case 4:
        return _stationeryProductLayoutList.length;
      case 5:
        return _handmadeProductLayoutList.length;
      default:
        return -1;
    }
  }

  /// product table에 있는 모든 상품 데이터를 요청
  /// @param : X
  /// @result : X [중간 과정에 상품을 분류하는 작업을 함]
  Future<void> _getProducts() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        print('일일 트래픽 모두 사용');
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
      _newProductLayoutList.clear();
      _bestProductLayoutList.clear();
      _newProductList.clear();
      _bestProductList.clear();
      _handmadeProductLayoutList.clear();
      _handmadeProductList.clear();
      _beverageProductList.clear();
      _beverageProductLayoutList.clear();
      _foodProductList.clear();
      _foodProductLayoutList.clear();
      _snackProductList.clear();
      _snackProductLayoutList.clear();
      _stationeryProductLayoutList.clear();
      _stationeryProductList.clear();

      for (int i = 0; i < _productList.length; ++i) {
        var tmp = _productList[i];
        _productLayoutList
            .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
      }
      setState(() {
        _groupingProduct();
      });
    }
  }

  /// 관리자가 상품을 삭제하는 HTTP 요청
  /// @param : 상품 ID -> PK of product table
  /// @result : 삭제가 정상적으로 되었는지에 대한 bool 값
  Future<bool> _deleteProductRequest(int productID) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_deleteProduct.php';
    final response = await http.get(url + '?id=$productID');
    if (response.statusCode == 200) {
      print(response.body);
      if (response.body.contains('DELETED')) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  /// 관리자임을 인증하는 HTTP 요청
  /// @param : HTTP GET : UID 값과 ADMIN KEY 값
  /// @result : 관리자 인증이 되었는지에 대한 bool 값
  Future<bool> _certifyAdminAccess() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_adminCertified.php';
    final response = await http
        .get(uri + '?uid=${widget.user.uid}&key=${_adminKeyController.text}');

    if (response.statusCode == 200) {
      if (response.body.contains('CERTIFIED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> showToast(String message, bool fail) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        textColor: fail ? Colors.deepOrange : Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
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
          BottomNavigationBarItem(
              icon: data.isExistCart
                  ? Badge(
                      alignment: Alignment.topRight,
                      animationType: BadgeAnimationType.scale,
                      padding: EdgeInsets.all(6),
                      position: BadgePosition.topEnd(top: -15, end: -17),
                      child: Icon(Icons.shopping_cart),
                      shape: BadgeShape.circle,
                      badgeContent: Text(
                        '!',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Icon(Icons.shopping_cart),
              label: '장바구니'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm_rounded), label: '알림'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지')
        ],
      ),
    );
  }

  Widget getWidgetAccordingIndex(int index, Size size) {
    switch (index) {
      case 0:
        return RefreshIndicator(
          onRefresh: _getProducts,
          child: NestedScrollView(
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
              _bestProductLayoutList.length == 0
                  ? RefreshIndicator(
                      onRefresh: _getProducts,
                      child: Column(
                        children: [
                          addProductForAdmin(size),
                          Expanded(
                            child: Center(
                                child: Text(
                              '베스트 상품이 없습니다1',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 21),
                            )),
                          ),
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
                              child: GridView.builder(
                                  itemCount: _bestProductLayoutList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 1),
                                  itemBuilder: (context, index) {
                                    return _bestProductLayoutList[index];
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
              /*------------ BEST TAB ---------------*/
              _newProductLayoutList.length == 0
                  ? RefreshIndicator(
                      onRefresh: _getProducts,
                      child: Column(
                        children: [
                          addProductForAdmin(size),
                          Expanded(
                            child: Center(
                                child: Text(
                              '신규 상품이 없습니다!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 21),
                            )),
                          ),
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
                              child: GridView.builder(
                                  itemCount: _newProductLayoutList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 1),
                                  itemBuilder: (context, index) {
                                    return _newProductLayoutList[index];
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
              /*------------ NEW TAB ---------------*/
              Container(
                child: Center(
                  child: Text('이벤트가 없습니다!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
                ),
              ),
              /*------------ EVENT TAB ---------------*/
              if (_productLayoutList.length == 0)
                RefreshIndicator(
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
              else
                RefreshIndicator(
                  onRefresh: _getProducts,
                  child: Column(
                    children: [
                      addProductForAdmin(size),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Card(
                        elevation: 2,
                        child: Container(
                          margin: EdgeInsets.all(5),
                          height: size.height * 0.10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedCategory != 1)
                                      _selectedCategory = 1;
                                    else
                                      _selectedCategory = 0;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.19,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Image.asset(_selectedCategory ==
                                                1
                                            ? "assets/images/dinner_on_icon.jpg"
                                            : "assets/images/dinner_icon.jpg"),
                                        height: size.height * 0.07,
                                      ),
                                      Text('음식류',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _selectedCategory == 1
                                                  ? Color(0xFF9EE1E5)
                                                  : Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedCategory != 2)
                                      _selectedCategory = 2;
                                    else
                                      _selectedCategory = 0;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.19,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Image.asset(_selectedCategory ==
                                                2
                                            ? "assets/images/candy_on_icon.jpg"
                                            : "assets/images/candy_icon.jpg"),
                                        height: size.height * 0.07,
                                      ),
                                      Text('간식류',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _selectedCategory == 2
                                                  ? Color(0xFF9EE1E5)
                                                  : Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedCategory != 3)
                                      _selectedCategory = 3;
                                    else
                                      _selectedCategory = 0;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.19,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Image.asset(_selectedCategory ==
                                                3
                                            ? "assets/images/drink_on_icon.jpg"
                                            : "assets/images/drink_icon.jpg"),
                                        height: size.height * 0.07,
                                      ),
                                      Text('음료류',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _selectedCategory == 3
                                                  ? Color(0xFF9EE1E5)
                                                  : Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedCategory != 4)
                                      _selectedCategory = 4;
                                    else
                                      _selectedCategory = 0;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.19,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Image.asset(_selectedCategory ==
                                                4
                                            ? "assets/images/pencil_on_icon.jpg"
                                            : "assets/images/pencil_icon.jpg"),
                                        height: size.height * 0.07,
                                      ),
                                      Text('문구류',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _selectedCategory == 4
                                                  ? Color(0xFF9EE1E5)
                                                  : Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedCategory != 5)
                                      _selectedCategory = 5;
                                    else
                                      _selectedCategory = 0;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.19,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Image.asset(_selectedCategory ==
                                                5
                                            ? "assets/images/handmade_on_icon.jpg"
                                            : "assets/images/handmadeicon.jpg"),
                                        height: size.height * 0.07,
                                      ),
                                      Text('핸드메이드',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _selectedCategory == 5
                                                  ? Color(0xFF9EE1E5)
                                                  : Colors.black))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      _getLengthOfCurrentCategory(_selectedCategory) == 0
                          ? Expanded(
                              child: Center(
                                  child: Text(
                                '상품이 없습니다!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 21),
                              )),
                            )
                          : Expanded(
                              child: Container(
                                height: size.height,
                                child: GridView.builder(
                                    itemCount: _getLengthOfCurrentCategory(
                                        _selectedCategory),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 15,
                                            crossAxisSpacing: 1),
                                    itemBuilder: (context, index) {
                                      return _getItemTileOfCurrentCategory(
                                          index, _selectedCategory);
                                    }),
                              ),
                            ),
                    ],
                  ),
                ),
              /*------------ MENU TAB ---------------*/
            ]),
          ),
        );
      case 1: // 장바구니
        return CartPage(user: widget.user);
      case 2: // 알림
        return AnnouncePage(
          user: widget.user,
        );
      case 3: // 마이페이지
        return StoreMyPage(
          user: widget.user,
        );
      default: // 없음
        return Center();
    }
  }

  Widget itemTile(
      String imgUrl, int price, String prodName, bool isWish, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailProductPage(
                      user: widget.user,
                      product: product,
                    )));
      },
      onLongPress: () async {
        // 상품 수정 및 삭제 기능 -> 어드민 권한으로 동작
        if (widget.user.isAdmin) {
          // 메뉴에서 선택한 값(value)를 리턴함
          var selected = await showMenu(
            color: Colors.cyan[100],
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black26, width: 2)),
            context: context,
            position: RelativeRect.fromLTRB(120, 75, 165, 75),
            items: [
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.delete),
                    Text('삭제하기'),
                  ],
                ),
                value: 'delete',
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.update),
                    Text('수정하기'),
                  ],
                ),
                value: 'modify',
              ),
            ],
          );
          switch (selected) {
            case 'delete':
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        title: Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.red,
                          size: 60,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '※이 상품을 삭제하시겠습니까?',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '[${product.prodName}]',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )
                          ],
                        ),
                        actions: [
                          FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('아니요')),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('관리자 키 Key 입력'),
                                          content: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.orange[200]),
                                                color: Colors.blue[100]),
                                            child: TextField(
                                              inputFormatters: [
                                                UpperCaseTextFormatter()
                                              ],
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Admin Key'),
                                              controller: _adminKeyController,
                                            ),
                                          ),
                                          actions: [
                                            FlatButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text('취소')),
                                            FlatButton(
                                                onPressed: () async {
                                                  var result =
                                                      await _certifyAdminAccess(); // 어드민 키 인증
                                                  if (result) {
                                                    var res =
                                                        await _deleteProductRequest(
                                                            product
                                                                .prodID); // DB에서 상품 삭제
                                                    if (res) {
                                                      Navigator.pop(ctx);
                                                      showToast(
                                                          '삭제가 완료되었습니다. 목록을 새로고침 바랍니다.',
                                                          false);
                                                    } else {
                                                      Navigator.pop(ctx);
                                                      showToast('삭제에 실패하였습니다!!',
                                                          true);
                                                    }
                                                  } else {
                                                    showToast(
                                                        '인증에 실패하였습니다!', true);
                                                  }
                                                },
                                                child: Text('인증'))
                                          ],
                                        ));
                              },
                              child: Text('예'))
                        ],
                      ));
              break;
            case 'modify':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdatingProductPage(
                            product: product,
                          )));
              break;
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            //핵심.... Stack의 높이는 정해져있지 않아서 Expanded로?..
            child: Stack(
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, progress) =>
                        CircularProgressIndicator(
                      value: progress.progress,
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                          alignment: Alignment.center,
                          color: Colors.grey[400],
                          child: Text('No Image'));
                      //placeholder 추가하기 -> 로고로
                    },
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_formatPrice(price)}원',
                style: TextStyle(
                    color: product.discount.toString() != '0.0'
                        ? Colors.red
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: product.discount.toString() == '0.0'
                        ? TextDecoration.none
                        : TextDecoration.lineThrough),
                textAlign: TextAlign.start,
              ),
              product.discount.toString() != '0.0'
                  ? Text(
                      '  ${_formatPrice((product.price * (1 - (product.discount / 100.0))).round())}원',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text('')
            ],
          ),
          SizedBox(
            height: 6,
          ),
          Text(prodName,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.start)
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
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddingProductPage()));
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        width: size.width * 0.98,
        height: size.height * 0.055,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Text(
          '상품 추가하기 [관리자 모드]',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget addProductForAdmin(Size size) {
    return widget.user.isAdmin ? managerAddingProductLayout(size) : SizedBox();
  }

  Widget _getItemTileOfCurrentCategory(int index, int position) {
    switch (position) {
      case 0:
        return _productLayoutList[index];
      case 1:
        return _foodProductLayoutList[index];
      case 2:
        return _snackProductLayoutList[index];
      case 3:
        return _beverageProductLayoutList[index];
      case 4:
        return _stationeryProductLayoutList[index];
      case 5:
        return _handmadeProductLayoutList[index];
      default:
        return Container(
          child: Text('Error'),
        );
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
