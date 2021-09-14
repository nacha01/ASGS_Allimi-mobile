import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
class PaymentCompletePage extends StatefulWidget {
  PaymentCompletePage({this.result});
  final Map result;
  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {

  Future<bool> _getOrderInfo() async{
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_searchOrderInfo.php?oid=${widget.result['orderID']}';
    final response = await http.get(url);

    if(response.statusCode == 200){
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
          '')
          .trim();
      print(result);
      print(jsonDecode(jsonDecode(json.decode(result)[0])['product'])['pid']);
      return true;
    }
    else{
      return false;
    }
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
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
          QrImage(
            data: widget.result['orderID'],
            size: 190,
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
            height: size.height * 0.02,
          ),
          Text(
            'QR 코드나 주문 번호는 본인이 주문을 했다는 것을 인증할 수 있는 수단으로써 상품을 수령하기 위해서는 반드시 필요한 것입니다.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
