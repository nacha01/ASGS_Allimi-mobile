import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/user.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../util/NumberFormatter.dart';
import '../../util/ToastMessage.dart';
import 'StatisticsGuidePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatisticsPage extends StatefulWidget {
  final User? user;

  StatisticsPage({this.user});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime _startDate = DateTime.now(); // 시작 날짜
  DateTime _endDate = DateTime.now().add(Duration(days: 1)); // 종료 날짜
  String _startTime = '설정 없음'; // 시작 시간
  String _endTime = '설정 없음'; // 종료 시간
  String _currentOrderQuery = ''; // 구매에 대한 쿼리 조건문 문자열
  String _currentReservationQuery = ''; // 예약에 대한 쿼리 조건문 문자열
  String _salesValue = ''; // "전체"의 경우 저장되는 총 매출 문자열
  String _resultExplainText = ''; // 조회하기 버튼 클릭 시 결과를 설명하는 문자열
  String? _selectedDate = '전체'; // 매출 통계에서 DropdownButton에서 현재 선택한 값
  int _currentTap = 1; // 현재 탭
  int _salesOption = 0; // 0 : 구매 + 예약, 1 : 구매, 2 : 예약
  int? _selectRadio = 0; // 정렬 라디오 버튼에서 선택한 값
  bool _isClicked = false; // 조회하기 버튼 클릭 여부
  bool _noPayedOrder = true; // 상품 통계에서 구매에 대한 미결제 & 결제 체크박스 판단
  bool _noPayedResv = true; // 상품 통계에서 예약에 대한 미결제 & 결제 체크박스 판단
  bool _firstSelectionInOrder = true; // 결제 완료 체크박스
  bool _secondSelectionInOrder = false; // 주문 처리 중 체크박스
  bool _thirdSelectionInOrder = false; // 수령 완료(구매) 체크박스
  bool _firstSelectionInResv = true; // 예약 중 체크박스
  bool _secondSelectionInResv = false; // 예약 완료 체크박스
  bool _thirdSelectionInResv = false; // 수령 완료(예약) 체크박스
  bool _isAsc = true; // 오름차순(true), 내림차순(false) 판단,
  List _orderList = []; // 요청으로 받아온 구매 데이터 리스트
  List _reservationList = []; // 요청으로 받아온 예약 데이터 리스트
  List<ProductCount> _countList = []; // 구매와 예약에 대한 데이터를 분류 및 조합한 최종 리스트
  List _salesRangeList = []; // 매출 통계에서 "전체"가 아닌 단위로 요청 시 담기는 데이터 리스트
  List<Widget> _salesRangeWidgetList = []; // 위의 리스트의 레이아웃 아이템을 담는 리스트
  List _productStockList = [];
  Map<int, Map> _productCountMap = Map(); // 데이터 분류 과정에서 사용되는 Map 데이터
  final List _dateUnitList = ['전체', '일간', '주간', '월간'];
  final List _salesTextList = ['구매 + 예약', '구매', '예약'];
  final List _sortTitleList = ['등록순(ID순)', '이름순', '구매순', '예약순'];

  Future<bool> _getAllProductStockCount() async {
    String url = '${ApiUtil.API_HOST}arlimi_statisticsStock.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);

      List map1st = jsonDecode(result);

      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }
      setState(() {
        _productStockList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 시작 날짜 및 종료 날짜, 그리고 쿼리 조건문 문자열을 바탕으로 모든 구매 데이터들을 가져오는 요청
  Future<bool> _getAllOrderDataInProduct() async {
    String url = '${ApiUtil.API_HOST}arlimi_statisticsProduct.php';
    _currentOrderQuery = _getOrderQueryFromSetting();
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'flag': '0',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'query': _currentOrderQuery
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }
      setState(() {
        _orderList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 상품 통계에서 예약에 대한 체킹 값들에 따른 쿼리 조건문 문자열을 가져오는 작업
  /// 2^3 = 8가지 경우
  String _getReservationQueryFromSetting() {
    // 미결제 시
    if (!_noPayedResv) {
      return 'orderState = 0 AND resv_state = 1';
    }

    // 단일 체크 시
    if (_firstSelectionInResv &&
        !_secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return 'orderState = 1 AND resv_state = 1';
    } else if (!_firstSelectionInResv &&
        _secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return 'orderState = 2 AND resv_state = 2';
    } else if (!_firstSelectionInResv &&
        !_secondSelectionInResv &&
        _thirdSelectionInResv) {
      return 'orderState = 3 AND resv_state = 2';
    }

    // 다중 체크 시
    if (_firstSelectionInResv &&
        _secondSelectionInResv &&
        !_thirdSelectionInResv) {
      return '(orderState >= 1 AND orderState <= 2) AND (resv_state >= 1 AND resv_state <= 2)';
    } else if (!_firstSelectionInResv &&
        _secondSelectionInResv &&
        _thirdSelectionInResv) {
      return '(orderState >= 2 AND orderState <= 3) AND resv_state = 2';
    } else if (_firstSelectionInResv &&
        !_secondSelectionInResv &&
        _thirdSelectionInResv) {
      return '(orderState = 1 AND resv_state = 1) OR (orderState = 3 AND resv_state = 2)';
    } else if (_firstSelectionInResv &&
        _secondSelectionInResv &&
        _thirdSelectionInResv) {
      return '(orderState >= 1 AND orderState <= 3) AND resv_state >= 1';
    }
    setState(() {
      _firstSelectionInResv = true;
      _secondSelectionInResv = false;
      _secondSelectionInResv = false;
    });
    ToastMessage.show('예약 설정에는 반드시 한개라도 체크가 되어 있어야 합니다. 자동으로 기본 체크 값으로 조회됩니다.');
    return 'orderState = 1 AND resv_state = 1';
  }

  /// 상품 통계에서 구매에 대한 체킹 값들에 따른 쿼리 조건문 문자열을 가져오는 작업
  /// 2^3 = 8가지 경우
  String _getOrderQueryFromSetting() {
    // 미결제 시
    if (!_noPayedOrder) {
      return 'orderState = 0 AND resv_state = 0';
    }
    // 단일 체크 시
    if (_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return 'orderState = 1 AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return 'orderState = 2 AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return 'orderState = 3 AND resv_state = 0';
    }

    // 다중 체크 시
    if (_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        !_thirdSelectionInOrder) {
      return '(orderState >= 1 AND orderState <= 2) AND resv_state = 0';
    } else if (!_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return '(orderState >= 2 AND orderState <= 3) ANDresv_state = 0';
    } else if (_firstSelectionInOrder &&
        !_secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return '(orderState = 1 AND resv_state = 0) OR (orderState = 3 AND resv_state = 0)';
    } else if (_firstSelectionInOrder &&
        _secondSelectionInOrder &&
        _thirdSelectionInOrder) {
      return 'orderState = 1 AND resv_state = 0';
    }
    setState(() {
      _firstSelectionInOrder = true;
      _secondSelectionInOrder = false;
      _thirdSelectionInOrder = false;
    });
    ToastMessage.show('구매 설정에는 반드시 체크가 되어 있어야 합니다. 자동으로 기본 체크 값으로 조회됩니다.');
    return '(orderState >= 1 AND orderState <= 3) AND resv_state = 0';
  }

  /// 시작 날짜 및 종료 날짜, 그리고 쿼리 조건문 문자열을 바탕으로 모든 예약 데이터들을 가져오는 요청
  Future<bool> _getAllReservationDataInProduct() async {
    String url = '${ApiUtil.API_HOST}arlimi_statisticsProduct.php';
    _currentReservationQuery = _getReservationQueryFromSetting();
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'flag': '1',
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'query': _currentReservationQuery
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
      }
      setState(() {
        _reservationList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  /// Count 데이터를 갖고 있는 리스트들 중 "구매"의 모든 구매수를 더하는 작업
  int _totalBuyCount() {
    int sum = 0;
    for (int i = 0; i < _countList.length; ++i) {
      sum += _countList[i].orderCount!;
    }
    return sum;
  }

  /// Count 데이터를 갖고 있는 리스트들 중 "예약"의 모든 예약수를 더하는 작업
  int _totalResvCount() {
    int sum = 0;
    for (int i = 0; i < _countList.length; ++i) {
      sum += _countList[i].reservationCount!;
    }
    return sum;
  }

  /// 설정한 쿼리문에 따른 구매 데이터와 예약 데이터를 하나의 Map에 데이터를 넣는 작업
  /// 하나의 Map에 구매수, 예약수, 상품 이름, 카테고리의 Key 데이터가 들어감
  /// 마무리로 상품 ID를 기준으로 정렬
  void _classifyProduct() {
    _productCountMap = Map();
    for (int i = 0; i < _orderList.length; ++i) {
      int pid = int.parse(_orderList[i]['pid']);
      if (!_productCountMap.containsKey(pid)) {
        _productCountMap[pid] = {
          'order': 0,
          'resv': 0,
          'pName': _orderList[i]['pName'],
          'category': Category
              .categoryIndexToStringMap[int.parse(_orderList[i]['category'])]
        };
      }
      if (_productCountMap[pid]!.containsKey('order')) {
        _productCountMap[pid]!['order'] = int.parse(_orderList[i]['quantity']);
      }
    }
    for (int i = 0; i < _reservationList.length; ++i) {
      int pid = int.parse(_reservationList[i]['pid']);
      if (!_productCountMap.containsKey(pid)) {
        _productCountMap[pid] = {
          'order': 0,
          'resv': 0,
          'pName': _reservationList[i]['pName'],
          'category': Category.categoryIndexToStringMap[
              int.parse(_reservationList[i]['category'])]
        };
      }
      if (_productCountMap[pid]!.containsKey('resv')) {
        _productCountMap[pid]!['resv'] =
            int.parse(_reservationList[i]['quantity']);
      }
    }
    _countList = _productCountMap.entries
        .map((e) => ProductCount(e.key, e.value['pName'], e.value['category'],
            e.value['order'], e.value['resv']))
        .toList();
    _countList.sort((a, b) => a.pid.compareTo(b.pid));
  }

  /// 시작 날짜와 종료 날짜, 매출 옵션, 날짜 단위 flag 값을 바탕으로 한 매출 데이터를 가져오는 요청
  /// flag = 0일 때, 전체 요청이므로 단일 데이터
  /// flag > 0일 때, 날짜 짜르는 요청이므로 복수 데이터
  Future<bool> _getTotalSales(int flag) async {
    String url = '${ApiUtil.API_HOST}arlimi_statisticsSales.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'start': _formatStartDateTime(),
      'end': _formatEndDateTime(),
      'option': _salesOption.toString(),
      'date': flag.toString()
    });
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (flag == 0) {
        if (result == '' || result == null) {
          _salesValue = 'NO RESULT';
        } else {
          _salesValue = result;
        }
      } else {
        List map1st = jsonDecode(result);
        for (int i = 0; i < map1st.length; ++i) {
          map1st[i] = jsonDecode(map1st[i]);
        }
        setState(() {
          _salesRangeList = map1st;
          _getResultListForSalesOnUnit(MediaQuery.of(context).size);
        });
      }
      return true;
    } else {
      return false;
    }
  }

  /// 시작 날짜와 시작 시간을 합치는 작업
  String _formatStartDateTime() {
    return _startDate.toString().split(' ')[0] +
        ' ' +
        (_startTime == '설정 없음' ? '00:00' : _startTime);
  }

  /// 종료 날짜와 종료 시간을 합치는 작업
  String _formatEndDateTime() {
    return _endDate.toString().split(' ')[0] +
        ' ' +
        (_endTime == '설정 없음' ? '00:00' : _endTime);
  }

  /// 매출 통계에서 현재 지정한 날짜 단위에 따른 결과를 리스트를 만드는 작업
  /// 일간 : 하나씩 리스트에 추가
  /// 주간 : 7일 간격으로 짜르기
  /// 월간 : 리스트들 중 겹치는 (년, 월) 대로 합치기
  void _getResultListForSalesOnUnit(Size size) {
    _salesRangeWidgetList.clear();
    int sum = 0;
    String start = '';
    String end = '';
    int index = 0;
    int count = 0;
    int order = 0;
    if (_selectedDate == '주간') {
      for (var i = _startDate;; i = i.add(Duration(days: 1))) {
        if ((count + 1) % 7 == 1) {
          start = i.toString().split(' ')[0];
        }
        if (index < _salesRangeList.length &&
            _salesRangeList[index]['date'].toString().split(' ')[0] ==
                i.toString().split(' ')[0]) {
          sum += int.parse(_salesRangeList[index++]['total']);
        } else {
          sum += 0;
        }
        if ((count + 1) % 7 == 0) {
          end = i.toString().split(' ')[0];
          _salesRangeWidgetList.add(_salesItemLayout(size,
              start.split(' ')[0] + ' ~ ' + end.split(' ')[0], sum, order++));
          sum = 0;
        }
        if (_endDate.toString().split(' ')[0] == i.toString().split(' ')[0]) {
          end = i.toString().split(' ')[0];
          _salesRangeWidgetList.add(_salesItemLayout(size,
              start.split(' ')[0] + ' ~ ' + end.split(' ')[0], sum, order++));
          sum = 0;
          break;
        }
        count++;
      }
    } else if (_selectedDate == '월간') {
      if (_salesRangeList.length == 0) {
        return;
      }
      String curYear = _salesRangeList[0]['date'].toString().split('-')[0];
      String curMonth = _salesRangeList[0]['date'].toString().split('-')[1];
      for (int i = 0;; ++i) {
        if (i == _salesRangeList.length - 1) {
          sum += int.parse(_salesRangeList[i]['total']);
          _salesRangeWidgetList.add(_salesItemLayout(
              size,
              _salesRangeList[i]['date']
                      .toString()
                      .substring(0, 7)
                      .replaceAll('-', '년 ') +
                  '월',
              sum,
              order++));
          break;
        }
        if (curYear == _salesRangeList[i]['date'].toString().split('-')[0] &&
            curMonth == _salesRangeList[i]['date'].toString().split('-')[1]) {
          sum += int.parse(_salesRangeList[i]['total']);
        } else {
          _salesRangeWidgetList.add(_salesItemLayout(
              size,
              _salesRangeList[i - 1]['date']
                      .toString()
                      .substring(0, 7)
                      .replaceAll('-', '년 ') +
                  '월',
              sum,
              order++));
          curYear = _salesRangeList[i]['date'].toString().split('-')[0];
          curMonth = _salesRangeList[i]['date'].toString().split('-')[1];
          sum = 0;
          sum += int.parse(_salesRangeList[i]['total']);
        }
      }
    } else if (_selectedDate == '일간') {
      for (var i = _startDate;
          _endDate.toString().split(' ')[0] != i.toString().split(' ')[0];
          i = i.add(Duration(days: 1))) {
        int curValue = 0;
        if (index < _salesRangeList.length &&
            _salesRangeList[index]['date'].toString().split(' ')[0] ==
                i.toString().split(' ')[0]) {
          curValue = int.parse(_salesRangeList[index]['total']);
          index++;
        }
        _salesRangeWidgetList.add(_salesItemLayout(
            size, i.toString().split(' ')[0], curValue, order++));
      }
    }
    setState(() {});
  }

  /// 상품 통계에서 조회한 결과에 대해서 [sortMethod] 값에 따라 리스트르 정렬해주는 작업
  void _sortProductResultByIndex(int? sortMethod) {
    _isAsc = true;
    switch (sortMethod) {
      case 0:
        _countList.sort((a, b) => a.pid.compareTo(b.pid));
        break;
      case 1:
        _countList.sort((a, b) => a.name!.compareTo(b.name!));
        break;
      case 2:
        _countList.sort((a, b) => a.orderCount!.compareTo(b.orderCount!));
        break;
      case 3:
        _countList
            .sort((a, b) => a.reservationCount!.compareTo(b.reservationCount!));
        break;
    }
    setState(() {});
  }

  @override
  void initState() {
    _getAllProductStockCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(
        barTitle: '통계 페이지',
        actions: [
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StatisticsGuidePage()));
            },
            icon: Icon(
              Icons.help_outline,
              color: Colors.black,
            ),
            iconSize: 30,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                DefaultButtonComp(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 1;
                      _countList.clear();
                    });
                  },
                  child: Container(
                    height: size.height * 0.04,
                    width: size.width * 0.3,
                    child: Text('매출 통계',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 1 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                ),
                DefaultButtonComp(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 2;
                      _isAsc = true;
                    });
                  },
                  child: Container(
                    child: Text('상품 통계',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    width: size.width * 0.3,
                    height: size.height * 0.04,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 2 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                ),
                Expanded(
                    child: DefaultButtonComp(
                  onPressed: () {
                    setState(() {
                      _isClicked = false;
                      _currentTap = 3;
                      _countList.clear();
                    });
                  },
                  child: Container(
                    child: Text(
                      '재고 통계',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    height: size.height * 0.04,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color:
                            _currentTap == 3 ? Colors.green[200] : Colors.white,
                        border: Border.all(width: 0.2, color: Colors.grey)),
                  ),
                )),
              ],
            ),
            SizedBox(
              height: size.height * 0.005,
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width: size.width,
              height: size.height * 0.06,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Text(
                      '시작 날짜',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    width: size.width * 0.17,
                  ),
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.043,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue[200]),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Future<DateTime?> selectDate = showDatePicker(
                                helpText: '날짜를 선택하세요',
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2031),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light(), // 밝은테마
                                    child: child!,
                                  );
                                },
                              );
                              selectDate.then((dateTime) {
                                setState(() {
                                  if (dateTime != null) {
                                    _startDate = dateTime;
                                  }
                                });
                              });
                            },
                            icon: Icon(Icons.calendar_today),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.03,
                        ),
                        Text('${_startDate.toString().split(' ')[0]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: size.width * 0.1,
                            height: size.height * 0.043,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blue[200]),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Future<TimeOfDay?> selectTime = showTimePicker(
                                    helpText: '시간을 선택하세요',
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                selectTime.then((value) {
                                  setState(() {
                                    if (value != null) {
                                      _startTime =
                                          '${value.hour}:${value.minute}';
                                    }
                                  });
                                });
                              },
                              icon: Icon(Icons.access_time),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          ),
                          Text('$_startTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width: size.width,
              height: size.height * 0.06,
              margin: EdgeInsets.all(size.width * 0.005),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey)),
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Text(
                      '종료 날짜',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    width: size.width * 0.17,
                  ),
                  Container(
                    width: size.width * 0.45,
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.height * 0.043,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.blue[200]),
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Future<DateTime?> selectDate = showDatePicker(
                                helpText: '날짜를 선택하세요',
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2031),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light(), // 밝은테마
                                    child: child!,
                                  );
                                },
                              );
                              selectDate.then((dateTime) {
                                setState(() {
                                  if (dateTime != null) {
                                    var diff = dateTime.difference(_startDate);
                                    if (diff.inDays >= 0) {
                                      _endDate = dateTime;
                                    } else {
                                      ToastMessage.show(
                                          '종료 날짜는 시작 날짜보다 같거나 작을 수 없습니다.');
                                    }
                                  }
                                });
                              });
                            },
                            icon: Icon(Icons.calendar_today),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.03,
                        ),
                        Text('${_endDate.toString().split(' ')[0]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: size.width * 0.1,
                            height: size.height * 0.045,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blue[200]),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                Future<TimeOfDay?> selectTime = showTimePicker(
                                    helpText: '시간을 선택하세요',
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                selectTime.then((value) {
                                  setState(() {
                                    if (value != null) {
                                      _endTime =
                                          '${value.hour}:${value.minute}';
                                    }
                                  });
                                });
                              },
                              icon: Icon(Icons.access_time),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          ),
                          Text('$_endTime',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.red,
              thickness: 1,
              height: 10,
            ),
            _setLayoutAccordingToTap(size)
          ],
        ),
      ),
    );
  }

  Widget _salesTapLayout(Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '날짜 단위',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Container(
              width: size.width * 0.7,
              color: Colors.grey[200],
              child: DropdownButton(
                value: _selectedDate,
                isExpanded: true,
                underline: SizedBox(),
                items: _dateUnitList.map((e) {
                  return DropdownMenuItem(
                    child: Center(
                      child: Text(
                        e,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    value: e,
                  );
                }).toList(),
                onChanged: (dynamic value) {
                  setState(() {
                    _selectedDate = value;
                    _isClicked = false;
                  });
                },
              ),
            ),
          ],
        ),
        Divider(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '결과 기준',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            DefaultButtonComp(
              onPressed: () {
                setState(() {
                  _salesOption = 0;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _salesOption == 0
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.blue,
                    size: 20,
                  ),
                  Text(
                    ' 구매 + 예약',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            ),
            DefaultButtonComp(
              onPressed: () {
                setState(() {
                  _salesOption = 1;
                });
              },
              child: Row(
                children: [
                  Icon(
                      _salesOption == 1
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue,
                      size: 20),
                  Text(' 구매',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                ],
              ),
            ),
            DefaultButtonComp(
              onPressed: () {
                setState(() {
                  _salesOption = 2;
                });
              },
              child: Row(
                children: [
                  Icon(
                      _salesOption == 2
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.blue,
                      size: 20),
                  Text(' 예약',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                ],
              ),
            ),
          ],
        ),
        Divider(
          height: 0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DefaultButtonComp(
                onPressed: () async {
                  int flag = _dateUnitList.indexOf(_selectedDate);
                  await _getTotalSales(flag);
                  setState(() {
                    _isClicked = true;
                    _resultExplainText = _formatStartDateTime() +
                        " ~ " +
                        _formatEndDateTime() +
                        "\n[${_salesTextList[_salesOption]}] 매출 [$_selectedDate] 통계";
                  });
                },
                child: Container(
                  child: Text(
                    '조회하기',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12),
                  ),
                  width: size.width * 0.23,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * 0.015,
                      horizontal: size.height * 0.015),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6)),
                )),
          ],
        ),
        _isClicked
            ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.orange[200]),
                    child: Text(
                      '$_resultExplainText',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  _selectedDate == '전체'
                      ? Card(
                          child: Container(
                            width: size.width * 0.9,
                            height: size.height * 0.1,
                            alignment: Alignment.center,
                            child: Text(
                              '${_salesValue == 'NO RESULT' || _salesValue == '' ? '0원' : NumberFormatter.formatPrice(int.parse(_salesValue)) + '원'}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        )
                      : _salesRangeWidgetList.length == 0
                          ? Center(
                              child: Text('결과 없음'),
                            )
                          : Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.3, color: Colors.black)),
                                  padding: EdgeInsets.all(size.width * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          'No.',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        width: size.width * 0.15,
                                        alignment: Alignment.center,
                                      ),
                                      Container(
                                          child: Text('날짜',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                          width: size.width * 0.2,
                                          alignment: Alignment.centerLeft),
                                      Container(
                                          child: Text('매출',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                          width: size.width * 0.2,
                                          alignment: Alignment.centerLeft)
                                    ],
                                  ),
                                ),
                                Column(
                                  children: _salesRangeWidgetList,
                                ),
                              ],
                            )
                ],
              )
            : SizedBox(),
      ],
    );
  }

  Widget _productTapLayout(Size size) {
    return Column(
      children: [
        Container(
          height: size.height * 0.06,
          decoration:
              BoxDecoration(border: Border.all(width: 0.3, color: Colors.grey)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                ' 구매 설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = false;
                    _firstSelectionInOrder = false;
                    _secondSelectionInOrder = false;
                    _thirdSelectionInOrder = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _noPayedOrder
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      size: 18,
                      color: _noPayedOrder ? Colors.grey : Colors.blue,
                    ),
                    Text(' 미결제',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.grey : Colors.black))
                  ],
                ),
              ),
              Container(
                width: size.width * 0.005,
                height: size.height * 0.03,
                color: Colors.black,
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _firstSelectionInOrder = !_firstSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _firstSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 결제 완료',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _secondSelectionInOrder = !_secondSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 주문 처리 중',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedOrder = true;
                    _thirdSelectionInOrder = !_thirdSelectionInOrder;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _thirdSelectionInOrder
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedOrder ? Colors.blue : Colors.grey,
                    ),
                    Text(' 수령 완료',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedOrder ? Colors.black : Colors.grey))
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: size.height * 0.06,
          decoration:
              BoxDecoration(border: Border.all(width: 0.3, color: Colors.grey)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                ' 예약 설정',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedResv = false;
                    _firstSelectionInResv = false;
                    _secondSelectionInResv = false;
                    _thirdSelectionInResv = false;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _noPayedResv
                          ? Icons.check_box_outline_blank
                          : Icons.check_box,
                      size: 18,
                      color: _noPayedResv ? Colors.grey : Colors.blue,
                    ),
                    Text(' 미결제',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: _noPayedResv ? Colors.grey : Colors.black))
                  ],
                ),
              ),
              Container(
                width: size.width * 0.005,
                height: size.height * 0.03,
                color: Colors.black,
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _firstSelectionInResv = !_firstSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _firstSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 예약 중',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _secondSelectionInResv = !_secondSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _secondSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 예약 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
              DefaultButtonComp(
                onPressed: () {
                  setState(() {
                    _noPayedResv = true;
                    _thirdSelectionInResv = !_thirdSelectionInResv;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _thirdSelectionInResv
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _noPayedResv ? Colors.blue : Colors.grey,
                    ),
                    Text(' 수령 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: _noPayedResv ? Colors.black : Colors.grey,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DefaultButtonComp(
                onPressed: () async {
                  await _getAllOrderDataInProduct();
                  await _getAllReservationDataInProduct();
                  _classifyProduct();
                  setState(() {
                    _isClicked = true;
                    _isAsc = true;
                    _resultExplainText = _formatStartDateTime() +
                        " ~ " +
                        _formatEndDateTime() +
                        "\n[주문 검색 조건] : ${_currentOrderQuery.replaceAll('orderState', '주문 상태').replaceAll('resv_state', '예약 상태')}\n[예약 검색 조건] : ${_currentReservationQuery.replaceAll('orderState', '주문 상태').replaceAll('resv_state', '예약 상태')}\n상품 통계";
                  });
                },
                child: Container(
                  child: Text(
                    '조회하기',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  width: size.width * 0.23,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(size.width * 0.015),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.red),
                )),
          ],
        ),
        _isClicked
            ? Column(
                children: [
                  Divider(
                    thickness: 1,
                    height: 3,
                  ),
                  Container(
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.orange[200]),
                    child: Text(
                      '$_resultExplainText',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 8,
                  ),
                ],
              )
            : SizedBox(),
        _isClicked
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isAsc = !_isAsc;
                        _countList = List.from(_countList.reversed);
                      });
                    },
                    padding: EdgeInsets.all(0),
                    icon: Icon(_isAsc
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down),
                    iconSize: 26,
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: Center(
                                  child: Text(
                                    '조회 결과 정렬 기준 선택',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                          _sortTitleList.length, (index) {
                                        return RadioListTile<int>(
                                            value: index,
                                            groupValue: _selectRadio,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectRadio = value;
                                              });
                                              _sortProductResultByIndex(
                                                  _selectRadio);
                                              Navigator.pop(context);
                                            },
                                            title: Center(
                                              child: Text(
                                                _sortTitleList[index],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ));
                                      }),
                                    );
                                  },
                                ),
                              ));
                    },
                    icon: Icon(Icons.sort),
                    iconSize: 26,
                    padding: EdgeInsets.all(0),
                  ),
                  Text(
                    '[${_sortTitleList[_selectRadio!]}]',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: size.width * 0.01,
                  )
                ],
              )
            : SizedBox(),
        Container(
          padding: EdgeInsets.all(size.width * 0.01),
          decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: Colors.black)),
          child: Row(
            children: [
              Container(
                child: Text('상품번호(ID)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                width: size.width * 0.2,
                alignment: Alignment.center,
              ),
              Container(
                child: Text('[카테고리] 상품이름',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                width: size.width * 0.4,
                alignment: Alignment.center,
              ),
              Container(
                child: Text('구매수',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                width: size.width * 0.18,
                alignment: Alignment.center,
              ),
              Container(
                child: Text('예약수',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                width: size.width * 0.18,
                alignment: Alignment.center,
              )
            ],
          ),
        ),
        _isClicked
            ? Container(
                padding: EdgeInsets.all(size.width * 0.01),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: Colors.black)),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.red),
                      ),
                      width: size.width * 0.2,
                    ),
                    SizedBox(
                      width: size.width * 0.43,
                    ),
                    Container(
                      child: Text(
                        '${_totalBuyCount()}개',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      width: size.width * 0.15,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text('${_totalResvCount()}개',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      width: size.width * 0.15,
                    ),
                  ],
                ),
              )
            : SizedBox(),
        Container(
          height: size.height * 0.4,
          child: _countList.length == 0
              ? Center(
                  child: Text(
                    '결과 없음',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return _productItemLayout(_countList[index], size);
                  },
                  itemCount: _countList.length,
                ),
        ),
      ],
    );
  }

  Widget _buyerTapLayout(Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              alignment: Alignment.center,
              width: size.width * 0.2,
              child: Text(
                '대표 이미지',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: size.width * 0.45,
              child: Text('상품 이름',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Container(
              alignment: Alignment.center,
              width: size.width * 0.2,
              child: Text('남은 재고',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Text('판매 중',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
          ],
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Container(
          height: size.height * 0.67,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return _productStockItemLayout(_productStockList[index], size);
            },
            itemCount: _productStockList.length,
          ),
        ),
      ],
    );
  }

  Widget _setLayoutAccordingToTap(Size size) {
    switch (_currentTap) {
      case 1:
        return _salesTapLayout(size);
      case 2:
        return _productTapLayout(size);
      case 3:
        return _buyerTapLayout(size);
      default:
        return SizedBox();
    }
  }

  Widget _productItemLayout(ProductCount data, Size size) {
    return Container(
      width: size.width * 0.98,
      padding: EdgeInsets.all(size.width * 0.02),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: Colors.grey)),
      child: Row(
        children: [
          Container(
            child: Text(
              '${data.pid}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 12),
            ),
            width: size.width * 0.13,
          ),
          Container(
            width: size.width * 0.45,
            child: Wrap(
              children: [
                Text(
                  '[${data.category}] ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '${data.name}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                )
              ],
            ),
          ),
          Container(
            width: size.width * 0.15,
            child: Column(
              children: [
                Text(
                  '구매',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text('${data.orderCount}',
                    style: TextStyle(color: Colors.red, fontSize: 12))
              ],
            ),
          ),
          Container(
            width: size.width * 0.15,
            child: Column(
              children: [
                Text('예약',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${data.reservationCount}',
                    style: TextStyle(color: Colors.red, fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _salesItemLayout(
      Size size, String rangeDate, int momentSale, int index) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.all(size.width * 0.004),
      padding: EdgeInsets.all(size.width * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '${index + 1}',
            style: TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Container(
            padding: EdgeInsets.all(size.width * 0.02),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200]),
            child: Text(
              rangeDate,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.015),
              width:
                  _selectedDate == '주간' ? size.width * 0.3 : size.width * 0.45,
              alignment: Alignment.center,
              child: Text(
                NumberFormatter.formatPrice(momentSale) + '원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _productStockItemLayout(Map data, Size size) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.01),
      width: size.width,
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CachedNetworkImage(
            imageUrl: data['imgUrl'],
            width: size.width * 0.15,
            height: size.height * 0.06,
            errorWidget: (context, url, error) {
              return Container(
                alignment: Alignment.center,
                child: Text(
                  'No Image',
                  style: TextStyle(fontSize: 9),
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(6)),
              );
            },
          ),
          Container(
            child: Text(
              data['pName'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            width: size.width * 0.45,
            alignment: Alignment.center,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(data['stockCount'] + '개',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue)),
            width: size.width * 0.2,
          ),
          Icon(
            int.parse(data['onSale']) == 1 ? Icons.check : Icons.clear,
            color:
                int.parse(data['onSale']) == 1 ? Colors.lightGreen : Colors.red,
          )
        ],
      ),
    );
  }
}

class ProductCount {
  int pid;
  String? name;
  String? category;
  int? orderCount;
  int? reservationCount;

  ProductCount(this.pid, this.name, this.category, this.orderCount,
      this.reservationCount);
}
