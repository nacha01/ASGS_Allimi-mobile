import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/AddProduct.dart';
import 'package:asgshighschool/storeAdmin/DeleteProduct.dart';
import 'package:asgshighschool/storeAdmin/UpdateProduct.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  List<Widget> _newProductLayoutList = [];
  List<Widget> _bestProductLayoutList = [];
  List<Product> _productList = [];
  List<Product> _newProductList = [];
  List<Product> _bestProductList = [];

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
    }
    getBestProdLayout();
    getNewProdLayout();
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

  Future<List<Product>> _getProducts() async {
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

      for (int i = 0; i < _productList.length; ++i) {
        var tmp = _productList[i];
        _productLayoutList
            .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false, tmp));
      }
      setState(() {
        _groupingProduct();
      });

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
                          SizedBox(
                            height: size.width * 0.02,
                          ),
                          Center(
                              child: Text(
                            '베스트 상품이 없습니다.',
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
                          SizedBox(
                            height: size.width * 0.02,
                          ),
                          Center(
                              child: Text(
                            '신규 상품이 없습니다.',
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
                color: Colors.blue,
              ),
              /*------------ EVENT TAB ---------------*/
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
                              child: GridView.builder(
                                  itemCount: _productLayoutList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 1),
                                  itemBuilder: (context, index) {
                                    return _productLayoutList[index];
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

  Widget itemTile(
      String imgUrl, int price, String prodName, bool isWish, Product product) {
    return GestureDetector(
      onTap: () {
        print('클릭함');
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeletingProductPage()));
              break;
            case 'modify':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdatingProductPage()));
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
                    errorWidget: (context, url, error) {
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
          SizedBox(
            height: 10,
          ),
          Text(
            '$price원',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
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
}
