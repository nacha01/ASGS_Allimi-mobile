class DateFormatter {
  /// [criteria]를 기준으로 오늘과 비교하여 얼마나 최신인지 참 거짓 리턴
  static bool compareDateIsNew(String cmpDate, int criteria) {
    int diff = int.parse(
        DateTime.now().difference(DateTime.parse(cmpDate)).inDays.toString());
    return diff < criteria;
  }

  /// yyyy년 MM월 dd일 오후(오전) hh시 mm분
  static String formatDateMidday(String origin) {
    var split = origin.split(' ');
    var dateSplit = split[0].split('-');
    String fDate =
        dateSplit[0] + '년 ' + dateSplit[1] + '월 ' + dateSplit[2] + '일 ';

    var timeSplit = split[1].split(':');
    bool isPM = false;
    int hour = int.parse(timeSplit[0]);
    if (hour >= 12) {
      isPM = true;
      hour = (hour == 12) ? hour : hour - 12;
    } else if (hour == 0) {
      isPM = false;
      hour = 12;
    }
    String fTime =
        (isPM ? '오후 ' : '오전 ') + hour.toString() + '시 ' + timeSplit[1] + '분';
    return fDate + fTime;
  }

  /// yyyy년 MM월 dd일 hh시 mm분
  static String formatDate(String origin) {
    var split = origin.split(' ');
    var leftSp = split[0].split('-');
    String date = leftSp[0] + '년 ' + leftSp[1] + '월 ' + leftSp[2] + '일 ';

    var rightSp = split[1].split(':');
    String time = rightSp[0] + '시 ' + rightSp[1] + '분';
    return date + time;
  }

  /// mm/dd hh:mm
  static String formatShortDate(String origin) {
    return origin.substring(5, 16).replaceAll('-', '/');
  }

  /// n일 전, n시간 전, n분 전
  static String formatDateTimeCmp(String origin) {
    var today = DateTime.now();
    var difference = today.difference(DateTime.parse(origin));

    int dayDiff = int.parse(difference.inDays.toString());

    if (dayDiff < 1) {
      int hourDiff = int.parse(difference.inHours.toString());
      if (hourDiff < 1) {
        int minDiff = int.parse(difference.inMinutes.toString());
        return minDiff.toString() + '분 전';
      }
      return hourDiff.toString() + '시간 전';
    }
    return dayDiff.toString() + '일 전';
  }
}
