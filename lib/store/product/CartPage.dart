import 'dart:convert';

import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/CorporationComp.dart';
import 'package:asgshighschool/data/category.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../data/provider/exist_cart.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/order/OrderPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../util/NumberFormatter.dart';

/// 장바구니 Item Field
/// 1. cID[hidden]
/// 2. cUID[hidden]
/// 3. cPID[hidden]
/// 4. quantity[visible]
/// 5. prodName[visible]
/// 6. category[visible]
/// 7. price[visible]
/// 8. stockCount[visible]
/// 9. discount[visible]
/// 10. imgUrl1[visible] 고민중..
class CartPage extends StatefulWidget {
  CartPage({this.user, this.isFromDetail = false});

  final User? user;
  final bool isFromDetail;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map?> _cartProductList = []; // 원본 장바구니 데이터
  List<int> _countList = [];
  bool _isLoading = true;
  int _allAdditionalPrice = 0;

  /// 특정 유저에 대해 그 유저가 갖고 있는 장바구니 상품들을 가져오는 HTTP 요청
  /// @return : 요청 성공 여부
  Future<bool> _getCartForUserRequest() async {
    String url = '${ApiUtil.API_HOST}arlimi_getAllCart.php';
    final response =
        await http.get(Uri.parse(url + '?uid=${widget.user!.uid}'));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      List cartProduct = json.decode(result);
      _cartProductList.clear();
      for (int i = 0; i < cartProduct.length; ++i) {
        _cartProductList.add(json.decode(cartProduct[i]));
      }
      _initCartCount();
      _sumAllOptionPrice();
      setState(() {
        _isLoading = false;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 장바구니에서 특정 상품을 삭제하는 HTTP 요청
  /// @param : 장바구니 고유 ID[cid]
  /// @response message : DELETED : 삭제 완료, NOT : 삭제 실패
  /// @return : 요청 성공 여부
  Future<bool> _deleteCartForUserRequest(int cid) async {
    String url = '${ApiUtil.API_HOST}arlimi_deleteCart.php';
    final response = await http.get(Uri.parse(url + '?cid=$cid'));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result == 'DELETED') {
        return true;
      }
    }
    return false;
  }

  /// 그 장바구니 상품에 대해 수량 업데이트 HTTP 요청을 보내는 작업
  /// @param : 장바구니 고유 ID[cid], 현재 장바구니 수량[currentQuantity]
  /// @return : 요청 성공 여부
  Future<bool> _updateCartQuantity(int cid, int currentQuantity) async {
    String url = '${ApiUtil.API_HOST}arlimi_updateCartCount.php';
    final response =
        await http.get(Uri.parse(url + '?cid=$cid&quantity=$currentQuantity'));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 특정 상품에 대해 할인율과 개수를 적용해 그 상품의 총 가격을 구하는 작업
  /// @param : 가격[price], 할인율[discount], 수량[count]
  /// @return : 상품의 총 가격
  int _calculateTotalEachPrice(int price, double discount, int count) {
    if (discount.toString() == '0.0') {
      return price * count;
    } else {
      return ((price * (1 - (discount / 100))) * count).round();
    }
  }

  /// 장바구니에 존재하는 모든 상품의 최종 가격을 구하는 작업
  /// @return : 장바구니에 담긴 총 가격
  int _totalPrice() {
    int sum = 0;
    for (int i = 0; i < _cartProductList.length; ++i) {
      sum += _calculateTotalEachPrice(int.parse(_cartProductList[i]!['price']),
          double.parse(_cartProductList[i]!['discount']), _countList[i]);
    }
    return sum;
  }

  /// 화면이 사라질 때, 즉, 장바구니 페이지가 종료되는 시점에 수량에 대한 변경 사항을
  /// DB에 업데이트하는 작업
  void _renewCartCount() async {
    for (int i = 0; i < _cartProductList.length; ++i) {
      if (int.parse(_cartProductList[i]!['quantity']) != _countList[i]) {
        await _updateCartQuantity(
            int.parse(_cartProductList[i]!['cID']), _countList[i]);
      }
    }
  }

  /// 장바구니 페이지 시작 시 DB에서 가져온 정보중에서 수량에 대한 정보를
  /// mutable한 객체에 복사해서 저장하는 작업
  void _initCartCount() {
    for (int i = 0; i < _cartProductList.length; ++i) {
      _countList.add(int.parse(_cartProductList[i]!['quantity']));
    }
  }

  void _sumAllOptionPrice() {
    _allAdditionalPrice = 0;
    for (int i = 0; i < _cartProductList.length; ++i) {
      _allAdditionalPrice += int.parse(_cartProductList[i]!['optionPrice']);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCartForUserRequest();
  }

  @override
  void dispose() {
    _renewCartCount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<ExistCart>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '장바구니', allowLeading: widget.isFromDetail),
      body: _cartProductList.length == 0
          ? _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('불러오는 중...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          '장바구니에 상품이 없습니다!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    CorporationInfo(isOpenable: true)
                  ],
                )
          : Column(
              children: [
                Container(
                  width: size.width,
                  child: Column(
                    children: [
                      //brief 설명 적는 곳
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.015),
                        child: Text(
                          '* 상품 옵션이 존재하는 상품의 경우 장바구니 페이지에서 수량 증가 시 어떤 옵션도 선택되지 않은 정가의 순수 상품이 추가 됩니다. \n* 서로 다른 옵션을 사용하고 싶으신 경우 상품 정보에서 옵션을 선택 후 "장바구니 담기"를 선택해주세요.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 9),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Expanded(
                  child: ListView.builder(
                      itemBuilder: (context, index) {
                        return _cartItemTile(
                            _cartProductList[index]!, size, data, index);
                      },
                      itemCount: _cartProductList.length),
                ),
                CorporationInfo(isOpenable: true),
                DefaultButtonComp(
                  onPressed: () async {
                    _renewCartCount();
                    await _getCartForUserRequest();
                    final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderPage(
                                  cart: _cartProductList,
                                  user: widget.user,
                                  optionList: [],
                                  selectList: [],
                                  additionalPrice: _allAdditionalPrice,
                                  productCount: 0,
                                )));
                    setState(() {
                      _getCartForUserRequest();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.01),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Color(0xFF9EE1E5)),
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: size.height * 0.04 * 0.8,
                          child: CircleAvatar(
                            child: Text(
                              '${_cartProductList.length}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Text(
                          '${NumberFormatter.formatNumber(_totalPrice() + _allAdditionalPrice)}원  결제하기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 13),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  /// 장바구니 각 아이템에 대한 Layout
  Widget _cartItemTile(
      Map cartItem, Size size, ExistCart existCart, int index) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
      width: size.width,
      height: size.height * 0.2,
      padding: EdgeInsets.all(size.width * 0.02),
      margin: EdgeInsets.all(size.width * 0.005),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: size.width * 0.23 * 1.4,
            width: size.width * 0.23,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: cartItem['imgUrl1'],
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, string, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * 0.012,
          ),
          Container(
            width: size.width * 0.45,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(children: [
                    Text(
                      cartItem['prodName'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '  [${Category.categoryIndexToStringMap[int.parse(cartItem['category'])]}]',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  ]),
                ),
                Text(
                  '· 정가 : ${NumberFormatter.formatNumber(int.parse(cartItem['price']))}원',
                  style: TextStyle(fontSize: 13),
                ),
                double.parse(cartItem['discount']).toString() != '0.0'
                    ? Text(
                        '[ ${double.parse(cartItem['discount'])}% 할인 ]',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      )
                    : SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * 0.115,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400]!)),
                      child: IconButton(
                        onPressed: () async {
                          if (cartItem['options'] == null ||
                              cartItem['options'] == '') {
                            if (_countList[index] > 1) {
                              setState(() {
                                _countList[index]--;
                              });
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('장바구니 수량 줄이기 실패'),
                                      content: Text(
                                        '현재 서로 다른 상품 옵션을 갖는 상품이 존재합니다. 수량을 줄이려면 장바구니를 삭제하고 다시 추가해주세요.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      actions: [
                                        DefaultButtonComp(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('확인'))
                                      ],
                                    ));
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                    ),
                    Container(
                      width: size.width * 0.12,
                      height: size.height * 0.05,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400]!)),
                      child: Text(
                        '${_countList[index]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: size.width * 0.11,
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.black38,
                          border:
                              Border.all(width: 1, color: Colors.grey[400]!)),
                      child: IconButton(
                        onPressed: () async {
                          if (_countList[index] <
                              int.parse(
                                  _cartProductList[index]!['stockCount'])) {
                            setState(() {
                              _countList[index]++;
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: '현재 상품의 재고를 초과할 수 없습니다!',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              // width: size.width * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () async {
                          var result = await _deleteCartForUserRequest(
                              int.parse(cartItem['cID']));
                          if (result) {
                            var res = await _getCartForUserRequest();
                            if (_cartProductList.length == 0) {
                              existCart.setExistCart(false);
                            }
                            Fluttertoast.showToast(
                                msg: '장바구니에서 상품을 삭제하였습니다.',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                          } else {
                            Fluttertoast.showToast(
                                msg: '장바구니에서 상품을 삭제하는데 실패했습니다!!',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(size.width * 0.01),
                      margin: EdgeInsets.only(bottom: size.width * 0.008),
                      child: Text(
                        '${NumberFormatter.formatNumber(_calculateTotalEachPrice(int.parse(cartItem['price']), double.parse(cartItem['discount']), _countList[index]) + int.parse(cartItem['optionPrice']))}원',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
