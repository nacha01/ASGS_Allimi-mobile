import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/user.dart';
import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../data/product_count.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../util/NumberFormatter.dart';

class AdminDetailReservation extends StatefulWidget {
  final List? reservationList;
  final User? user;
  final ProductCount? productCount;

  AdminDetailReservation({this.reservationList, this.user, this.productCount});

  @override
  _AdminDetailReservationState createState() => _AdminDetailReservationState();
}

class _AdminDetailReservationState extends State<AdminDetailReservation> {
  List _productReservationList = [];
  int _newCount = 0;
  List<int> _indexList = [];
  bool _simulationOn = false;
  TextEditingController _countController = TextEditingController();

  /// 넘겨받은 모든 예약 정보들 중에서 예약 처리가 필요한 예약 데이터만 분류하는 전처리 작업
  void _preProcessing() {
    for (int i = 0; i < widget.reservationList!.length; ++i) {
      if (widget.productCount!.pid ==
              int.parse(widget.reservationList![i]['detail'][0]['oPID']) &&
          int.parse(widget.reservationList![i]['orderState']) != 0 &&
          (int.parse(widget.reservationList![i]['orderState']) >= 1 &&
              int.parse(widget.reservationList![i]['orderState']) < 3 &&
              int.parse(widget.reservationList![i]['resvState']) == 1)) {
        _productReservationList.add(widget.reservationList![i]);
      }
    }
    _productReservationList = List.from(_productReservationList.reversed);
    _newCount = int.parse(
        _productReservationList[0]['detail'][0]['pInfo']['stockCount']);
    setState(() {});
  }

