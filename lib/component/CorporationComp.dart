import 'package:flutter/material.dart';

/// 법인 정보를 보여주는 위젯 컴포넌트
class CorporationInfo extends StatefulWidget {
  const CorporationInfo({Key? key, required this.isOpenable}) : super(key: key);
  final bool isOpenable; // 개폐 유무 (true: 클릭 시 개방, false: 항상 개방)

  @override
  State<CorporationInfo> createState() => _CorporationInfoState();
}

class _CorporationInfoState extends State<CorporationInfo> {
  final _defaultFontSize = 9.0;
  bool _isClicked = false;

  @override
  void initState() {
    _isClicked = !widget.isOpenable;
    super.initState();
  }

  TextStyle _textStyle() =>
      TextStyle(color: Colors.grey, fontSize: _defaultFontSize);

  Text _titleText() => Text(
        '회사 정보',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: _defaultFontSize + 1),
      );

  Widget _corpInfo(Size size) => _columnCrossAxisStart([
        SizedBox(
          height: size.height * 0.005,
        ),
        Text(
          '사업자 번호: 135-82-17822',
          style: _textStyle(),
        ),
        Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합', style: _textStyle()),
        Text('대표자: 김은미', style: _textStyle()),
        Text('위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
            style: _textStyle()),
        Text('대표 전화: 031-485-9742', style: _textStyle()),
        Text('대표 이메일: asgscoop@naver.com', style: _textStyle())
      ]);

  Widget _clickableTitle(Size size) => GestureDetector(
        onTap: () {
          setState(() {
            _isClicked = !_isClicked;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: size.width * 0.02,
            ),
            _titleText(),
            Icon(_isClicked
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down)
          ],
        ),
      );

  Widget _columnCrossAxisStart(List<Widget> widgets) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        width: size.width,
        padding: EdgeInsets.all(size.width * 0.01),
        color: Colors.grey[100],
        child: _columnCrossAxisStart([
          widget.isOpenable ? _clickableTitle(size) : _titleText(),
          _isClicked ? _corpInfo(size) : SizedBox()
        ]));
  }
}
