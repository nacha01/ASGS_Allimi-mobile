import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/AddProduct.dart';
import 'package:flutter/material.dart';

import '../data/product_data.dart';

class StoreMainPage extends StatefulWidget {
  StoreMainPage({this.user, this.product});
  final user;
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
  List<Widget> productLayoutList = [];
  @override
  void initState() {
    super.initState();
    print((widget.user as User).nickName);
    _tabController = TabController(length: 4, vsync: this);
    _scrollViewController = ScrollController();

    for (int i = 0; i < widget.product.length; ++i) {
      var tmp = widget.product[i];
      productLayoutList
          .add(itemTile(tmp.imgUrl1, tmp.price, tmp.prodName, false));
    }
  }

  List<Widget> bottomTapWidgets = [];
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: getWidgetAccordingIndex(_currentNav, size),
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
                floating: true,
                pinned: true,
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
            productLayoutList.length == 0
                ? Center(
                    child: Text(
                    '상품이 없습니다.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ))
                : GridView.count(
                    padding: EdgeInsets.all(10),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 15,
                    crossAxisCount: 2,
                    children: productLayoutList),
            Column(
              children: [
                FlatButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddingProductPage())),
                    child: Text('ADD'))
              ],
            ),
            Container(
              color: Colors.blue,
            ),
            Container(
              color: Colors.green,
            ),
          ]),
        );
      case 1: // 알림
        return Center();
      case 2: // 장바구니
        return Center();
      case 3: // 마이페이지
        return StoreMyPage(user: widget.user,);
      default: // 없음
        return Center();
    }
  }

  Widget itemTile(String imgUrl, int price, String prodName, bool isWish) {
    return GestureDetector(
      onTap: () {
        print('클릭함');
      },
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
}
