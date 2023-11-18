import 'package:flutter/material.dart';

import '../../api/ApiUtil.dart';
import '../../component/CorporationComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../data/category.dart';
import '../../data/product.dart';
import '../../data/user.dart';
import '../../util/NumberFormatter.dart';
import '../../util/OrderUtil.dart';
import 'package:http/http.dart' as http;

class PayPointCompletePage extends StatefulWidget {
  PayPointCompletePage(
      {this.totalPrice,
      this.responseData,
      this.direct,
      this.cart,
      this.productCount,
      this.user,
      this.optionList,
      this.selectList,
      this.isCart,
      this.location,
      this.option,
      this.receiveMethod});

  final int? totalPrice;
  final Map? responseData;
  final bool? isCart;
  final Product? direct; // 바로 결제 시 그 단일 상품 하나
  final List<Map?>? cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final int? productCount; // 바로 결제시 상품의 개수
  final User? user;
  final List? optionList;
  final List? selectList;
  final String? receiveMethod;
  final String? option;
  final String? location;

  @override
  _PayPointCompletePageState createState() => _PayPointCompletePageState();
}

class _PayPointCompletePageState extends State<PayPointCompletePage> {
  bool _isFinished = false;
  bool _isCreditSuccess = true;
  String? _resultMessage = '';
  String? _resultCode = '';
  String _generatedOID = '';


  @override
  void initState() {
    _isCreditSuccess =
    widget.responseData!['ResultCode'] == '3001' ? true : false;
    _resultMessage = widget.responseData!['ResultMsg'];
    _resultCode = widget.responseData!['ResultCode'];
    super.initState();
    _generatedOID = DateTime.now().millisecondsSinceEpoch.toString();
    _processAfterPaying();
  }

  void _processAfterPaying() async {
    if (_isCreditSuccess) {
      var res = await _registerOrderRequest();
      if (!res) {
        _resultCode = 'O001'; // 커스텀 코드로 결제는 되었으나 DB에 주문 등록이 실패했다는 의미
      }
    }
    setState(() {
      _isFinished = true;
    });
  }

  /// 최종적으로 주문을 등록하는 과정
  Future<bool> _registerOrderRequest() async {
    var orderManager = OrderUtil();
    var orderRes = await _addOrderRequest();

    if (!orderRes) return false;

      var detRes = await _addOrderDetailRequest(
          widget.direct!.prodID, widget.productCount);
      var renewCountRes = await orderManager.updateProductCountRequest(
          widget.direct!.prodID, widget.productCount!, '-');

      var sellCountRes = await orderManager.updateEachProductSellCountRequest(
          widget.direct!.prodID, widget.productCount, '+');

      var buyerCountRes =
      await orderManager.updateUserBuyCountRequest(widget.user!.uid!, '+');

      if (!detRes) return false;
      if (!renewCountRes) return false;
      if (!sellCountRes) return false;
      if (!buyerCountRes) return false;

    return true;
  }
  /// orderDetail 테이블에 oid인 값에 대하여 어떤 상품인지 등록하는 http 요청
  Future<bool> _addOrderDetailRequest(int pid, int? quantity) async {
    String url = '${ApiUtil.API_HOST}arlimi_addOrderDetail.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'oid': _generatedOID,
      'pid': pid.toString(),
      'quantity': quantity.toString()
    });
    if (response.statusCode == 200) {
      print("_addOrderDetailRequest연결되었다");
      return true;
    } else {
      print("_addOrderDetailRequest연결안됨");
      return false;
    }
  }
  /// 주문을 등록하는 요청
  Future<bool> _addOrderRequest() async {
    String url = '${ApiUtil.API_HOST}arlimi_addOrder.php';

    final response = await http.post(Uri.parse(url), body: <String, String>{
      'oid': _generatedOID,
      'uid': widget.user!.uid!,
      'oDate': DateTime.now().toString(),
      'price': (widget.totalPrice ?? 0).toString(),
      'oState': '', // '결제완료' 상태
      'recvMethod': '',
      'option': '',
      'pay': '0', // 신용카드
      'location': widget.location!,
      'TID': 'point'
    });
    print(response.body);

    if (response.statusCode == 200) {
      print("_addOrderRequest연결되었다");
      return true;
    } else {
      print("_addOrderRequest연결안됨");
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(
            barTitle: '결제 결과 페이지',
            leadingClick: () => Navigator.pop(context, true)),
        body: _isFinished
            ? Column(
          children: [
            Expanded(
                child: _layoutAccordingToResultCode('3001' as String?, size)),
            CorporationInfo(isOpenable: true)
          ],
        )
            : Container(
                height: size.height,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '주문 등록 중입니다..',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
      ),
    );
  }

  Widget _layoutAccordingToResultCode(String? resultCode, Size size) {
    switch (resultCode) {
      case '3001': // 카드 결제 성공
        return SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                Icons.check,
                color: Colors.lightGreenAccent,
                size: 85,
              ),
              Text(
                '결제가 성공적으로 완료되었습니다!',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
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
                height: size.height * 0.01,
              ),
              Text(
                '주문번호 point 결재}',
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
                height: size.height * 0.01,
              ),
              widget.option!.isNotEmpty //여기는 뭐지? ???
                  ? Container(
                      width: size.width * 0.8,
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Text(
                            '요청 사항 및 상품 옵션',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.black54),
                          ),
                          Text(
                            widget.option!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: size.height * 0.01,
              ),
              Card(
                child: Container(
                  alignment: Alignment.center,
                  width: size.width * 0.6,
                  padding: EdgeInsets.all(size.width * 0.02),
                  child: Text(
                    '결제 금액  ${NumberFormatter.formatPrice(widget.totalPrice ?? 0) }원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
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
                '마이페이지 → 내 주문 현황',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(' 에서도 확인할 수 있습니다.', style: TextStyle(fontSize: 12)),
              SizedBox(
                height: size.height * 0.02,
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
              Text(
                'QR 코드는 "내 주문 현황"에서 확인 가능합니다.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blueGrey),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Text(
                '* QR 코드나 주문 번호는 본인이 주문을 했다는 것을 인증할 수 있는 수단으로써 상품을 수령하기 위해서는 반드시 필요한 것입니다.',
                style: TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Divider(
                thickness: 2,
                indent: 3,
                endIndent: 3,
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
            ],
          ),
        );

      default: // 이외에 결제 실패 오류
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
                size: 85,
              ),
              Text(
                '결제에 실패했습니다!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 20),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                ' | 실패 사유 뭐지?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Text(
                  '* 결제를 다시 시도하거나 실패 사유에 대한 문제를 해결하고 시도해주세요.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.grey),
                ),
              ),
              SizedBox(
                height: size.height * 0.08,
              )
            ],
          ),
        );
    }
  }

  List<Widget> _getProductList(Size size) {
    List<Widget> list = [];

    list.add(_productLayout(widget.direct!.prodName, widget.productCount,
        widget.direct!.category, size));

    return list;
  }

  Widget _productLayout(String? name, int? quantity, int category, Size size) {
    return Container(
      width: size.width * 0.8,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * 0.02),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: size.width * 0.01,
          children: [
            Text(
              '[${Categories.categories[category].name}]',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              ' $name $quantity개 ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
