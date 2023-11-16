import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class MealsAPI {
  static String API_KEY = "";
  static String API_URL =
      "https://open.neis.go.kr/hub/mealServiceDietInfo?ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7530182";
  static String EMPTY_TEXT = "급식 정보가 없습니다.";

  Future<String> fetchTodayMealInfo() async {
    final response = await http.get(
        Uri.parse(
            '$API_URL&MLSV_FROM_YMD=${_getTodayYMD()}&MLSV_TO_YMD=${_getTodayYMD()}'),
        headers: <String, String>{'Authorization': 'Bearer $API_KEY'});

    if (response.statusCode == 200) {
      final xmlDoc = xml.XmlDocument.parse(response.body);
      print(xmlDoc);
      final mealElements =
          xmlDoc.findAllElements('DDISH_NM'); // 'DDISH_NM' 요소 찾기
      final nutritionElements =
          xmlDoc.findAllElements('ORPLC_INFO'); // 'NTR_INFO' 요소 찾기

      if (mealElements.isNotEmpty) {
        print(mealElements);
        final mealElement = mealElements.first;
        final mealText = mealElement.innerText.replaceAll('<br/>', '\n');

        String nutritionText = ''; // 영양정보를 담을 변수 초기화

        if (nutritionElements.isNotEmpty) {
          final nutritionElement = nutritionElements.first;
          nutritionText =
              nutritionElement.innerText.replaceAll('<br/>', ''); // 영양정보 가져오기
        }

        return mealText;
      }
    }
    return EMPTY_TEXT;
  }

  String _getTodayYMD() {
    var string = DateTime.now().toString();
    return string.split(' ')[0].replaceAll('-', '');
  }
}
