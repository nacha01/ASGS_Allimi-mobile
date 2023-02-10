import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool _corporationInfoClicked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '이벤트가 없습니다!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          _corpInfoLayout(size)
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
