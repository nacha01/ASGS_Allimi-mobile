import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentCompletePage extends StatefulWidget {
  PaymentCompletePage({this.result, this.totalPrice});
  final Map result;
  final int totalPrice;
  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  List _orderInfo = [];

  /// route 이동 시 넘겨 받은 주문 ID를 통한 주문 상세 정보 요청 작업
  Future<bool> _getOrderInfo() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_searchOrderInfo.php?oid=${widget.result['orderID']}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();

      List map = json.decode(result);

      for (int i = 0; i < map.length; ++i) {
        map[i] = jsonDecode(map[i]);
        map[i]['product'] = jsonDecode(map[i]['product']);
      }
      setState(() {
        _orderInfo = map;
      });
      return true;
    } else {
      return false;
    }
  }

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

  @override
  void initState() {
    super.initState();
    _getOrderInfo();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '주문 완료',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.04,
            ),
            Text(
              '주문이 성공적으로 완료되었습니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Divider(
              thickness: 0.5,
              indent: 3,
              endIndent: 3,
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              '주문번호 ${widget.result['orderID']}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.lightBlue),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Column(
              children: _getProductList(size),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text(
              '주문 현황 및 상세 정보는 ',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Text(
              '마이페이지 → 주문 현황',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Text(' 에서도 확인할 수 있습니다.', style: TextStyle(fontSize: 12)),
            SizedBox(
              height: size.height * 0.03,
            ),
            Divider(
              thickness: 0.5,
              indent: 3,
              endIndent: 3,
            ),
            Text(
              '주문 인증용 QR 코드',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: Text(
                '<카카오뱅크 79794096110, 예금주 이경희>\n 로 [${_formatPrice(widget.totalPrice)}원] 송금 바랍니다.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            // QrImage(
            //   data: widget.result['orderID'],
            //   size: 190,
            // ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Divider(
              thickness: 0.5,
              indent: 3,
              endIndent: 3,
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text(
              'QR 코드나 주문 번호는 본인이 주문을 했다는 것을 인증할 수 있는 수단으로써 상품을 수령하기 위해서는 반드시 필요한 것입니다.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productLayout(String name, int quantity, int category, Size size) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.06,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.black),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(
            '[${_categoryReverseMap[category]}]',
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            ' $name $quantity개 ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _getProductList(Size size) {
    List<Widget> list = [];
    for (int i = 0; i < _orderInfo.length; ++i) {
      list.add(_productLayout(
          _orderInfo[i]['product']['pName'],
          int.parse(_orderInfo[i]['quantity']),
          int.parse(_orderInfo[i]['product']['category']),
          size));
    }
    return list;
  }
}