  /// 현재 상품의 재고를 변경하는 요청
  /// @param : 수정하고자 하는 상품의 수량 값
  /// @return : 업데이트 성공 여부
  Future<bool> _updateNewCount(int count) async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateProductCountForResv.php?pid=${widget.productCount!.pid.toString() + '&count=$count'}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// @parameter 로부터 받은 데이터를 바탕으로 해당 유저(토큰)에게 push notification 을 보내는 요청
  /// @param : 예약 데이터(유저 정보 포함한)
  /// @return : 보낸 여부
  Future<bool> _sendPushMessage(Map data) async {
    String url = '${ApiUtil.API_HOST}arlimi_sendPushForResv.php';
    print(data['token']);
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'token': data['token'],
      'title': '[두루두루 상품 입고]',
      'message': '예약하신 "${widget.productCount!.name}" 상품이 입고되었습니다.\n 상품 수령바랍니다.'
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// push notification 을 보냄에 따라 '수령 준비' 상태로 변경하기 위해 주문 DB의 orderState 의 값을 2로 변경을 요청하는 작업
  Future<bool> _convertOrderState(String? oid) async {
    String url = '${ApiUtil.API_HOST}arlimi_convertState.php';
    final response = await http.get(Uri.parse(url + '?oid=$oid'));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// 등록된 날짜와 오늘의 날짜를 비교해서 어느 정도 차이가 있는지에 대한 문자열을 반환하는 작업
  /// n일 전, n시간 전, n분 전
  String _formatDateTimeForToday(String origin) {
    var today = DateTime.now();

    int dayDiff =
        int.parse(today.difference(DateTime.parse(origin)).inDays.toString());
    if (dayDiff < 1) {
      int hourDiff = int.parse(
          today.difference(DateTime.parse(origin)).inHours.toString());
      if (hourDiff < 1) {
        int minDiff = int.parse(
            today.difference(DateTime.parse(origin)).inMinutes.toString());
        return minDiff.toString() + '분 전';
      }
      return hourDiff.toString() + '시간 전';
    } else {
      return dayDiff.toString() + '일 전';
    }
  }

  @override
  void initState() {
    _preProcessing();
    super.initState();
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
            barTitle: '[${widget.productCount!.name}] 예약 정보',
            leadingClick: () => Navigator.pop(context, true)),
        body: Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.01),
              child: Row(
                children: [
                  Text(
                    '*상품 정보',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Row(
                children: [
                  Text(
                    '- 현재 재고',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    ' $_newCount개',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '* 재고 수정하기',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                Container(
                  width: size.width * 0.18,
                  child: TextField(
                    controller: _countController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                Container(
                  width: size.width * 0.23,
                  height: size.height * 0.04,
                  child: DefaultButtonComp(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('재고 수정'),
                                content: Text('정말로 수정하시겠습니까?'),
                                actions: [
                                  DefaultButtonComp(
                                      onPressed: () async {
                                        await _updateNewCount(
                                            int.parse(_countController.text));
                                        setState(() {
                                          _newCount =
                                              int.parse(_countController.text);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('예')),
                                  DefaultButtonComp(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('아니오'))
                                ],
                              ));
                    },
                    child: Text(
                      '수정하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.green),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Text(
                '※ 재고 수정의 경우 입고한 경우 새로운 재고를 입력할 때 사용됩니다.',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.02),
              child: Row(
                children: [
                  Text(
                    '- 정가',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    ' ${NumberFormatter.formatNumber(int.parse(_productReservationList[0]['detail'][0]['pInfo']['price']))}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return _personDataTile(_productReservationList[index], size,
                    _indexList.contains(index));
              },
              itemCount: _productReservationList.length,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  child: DefaultButtonComp(
                    onPressed: int.parse(_productReservationList[0]['detail'][0]
                                    ['pInfo']['stockCount']) <
                                1 ||
                            _newCount < 1
                        ? null
                        : () {
                            if (int.parse(_productReservationList[0]['detail']
                                        [0]['pInfo']['stockCount']) <
                                    1 ||
                                _newCount < 1) {
                              return;
                            }
                            setState(() {
                              _simulationOn = !_simulationOn;
                            });
                            if (_simulationOn) {
                              int tmp = _newCount;
                              _indexList.clear();

                              // 순서대로 처리하다가 개수 안맞으면 다음 사람으로 넘어가기
                              for (int i = 0;
                                  i < _productReservationList.length;
                                  ++i) {
                                if (tmp >=
                                    int.parse(_productReservationList[i]
                                        ['detail'][0]['quantity'])) {
                                  tmp -= int.parse(_productReservationList[i]
                                      ['detail'][0]['quantity']);
                                  _indexList.add(i);
                                }
                              }
                            } else {
                              _indexList.clear();
                            }
                          },
                    child: Text(
                      '예약자 선별 ${_simulationOn ? '끄기' : '켜기'}',
                      style: TextStyle(
                          color: _simulationOn ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  width: size.width * 0.37,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black),
                      color: int.parse(_productReservationList[0]['detail'][0]
                                      ['pInfo']['stockCount']) <
                                  1 ||
                              _newCount < 1
                          ? Colors.grey
                          : Colors.deepOrange),
                ),
                Container(
                  margin: EdgeInsets.all(size.width * 0.01),
                  child: DefaultButtonComp(
                    onPressed: int.parse(_productReservationList[0]['detail'][0]
                                    ['pInfo']['stockCount']) <
                                1 ||
                            _newCount < 1
                        ? null
                        : () async {
                            if (int.parse(_productReservationList[0]['detail']
                                    [0]['pInfo']['stockCount']) <
                                1) {
                              return;
                            }
                            if (_indexList.length < 1) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        buttonPadding: EdgeInsets.all(0),
                                        shape: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        title: Text('예약 처리 불가능'),
                                        content: Text(
                                          '선택된 예약자가 없습니다!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        actions: [
                                          DefaultButtonComp(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ));
                              return;
                            }
                            int sum = 0;
                            if (_simulationOn) {
                              for (int i = 0; i < _indexList.length; ++i) {
                                await _sendPushMessage(
                                    _productReservationList[_indexList[i]]);
                                sum += int.parse(
                                    _productReservationList[_indexList[i]]
                                        ['detail'][0]['quantity']);
                                await _convertOrderState(
                                    _productReservationList[_indexList[i]]
                                        ['oID']);
                              }
                              await _updateNewCount(_newCount - sum);
                            }
                          },
                    child: Text(
                      '자동 예약 알림 전송하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  width: size.width * 0.5,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black),
                      color: _simulationOn
                          ? int.parse(_productReservationList[0]['detail'][0]
                                          ['pInfo']['stockCount']) <
                                      1 ||
                                  _newCount < 1
                              ? Colors.grey
                              : Colors.lightBlue
                          : Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _personDataTile(Map data, Size size, bool containAllocate) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.015),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.black),
          borderRadius: BorderRadius.circular(6),
          color: containAllocate ? Colors.deepOrange[200] : Colors.white),
      child: Row(
        children: [
          Container(
            width: size.width * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                Text(
                  '예약 번호',
                  style: TextStyle(fontSize: 10),
                ),
                Text('${data['oID']}',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: size.width * 0.01,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text('${data['name']}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ),
          ),
          Container(
            width: size.width * 0.23,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${data['detail'][0]['quantity']}개',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('${_formatDateTimeForToday(data['oDate'])}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
