import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/CartPage.dart';
import 'package:asgshighschool/store/OrderPage.dart';
import 'package:asgshighschool/store/ReservationPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// 상품의 재고는 실제 재고보다 5개 작게 보여준다. 2021/09/21
/// 위의 기능 철회. 2022/01/02 (online & offline 통합 재고관리 불가능)

class DetailProductPage extends StatefulWidget {
  DetailProductPage({this.product, this.user});

  final Product product;
  final User user;

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
  bool _isDiscountZero = false; // 할인율이 0.0%인지 아닌지 판단
  int _count = 1; // 버튼으로 누른 수량
  bool _isCart = false; // 장바구니에 담았는지 판단
  bool _isClicked = false; // 구매하기 버튼을 눌렀는지 판단
  bool _hasOption = false; // 상품에 옵션이 있는지 판단
  List _optionList = [];
  List<int> _selectedOptionIndex = [];
  String _optionString = '';
  int _additionalPrice = 0;
  String _errorMessage = '';
  bool _corporationInfoClicked = false;

  /// 일반 숫자에 ,를 붙여서 직관적인 가격을 보이게 하는 작업
  /// @param : 직관적인 가격을 보여줄 실제 int 가격[price]
  /// @return : 직관적인 가격 문자열
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

  /// 문자열을 뒤집는 작업
  /// @param : 뒤집고 싶은 문자열[str]
  /// @return : 뒤집은 문자열
  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  void _preProcessForOptions() {
    if (!_hasOption) {
      return;
    }
    for (int j = 0; j < _count; ++j) {
      _optionString += '[{${widget.product.prodName}} 상품 옵션 : ';
      for (int i = 0; i < _optionList.length; ++i) {
        if (_selectedOptionIndex[i] != -1) {
          _additionalPrice += int.parse(
              _optionList[i]['detail'][_selectedOptionIndex[i]]['optionPrice']);
          _optionString += _optionList[i]['optionCategory'] +
              '-' +
              _optionList[i]['detail'][_selectedOptionIndex[i]]['optionName'] +
              ' , ';
        }
      }
      _optionString += ']\n';
    }
  }

  /// 상품을 장바구니에 추가하는 요청을 하는 작업
  /// @response : 성공 시, '1' or 'Already Exists1'
  Future<bool> _addCartProductRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addCart.php';
    final response = await http.post(url, body: <String, String>{
      'uid': widget.user.uid,
      'pid': widget.product.prodID.toString(),
      'quantity': _count.toString(),
      'optionString': _optionString,
      'optionPrice': _additionalPrice.toString()
    });

