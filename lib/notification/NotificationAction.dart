import 'package:flutter/material.dart';

import '../WebViewPage.dart';
import '../util/GlobalVariable.dart';

class NotificationAction {
  static void _moveScreenAccordingToPush(
      {required String title, required String url}) {
    Navigator.push(
        GlobalVariable.navigatorState.currentContext!,
        MaterialPageRoute(
            builder: (context) => WebViewPage(
                  title: title,
                  baseUrl: url,
                )));
  }

  static void selectLocation(String screenLoc) {
    switch (screenLoc) {
      case '공지사항':
        _moveScreenAccordingToPush(
            title: '공지사항',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030100&searchMasterSid=3');
        break;
      case '학교 행사':
        _moveScreenAccordingToPush(
            title: '학교 행사',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030200&searchMasterSid=4');
        break;
      case '학습 자료실':
        _moveScreenAccordingToPush(
            title: '학습 자료실',
            url:
                'http://www.asgs.hs.kr/home/formError.do?code=NONE_LEVEL&menugrp=040300&gm=http%3A%2F%2Fgm7.goeia.go.kr&siteKey=QzlWVUd0ZVZHdFR1R3I3QXlpeHgzNDI1YVRkQk5sT09LbWhZSWlnbjA5bz0%3D');
        break;
      case '학교 앨범':
        _moveScreenAccordingToPush(
            title: '학교 앨범',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030600&searchMasterSid=6');
        break;
      case '오늘의 식단':
        _moveScreenAccordingToPush(
            title: '오늘의 식단',
            url: 'http://www.asgs.hs.kr/meal/formList.do?menugrp=040801');
        break;
      case '이 달의 일정':
        _moveScreenAccordingToPush(
            title: '이 달의 일정',
            url:
                'http://www.asgs.hs.kr/diary/formList.do?menugrp=030500&searchMasterSid=1');
        break;
      case '가정 통신문':
        _moveScreenAccordingToPush(
            title: '가정 통신문',
            url:
                'http://www.asgs.hs.kr/bbs/formList.do?menugrp=030400&searchMasterSid=49');
        break;
      case '도서 검색':
        _moveScreenAccordingToPush(
            title: '도서 검색',
            url:
                'https://reading.gglec.go.kr/r/newReading/search/schoolCodeSetting.jsp?schoolCode=895&returnUrl=');
        break;
    }
  }
}
