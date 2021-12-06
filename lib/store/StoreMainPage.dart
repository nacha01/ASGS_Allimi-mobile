import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/main/GameListPage.dart';
import 'package:asgshighschool/store/AnnouncePage.dart';
import 'package:asgshighschool/store/CartPage.dart';
import 'package:asgshighschool/store/StoreHomePage.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/QRScannerPage.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/product_data.dart';

class StoreMainPage extends StatefulWidget {
  StoreMainPage({this.user, this.product, this.existCart});
  final User user;
  final List<Product> product;
  final bool existCart;
  @override
  StoreMainPageState createState() => StoreMainPageState();
}

class StoreMainPageState extends State<StoreMainPage> {
  static int currentNav = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
    return Scaffold(
      floatingActionButton: widget.user.isAdmin
          ? FloatingActionButton(
              child: Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QRScannerPage()));
              },
            )
          : null,
      body: SafeArea(child: getWidgetAccordingIndex(currentNav, size)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNav,
        onTap: (index) async {
          setState(() {
            currentNav = index;
          });
          if (index == 0) {
            var selected = await showMenu(
                context: context,
                position: RelativeRect.fromSize(
                    Offset(0, size.height * 0.75) & Size(0, 0), Size(0, 0)),
                items: [
                  PopupMenuItem(
                    child: Text(
                      '알리미',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text('두루두루',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 2,
                  ),
                  PopupMenuItem(
                    child: Text('게임',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 3,
                  )
                ]);
            switch (selected) {
              case 1: // 알리미
                Navigator.pop(context);
                break;
              case 2: // 두루두루
                setState(() {
                  currentNav = 1;
                });
                break;
              case 3: // 게임
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameListPage(
                              user: widget.user,
                            )));
                break;
            }
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.menu,
                color: Colors.green,
              ),
              label: '이동 메뉴'),
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
      case 0: // 메인 홈
        return StoreHomePage(
          user: widget.user,
          product: widget.product,
          existCart: widget.existCart,
        );
      case 1: // 메인 홈
        return StoreHomePage(
          user: widget.user,
          product: widget.product,
          existCart: widget.existCart,
        );
      case 2: // 장바구니
        return CartPage(user: widget.user);
      case 3: // 알림
        return AnnouncePage(
          user: widget.user,
        );
      case 4: // 마이페이지
        return StoreMyPage(
          user: widget.user,
        );
      default: // 없음
        return Center();
    }
  }
}