    if (response.statusCode == 200) {
      var replace = response.body
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (replace != '1' && replace != 'Already Exists1') {
        _errorMessage = replace;
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _getOptionsForProduct() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getProductOptions.php?pid=${widget.product.prodID}';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result == 'NO OPTION') {
        _hasOption = false;
      } else {
        _hasOption = true;

        List map = json.decode(result);

        for (int i = 0; i < map.length; ++i) {
          map[i] = json.decode(map[i]);
          for (int j = 0; j < map[i]['detail'].length; ++j) {
            map[i]['detail'][j] = json.decode(map[i]['detail'][j]);
          }
        }
        _optionList = map;
        for (int i = 0; i < _optionList.length; ++i) {
          _selectedOptionIndex.add(-1);
        }
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  int _optionSummation() {
    int sum = 0;
    for (int i = 0; i < _optionList.length; ++i) {
      if (_selectedOptionIndex[i] != -1) {
        sum += int.parse(
            _optionList[i]['detail'][_selectedOptionIndex[i]]['optionPrice']);
      }
    }
    return sum;
  }

  @override
  void initState() {
    super.initState();
    _isDiscountZero = widget.product.discount.toString() == '0.0';
    _getOptionsForProduct();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var data = Provider.of<ExistCart>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '상품 세부정보',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF9EE1E5),
          leading: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context, true),
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
                        height: size.width * 0.9 * 1.4,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imgUrl1,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, string, progress) =>
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
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text(
                        '${widget.product.prodName}',
                        textScaleFactor: 2.5,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      '[${_categoryReverseMap[widget.product.category]}]',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Container(
                        padding: EdgeInsets.all(size.width * 0.06),
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
                          textScaleFactor: 2,
                          style: TextStyle(height: 1.3),
                        )),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Container(
                      width: size.width * 0.85,
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.production_quantity_limits,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          title: Center(
                            child: Text(
                              '상품 재고 : ${(widget.product.stockCount) < 0 ? 0 : (widget.product.stockCount)}개',
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
                      width: size.width * 0.85,
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
                                  fontWeight: FontWeight.bold,
                                  decoration: _isDiscountZero
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                  color: _isDiscountZero
                                      ? Colors.black
                                      : Colors.red,
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
                            ? null
                            : Center(
                                child: Text(
                                  '${widget.product.discount}% 할인 중',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                      )),
                    ),
                    _hasOption
                        ? Column(
                            children: [
                              Divider(),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.03),
                                child: Row(
                                  children: [
                                    Text(
                                      '상품 옵션',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children:
                                    _optionCategoryList(_optionList, size),
                              ),
                              Divider(),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    (widget.product.stockCount) <= 0
                        ? Container(
                            child: Text(
                              '재고가 없습니다.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: size.width * 0.15,
                                  height: size.height * 0.06,
                                  child: IconButton(
                                    onPressed: () {
                                      if (_count > 1) {
                                        setState(() {
                                          --_count;
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.remove),
                                  ),
                                ),
                                Container(
                                  width: size.width * 0.16,
                                  height: size.height * 0.06,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_count',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  width: size.width * 0.15,
                                  height: size.height * 0.06,
                                  child: IconButton(
                                    onPressed: () {
                                      if (_count < widget.product.stockCount) {
                                        setState(() {
                                          ++_count;
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: '더 추가할 수 없습니다!',
                                            gravity: ToastGravity.BOTTOM,
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Divider(
                      thickness: 1,
                      endIndent: 15,
                      indent: 15,
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Card(
                        child: Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      child: Text(
                        '※ 개당 총 가격 ${_formatPrice(((widget.product.price * (1 - (widget.product.discount / 100.0))) + _optionSummation()).round())}원',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    )),
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
                              progressIndicatorBuilder: (context, string,
                                      progress) =>
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
                              progressIndicatorBuilder: (context, string,
                                      progress) =>
                                  Center(child: CircularProgressIndicator()),
                            )),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    _corpInfoLayout(size)
                  ],
                ),
              ),
            ),
            _isClicked
                ? Container(
                    height: size.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (_count < 1 || widget.product.stockCount < 1) {
                              Fluttertoast.showToast(
                                  msg: '상품의 재고가 없어 장바구니에 담을 수 없습니다!',
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT);
                              return;
                            }
                            if (!_isCart) {
                              _preProcessForOptions();
                              var result = await _addCartProductRequest();
                              print(result);
                              if (result) {
                                data.setExistCart(true);
                                Fluttertoast.showToast(
                                    msg: '장바구니에 추가되었습니다.',
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_SHORT);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('장바구니 추가 문제 발생'),
                                          content: Text(
                                              '장바구니에 상품을 추가하는데 문제가 발생했습니다!\n${_errorMessage.trim() == 'EXCESS' ? '→현재 장바구니에 존재하는 이 상품의 수량과 현재 지정한 수량의 합이 상품 재고를 초과했습니다.' : _errorMessage} '),
                                          actions: [
                                            FlatButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('확인'))
                                          ],
                                        ));
                              }
                              setState(() {
                                _isCart = true;
                              });
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CartPage(
                                            user: widget.user,
                                            isFromDetail: true,
                                          )));
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: Color(0xFF9EE1E5),
                            alignment: Alignment.center,
                            width: size.width * 0.48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 33,
                                ),
                                Text(_isCart ? '장바구니로 이동' : '장바구니 담기',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isCart
                                            ? Colors.indigo
                                            : Colors.black))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_count < 1 || widget.product.stockCount < 1) {
                              Fluttertoast.showToast(
                                  msg: '상품의 재고가 없어 결제할 수가 없습니다!',
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT);
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderPage(
                                          user: widget.user,
                                          direct: widget.product,
                                          productCount: _count,
                                          cart: null,
                                          optionList: _optionList,
                                          selectList: _selectedOptionIndex,
                                          additionalPrice: _optionSummation(),
                                        )));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.cyan[700],
                            alignment: Alignment.center,
                            width: size.width * 0.52,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.payment_rounded,
                                    color: Colors.grey[300], size: 33),
                                Text(
                                  '${_formatPrice((((widget.product.price * (1 - (widget.product.discount / 100.0)) + _optionSummation()) * _count)).round())}원 결제하기',
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
                : FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: widget.product.stockCount < 1 &&
                            !widget.product.isReservation
                        ? null
                        : () {
                            if (widget.product.stockCount < 1) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                          '재고 없음',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                            '현재 상품의 재고가 없어 예약만 가능합니다. 예약하러 가시겠습니까?'),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReservationPage(
                                                              user: widget.user,
                                                              product: widget
                                                                  .product,
                                                              optionList:
                                                                  _hasOption
                                                                      ? _optionList
                                                                      : [],
                                                              selectList: _hasOption
                                                                  ? _selectedOptionIndex
                                                                  : [],
                                                            )));
                                              },
                                              child: Text(
                                                '예',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                              )),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                '아니오',
                                                style: TextStyle(
                                                    color: Colors.deepOrange),
                                              ))
                                        ],
                                      ));
                              return;
                            } else {
                              setState(() {
                                _isClicked = !_isClicked;
                              });
                            }
                          },
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width * 0.98,
                      padding: EdgeInsets.all(size.width * 0.025),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: widget.product.stockCount < 1
                              ? !widget.product.isReservation
                                  ? Colors.grey
                                  : Colors.deepOrange
                              : Colors.blueAccent),
                      child: Text(
                        widget.product.stockCount < 1
                            ? !widget.product.isReservation
                                ? '품절'
                                : '예약하러 가기'
                            : '구매하기',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  List<Widget> _optionCategoryList(List entire, Size size) {
    List<Widget> tmp = [];
    for (int i = 0; i < entire.length; ++i) {
      tmp.add(_optionItemTile(entire[i], size, i));
      tmp.add(SizedBox(
        height: size.height * 0.03,
      ));
    }
    return tmp;
  }

  Widget _optionItemTile(Map data, Size size, int index) {
    return Container(
      width: size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.topCenter,
            width: size.width * 0.35,
            child: Text(
              '| ${data['optionCategory']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _optionSelectList(data['detail'], size, index),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _optionSelectList(List data, Size size, int cIndex) {
    List<Widget> temp = [];
    for (int i = 0; i < data.length; ++i) {
      temp.add(_optionDetailSelectLayout(data[i], size, cIndex, i));
    }
    return temp;
  }

  Widget _optionDetailSelectLayout(
      Map data, Size size, int cIndex, int dIndex) {
    return FlatButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        setState(() {
          if (_selectedOptionIndex[cIndex] != dIndex) {
            _selectedOptionIndex[cIndex] = dIndex;
          } else {
            _selectedOptionIndex[cIndex] = -1;
          }
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _selectedOptionIndex[cIndex] == dIndex
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: Colors.blueAccent,
          ),
          SizedBox(
            width: size.width * 0.02,
          ),
          Expanded(
              child: Text(
            '${data['optionName']}',
            style: TextStyle(fontSize: 13),
          )),
          Text('+${_formatPrice(int.parse(data['optionPrice']))}원')
        ],
      ),
    );
  }

  Widget _corpInfoLayout(Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(
          _corporationInfoClicked ? size.width * 0.02 : size.width * 0.01),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _corporationInfoClicked = !_corporationInfoClicked;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: size.width * 0.04,
                ),
                Text(
                  '회사 정보',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                Icon(_corporationInfoClicked
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down)
              ],
            ),
          ),
          _corporationInfoClicked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.005,
                    ),
                    Text(
                      '사업자 번호: 135-82-17822',
                      style: TextStyle(color: Colors.grey, fontSize: 9),
                    ),
                    Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표자: 김은미',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표 전화: 031-485-9742',
                        style: TextStyle(color: Colors.grey, fontSize: 9)),
                    Text('대표 이메일: asgscoop@naver.com',
                        style: TextStyle(color: Colors.grey, fontSize: 9))
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
