import 'dart:async';
import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/order/order.dart';
import 'package:asgshighschool/data/payment_cancel.dart';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:asgshighschool/util/OrderUtil.dart';
import 'package:asgshighschool/util/PaymentUtil.dart';
import 'package:asgshighschool/util/ToastMessage.dart';
import 'package:asgshighschool/util/UpperCaseTextFormatter.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import 'AdminDetailOrder.dart';
import 'package:asgshighschool/storeAdmin/statistics/FullListPage.dart';
import '../qr/QrSearchScanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class OrderListPage extends StatefulWidget {
  OrderListPage({this.user});

  final User? user;

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Order> _allOrderList = [];
  List<Order> _orderList = [];

  // Map<bool, List<Order>> orderMap = Map(); // true: 필터링 리스트, false: 전체 주문 리스트
  bool _isChecked = true;
  bool _isFinished = false;
  final TextEditingController _adminKeyController = TextEditingController();
  PaymentCancelResponse? _cancelResponse;
  final FlutterTts _tts = FlutterTts();
  final ScrollController _orderScrollController = ScrollController();
  final ScrollController _allScrollController = ScrollController();
  late final Timer _timer;
  static const int LIMIT_SIZE = 8;

  String _topOrderID = '';
  int _listLength = 0;
  bool _isOverflow = false;

  /// 모든 주문 내역을 요청하는 작업
  /// 이미 주문 처리가 된 것과 안된 것을 구분하여 각각의 List 에 저장
  Future<bool> _getAllOrderData(
      int cursor, bool realtimeMode, bool useOption) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getAllOrder_paging.php?cursor=$cursor&size=$LIMIT_SIZE';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      var list = OrderUtil.serializeOrderList(result, true);

      if (_isFinished && list.length == 0) {
        _isOverflow = true;
      } else {
        _isOverflow = false;
      }

      if (useOption) {
        if (realtimeMode) {
          if (_topOrderID != '') {
            // _orderList.clear();
            for (int i = 0; i < list.length; ++i) {
              _orderList[i] = list[i];
            }
            // setState(() {
            //   _orderList = _orderList.toSet().toList();
            List<Order> tmp = [];
            _orderList.forEach((element) {
              int count = 0;
              for(int i=0; i< _orderList.length; ++i){
                if(element.orderID == _orderList[i].orderID){
                  count++;
                  // return;
                }
              }
              if(count == 1)
              tmp.add(element);

            });
            _orderList = tmp;
            // });
            if (list[0].orderID.compareTo(_topOrderID) > 0) {
              await _orderScrollController.animateTo(0,
                  curve: Curves.linear, duration: Duration(milliseconds: 500));
              // _orderList = list;
            }
          }
        } else
          _orderList.addAll(list);
      } else {
        if (realtimeMode)
          _allOrderList = list;
        else
          _allOrderList.addAll(list);
      }

      if (!_isFinished && useOption) _topOrderID = _orderList[0].orderID;
      setState(() {
        _isFinished = true;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 특정 uid 값을 통해 그 관리자의 사용자 정보를 가져오는 요청
  Future<Map?> _getAdminUserInfoByID(String uid) async {
    String url = '${ApiUtil.API_HOST}arlimi_getUserInfo.php?uid=' + uid;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      return jsonDecode(result);
    } else {
      return null;
    }
  }

  Future<void> _setTTS() async {
    await _tts.setLanguage('kr');
    await _tts.setSpeechRate(0.4);
  }

  @override
  void initState() {
    _setTTS();
    _getAllOrderData(0, false, true);
    _getAllOrderData(0, false, false);

    _orderScrollController.addListener(() async {
      if (_orderScrollController.position.maxScrollExtent ==
          _orderScrollController.position.pixels) {
        await _getAllOrderData(_orderList.length, false, true);
      }
    });
    _allScrollController.addListener(() async {
      if (_allScrollController.position.maxScrollExtent ==
          _allScrollController.position.pixels) {
        await _getAllOrderData(_allOrderList.length, false, false);
      }
    });
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_isFinished) {
        _topOrderID = _orderList[0].orderID; // 예전 리스트
        await _getAllOrderData(0, true, true);

        var currentTop = _orderList[0].orderID; // 새로운 리스트
        print(_topOrderID);
        print(currentTop);
        if (currentTop.compareTo(_topOrderID) > 0) {
          int index = _orderList
              .indexWhere((element) => element.orderID == _topOrderID);

          for (int i = 0; i < 2; ++i) await _tts.speak('주문이 들어왔습니다.');
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tts.stop();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(
        barTitle: '주문 목록',
        actions: [
          IconButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullListPage(
                              user: widget.user,
                              isResv: false,
                            )));
                if (res) {
                  // await _getAllOrderData();
                }
              },
              icon: Icon(Icons.list_alt_rounded, color: Colors.black),
              iconSize: 30)
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.qr_code_scanner),
          onPressed: () async {
            var res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QrSearchScannerPage(admin: widget.user)));
            // if (res) await _getAllOrderData();
          }),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getAllOrderData(0, true, _isChecked);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DefaultButtonComp(
                    child: Row(children: [
                      Icon(
                          _isChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.blue),
                      Text(' 주문 처리 완료 및 결제 취소 안보기',
                          style: TextStyle(fontSize: 11, color: Colors.black))
                    ]),
                    onPressed: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    })
              ],
            ),
            _isFinished
                ? _isChecked
                    ? _orderList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text('업로드 된 주문 내역이 없습니다!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ))
                        : Expanded(
                            child: ListView.builder(
                                controller: _orderScrollController,
                                itemBuilder: (context, index) {
                                  return _itemTile(_orderList[index], size);
                                },
                                itemCount: _orderList.length))
                    : _allOrderList.length == 0
                        ? Expanded(
                            child: Center(
                            child: Text('업로드 된 주문 내역이 없습니다!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ))
                        : Expanded(
                            child: ListView.builder(
                                controller: _allScrollController,
                                itemBuilder: (context, index) {
                                  if (_isOverflow &&
                                      index == _allOrderList.length) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      child: Center(
                                          child: Text(
                                        '더 이상 불러올 주문이 없습니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.red),
                                      )),
                                    );
                                  }
                                  if (index == _allOrderList.length) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  return _itemTile(_allOrderList[index], size);
                                },
                                itemCount: _allOrderList.length + 1),
                          )
                : Expanded(
                    child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('불러오는 중..'), CircularProgressIndicator()],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget _itemTile(Order order, Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.all(size.width * 0.01),
      padding: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.black)),
      child: DefaultButtonComp(
        onLongPress: () {
          if (order.orderState != 4)
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title:
                          Text('결제 강제 취소', style: TextStyle(color: Colors.red)),
                      content: Text('※ 관리자 권한으로 결제를 강제로 취소하시겠습니까?'),
                      actions: [
                        DefaultButtonComp(
                            onPressed: () => Navigator.pop(context),
                            child: Text('아니오')),
                        DefaultButtonComp(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: Text('관리자 Key 인증'),
                                        content: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.orange[200]!),
                                              color: Colors.blue[100]),
                                          child: TextField(
                                            inputFormatters: [
                                              UpperCaseTextFormatter()
                                            ],
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Admin Key'),
                                            controller: _adminKeyController,
                                          ),
                                        ),
                                        actions: [
                                          DefaultButtonComp(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text('취소')),
                                          DefaultButtonComp(
                                              onPressed: () async {
                                                var result = await AdminUtil
                                                    .certifyAdminAccess(
                                                        widget.user!.uid!,
                                                        _adminKeyController
                                                            .text);

                                                Navigator.pop(ctx);
                                                if (result) {
                                                  _cancelResponse =
                                                      await PaymentUtil
                                                          .cancelPayment(
                                                              order.tid,
                                                              order.orderID,
                                                              order.totalPrice,
                                                              true);

                                                  var isSuccess =
                                                      await PaymentUtil
                                                          .cancelOrderHandling(
                                                              order
                                                                  .user!.userID,
                                                              order,
                                                              _cancelResponse!);

                                                  if (isSuccess) {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: this.context,
                                                        builder:
                                                            (c) => AlertDialog(
                                                                  title: Text(
                                                                      '결제취소 성공',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Colors
                                                                              .green,
                                                                          fontSize:
                                                                              16)),
                                                                  content: Text(
                                                                      '${_cancelResponse!.resultMsg}',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14)),
                                                                  actions: [
                                                                    DefaultButtonComp(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              c);
                                                                          setState(
                                                                              () {
                                                                            // _getAllOrderData();
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                            '확인'))
                                                                  ],
                                                                ));
                                                  } else {
                                                    await showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder:
                                                            (c) => AlertDialog(
                                                                  title: Text(
                                                                    '결제취소 실패',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  content: Text(
                                                                      '${_cancelResponse!.resultMsg} (code-${_cancelResponse!.resultCode})',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14)),
                                                                  actions: [
                                                                    DefaultButtonComp(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              c);
                                                                        },
                                                                        child: Text(
                                                                            '확인'))
                                                                  ],
                                                                ));
                                                  }
                                                } else {
                                                  ToastMessage.show(
                                                      '인증에 실패했습니다.');
                                                }
                                              },
                                              child: Text('인증'))
                                        ],
                                      ));
                            },
                            child: Text(
                              '예',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ))
                      ],
                    ));
        },
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminDetailOrder(
                        user: widget.user,
                        order: order,
                      )));
          if (res) {
            // await _getAllOrderData();
          }
        },
        child: Container(
          width: size.width * 0.9,
          padding: EdgeInsets.all(size.width * 0.005),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('주문번호 : ${order.orderID}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(DateFormatter.formatDateTimeCmp(order.orderDate),
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: size.height * 0.003),
              Text(
                  '주문자: [${Status.statusList[order.user!.identity - 1]}] ${order.user!.studentID ?? ''} ${order.user!.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Text('주문 완료 일자: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: size.width * 0.02),
                  Text(
                      '${order.editDate == '0000-00-00 00:00:00' ? '-' : order.editDate}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                ],
              ),
              SizedBox(height: size.height * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('[${order.receiveMethod == 0 ? '직접 수령' : '배달'}]',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: order.receiveMethod == 0
                              ? Colors.lightBlue
                              : Colors.green)),
                  order.orderState == 2
                      ? Row(
                          children: [
                            _adminStateBar(
                                '처리 담당 중', Colors.lightBlueAccent, size),
                            GestureDetector(
                              onTap: () async {
                                var user = await _getAdminUserInfoByID(
                                    order.chargerID!);
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          shape: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          title: Text('관리자 정보'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID : ${user!['uid']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                  '이름 : ${user['name']} [${Status.statusList[int.parse(user['identity']) - 1]}]',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  '학번 : ${user['student_id'] == '' ? 'X' : user['student_id']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                          actions: [
                                            DefaultButtonComp(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('닫기'))
                                          ],
                                        ));
                              },
                              child: Row(
                                children: [
                                  Text('  담당자 [',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  Text(order.chargerID!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 12)),
                                  Text(']',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                ],
                              ),
                            )
                          ],
                        )
                      : order.orderState == 3
                          ? _adminStateBar(
                              '처리 완료', Colors.lightGreenAccent, size)
                          : order.orderState == 4
                              ? _adminStateBar('결제 취소', Colors.grey[300]!, size)
                              : _adminStateBar('', Colors.transparent, size),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminStateBar(String title, Color color, Size size) {
    return Container(
        width: size.width * 0.22,
        height: size.height * 0.025,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(6), color: color),
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        alignment: Alignment.center);
  }
}
