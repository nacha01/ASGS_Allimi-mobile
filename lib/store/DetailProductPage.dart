import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailProductPage extends StatefulWidget {
  DetailProductPage({this.product});
  final Product product;
  @override
  _DetailProductPageState createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  bool _isDiscountZero;
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

  @override
  void initState() {
    super.initState();
    _isDiscountZero = widget.product.discount.toString() == '0.0';
    print(widget.product.imgUrl2 == null ? '이미지 2는 null' : '2 존재');
    print(widget.product.imgUrl3 == null ? '이미지 3은 null' : '3 존재');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                      width: size.width * 0.9,
                      height: size.height * 0.45,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imgUrl1,
                        fit: BoxFit.fill,
                        progressIndicatorBuilder: (context, string, progress) =>
                            Center(child: CircularProgressIndicator()),
                      )),
                  Divider(
                    thickness: 1,
                    endIndent: 15,
                    indent: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.product.isBest == 1
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              width: size.width * 0.16,
                              height: size.height * 0.08,
                              child: CircleAvatar(
                                backgroundColor: Colors.greenAccent,
                                child: Text(
                                  'BEST MENU',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : SizedBox(),
                      widget.product.isNew == 1
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              width: size.width * 0.16,
                              height: size.height * 0.08,
                              child: CircleAvatar(
                                backgroundColor: Colors.limeAccent,
                                child: Text('NEW MENU',
                                    textAlign: TextAlign.center),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  widget.product.isBest == 1 || widget.product.isNew == 1
                      ? Divider(
                          thickness: 1,
                          endIndent: 15,
                          indent: 15,
                        )
                      : SizedBox(),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Text(
                    '${widget.product.prodName}',
                    textScaleFactor: 3,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '[${_categoryReverseMap[widget.product.category]}]',
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black54),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 6))
                          ]),
                      child: Text(
                        '${widget.product.prodInfo}',
                        textScaleFactor: 2.5,
                        style: TextStyle(),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.storage,
                          size: 40,
                          color: Colors.brown,
                        ),
                        title: Center(
                          child: Text(
                            '상품 재고 : ${widget.product.stockCount}개',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    width: size.width * 0.8,
                    child: Card(
                        child: ListTile(
                      leading: Icon(
                        Icons.attach_money,
                        size: 40,
                        color: Colors.green,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_formatPrice(widget.product.price)}원',
                            style: TextStyle(
                                decoration: _isDiscountZero
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                                color:
                                    _isDiscountZero ? Colors.black : Colors.red,
                                fontSize: 19),
                          ),
                          _isDiscountZero
                              ? Text('')
                              : Text(
                                  ' → ${_formatPrice((widget.product.price * (1 - (widget.product.discount / 100.0))).round())}원',
                                  style: TextStyle(fontSize: 19),
                                )
                        ],
                      ),
                      subtitle: _isDiscountZero
                          ? SizedBox()
                          : Text(
                              '${widget.product.discount}% 할인 중',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    )),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  widget.product.imgUrl2 == null
                      ? SizedBox()
                      : Container(
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imgUrl2,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder:
                                (context, string, progress) =>
                                    Center(child: CircularProgressIndicator()),
                          )),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  widget.product.imgUrl3 == null
                      ? SizedBox()
                      : Container(
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imgUrl3,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder:
                                (context, string, progress) =>
                                    Center(child: CircularProgressIndicator()),
                          )),
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    print('장바구니 이동');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Color(0xFF9EE1E5),
                    alignment: Alignment.center,
                    width: size.width * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.shopping_cart),
                        Text('장바구니 담기',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('예약 이동');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    color: Colors.cyan,
                    width: size.width * 0.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.assignment_turned_in,
                            color: Colors.grey[600]),
                        Text('예약하기',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600]))
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('결제 이동');
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.cyan[700],
                    alignment: Alignment.center,
                    width: size.width * 0.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.payment_rounded, color: Colors.grey[300]),
                        Text(
                          '결제하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300]),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
