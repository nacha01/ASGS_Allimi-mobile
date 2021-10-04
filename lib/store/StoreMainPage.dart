import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/AnnouncePage.dart';
import 'package:asgshighschool/store/CartPage.dart';
import 'package:asgshighschool/store/StoreHomePage.dart';
import 'package:asgshighschool/store/StoreMyPage.dart';
import 'package:asgshighschool/storeAdmin/QRScannerPage.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        onTap: (index) {
          setState(() {
            currentNav = index;
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
      case 0: // 메인 홈
        return StoreHomePage(
          user: widget.user,
          product: widget.product,
          existCart: widget.existCart,
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
}
