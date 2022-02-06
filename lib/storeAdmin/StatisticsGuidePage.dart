import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatisticsGuidePage extends StatefulWidget {
  @override
  _StatisticsGuidePageState createState() => _StatisticsGuidePageState();
}

class _StatisticsGuidePageState extends State<StatisticsGuidePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '통계 가이드',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.02),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '공통',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                  '- 시간 설정의 경우 "설정 없음"의 의미는 00시 00분으로 Default 값으로 사용합니다. (= 오전 12시, 밤 12시)  '),
              SizedBox(
                height: size.height * 0.025,
              ),
              Row(
                children: [
                  Text('매출 통계',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                  '- 매출 통계에서 "날짜 단위"가 "전체"를 제외한 나머지의 경우에는 시간 설정하지 않을 것을 권고합니다.'),
              Text(
                  '(전체를 제외한 나머지를 사용할 경우 시간을 모두 "설정 없음" 혹은 00시 00분으로 설정하시길 바랍니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(
                height: size.height * 0.025,
              ),
              Row(
                children: [
                  Text(' 1. 일간',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('- 시작 날짜 포함해서 종료 날짜의 전날까지의 각 매출을 보여줍니다.'),
              Text(
                '※ 권고 사항 :종료 날짜에 대한 매출도 필요한 경우 +1일을 권고합니다. ',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Text('ex) 2022년 1월 5일을 포함한 결과를 얻고 싶다면 종료 날짜를 2022-01-06으로 설정',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(
                height: size.height * 0.025,
              ),
              Row(
                children: [
                  Text(' 2. 주간',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                  '- 시작 날짜 포함해서 종료 날짜까지의 범위에서 7일 간격에 대한 매출을 보여줍니다. (각 간격의 시작날짜와 종료 날짜가 포함된 매출)'),
              Text(
                  '※ 권고 사항 : 7일 간격은 설정한 시작 날짜를 기준으로 시작하기 때문에 달력 상에서의 각 주의 결과를 원할 경우에는 시작날짜를 달력 기준 주의 첫째날로 지정 바람',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(
                height: size.height * 0.025,
              ),
              Row(
                children: [
                  Text(' 3. 월간',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('- 시작 날짜의 (년, 월) 부터 종료 날짜의 (년, 월)까지의 각 월 매출을 보여줍니다. '),
              Text('- 단, 각 시작 날짜와 종료 날짜에 지정된 해당 일부터 해당 월의 마지막 일까지의 매출을 보여줍니다.'),
              Text(
                  'ex) 시작 날짜 : 2021-12-17, 종료 날짜 : 2022-02-07\n* 결과 : \n(2021-12-17 ~ 2021-12-31 에 대한 매출 → 12월)\n(2022-01-01 ~ 2022-01-31 에 대한 매출 → 1월)\n(2022-02-01 ~ 2022-02-07 에 대한 매출 → 2월)',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                  '※권고 사항 : 한달의 결과를 모두 원하는 경우 위와 같은 상황을 방지하고자 시작 날짜의 일(day)을 1일로 지정하고, 종료 날짜의 일(day)을 해당 달의 마지막 일로 지정하기를 권고함.',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                  '- 조회했을 때 특정 달에 대한 매출이 아예 없는 경우(매출 = 0원) 해당 달은 생략되서 보여집니다. '),
              SizedBox(
                height: size.height * 0.025,
              ),
              Row(
                children: [
                  Text(' 4. 전체',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('- 시작 날짜와 시작 시간부터 종료 날짜와 종료 시간까지의 총 매출을 보여줍니다. '),
            ],
          ),
        ),
      ),
    );
  }
}