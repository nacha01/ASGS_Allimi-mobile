import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddingProductPage extends StatefulWidget {
  @override
  _AddingProductPageState createState() => _AddingProductPageState();
}

// 어드민 전용 페이지
//상품 추가 페이지
//저장할 때 비밀번호로 어드민 DB에서 확인
// 직접적으로 추가하는 목록
/*
1. 제품 이름
2. 제품 카테고리
3. 가격
4. 이미지 1,2,3 & 이미지 파일 이름
5. 베스트인지?
6. 새로운건지?
7. 재고
8. 제품 설명
 */
class _AddingProductPageState extends State<AddingProductPage> {
  var _productNameController = TextEditingController();
  var _productPriceController = TextEditingController();
  var _productCountController = TextEditingController();
  var _productExplainController = TextEditingController();
  var _mainImage;
  var _subImage1;
  var _subImage2;
  var _mainImageFileName;
  var _subImage1FileName;
  var _subImage2FileName;
  bool mainSent = false;
  bool sub1Sent = false;
  bool sub2Sent = false;

  final _categoryList = ['음식류', '간식류', '음료류', '문구류', '핸드메이드']; //드롭다운 아이템
  final _categoryMap = {'음식류' : 0, '간식류' : 1, '음료류' : 2, '문구류' : 3, '핸드메이드' : 4};
  var _selectedCategory = '음식류'; // 드롭다운 아이템 default

  Future<void> _getImageFromGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _mainImage = image;
    });
  }

  Future<void> _getImageFromCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _mainImage = image;
    });
  }

  Future<void> _sendImageToServer() async {
    var request = http.MultipartRequest('POST',
        Uri.parse('http://nacha01.dothome.co.kr/sin/arlimi_storeImage.php'));
    var picture = await http.MultipartFile.fromPath(
        'imgFile', (_mainImage as PickedFile).path,
        filename: _mainImageFileName);
    request.files.add(picture);

    var response = await request.send();

    if (response.statusCode == 200) {
      // 전송 성공
    }
  }

  Future<void> _postRequestForInsertProduct() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_insertProduct.php';
    http.Response response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: <String, String>{
      'prodName' : _productNameController.text,
      'prodExp' : _productExplainController.text,
      'category' : _categoryMap[_selectedCategory].toString(),
      'price' : _productPriceController.text,
      'stockCount' : _productCountController.text,
      'isBest' : 'false',
      'isNew' : 'false'
    });

    if (response.statusCode == 200) {
      // 전송 성공
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                '상품 등록하기',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '*표시는 필수 입력 사항',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleLayoutWidget(title: '상품명', require: true, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.15,
                      controller: _productNameController,
                      maxCharNum: 100,
                      maxLine: 3)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleLayoutWidget(title: '상품 설명', require: true, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.2,
                      controller: _productExplainController,
                      maxCharNum: 3000,
                      maxLine: 5)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  titleLayoutWidget(title: '카테고리', require: true, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Container(
                    width: size.width * 0.7,
                    height: size.height * 0.05,
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: _categoryList.map((value) {
                        return DropdownMenuItem(
                          child: Center(child: Text(value)),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  titleLayoutWidget(title: '가격', require: true, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.07,
                      controller: _productPriceController,
                      maxCharNum: 30,
                      validation: true,
                      formatType: true)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  titleLayoutWidget(title: '재고', require: true, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.07,
                      controller: _productCountController,
                      maxCharNum: 10,
                      formatType: true)
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 2,
                endIndent: 15,
                indent: 15,
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: size.width * 0.8,
                    height: size.height * 0.05,
                    child: Text(
                      '*대표 이미지 선택',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.2,
                        child: IconButton(
                            onPressed: _getImageFromCamera,
                            icon: Icon(Icons.camera_alt_rounded)),
                        decoration: BoxDecoration(
                            color: Color(0xFF9EE1E5),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.2,
                        child: IconButton(
                            onPressed: _getImageFromGallery,
                            icon: Icon(Icons.photo_outlined)),
                        decoration: BoxDecoration(
                            color: Color(0xFF9EE1E5),
                            borderRadius: BorderRadius.circular(5)),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _mainImage == null
                      ? Container(
                          width: size.width * 0.7,
                          height: size.height * 0.35,
                          child: Text('이미지를 불러와주세요'),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(width: 5, color: Colors.grey)))
                      : Image.file(
                          File((_mainImage as PickedFile).path),
                          fit: BoxFit.fill,
                          width: size.width * 0.7,
                          height: size.height * 0.35,
                        )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이미지 추가하기 (최대 2개 추가 가능)'),
                  IconButton(onPressed: () {}, icon: Icon(Icons.add_circle))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget textFieldLayoutWidget(
      {double height,
      double width,
      TextEditingController controller,
      int maxCharNum,
      bool validation = false,
      int maxLine = 1,
      bool formatType = false}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(3),
      height: height,
      width: width,
      child: TextField(
        keyboardType: formatType ? TextInputType.number : TextInputType.text,
        inputFormatters: [
          formatType
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.singleLineFormatter
        ],
        decoration: InputDecoration(border: InputBorder.none),
        maxLines: maxLine,
        controller: controller,
        onChanged: (text) {
          setState(() {});
        },
      ),
      decoration:
          BoxDecoration(border: Border.all(width: 2, color: Color(0xFF9EE1E5))),
    );
  }

  Widget titleLayoutWidget(
      {@required String title, @required bool require, Size size}) {
    return Container(
      margin: EdgeInsets.all(5),
      alignment: Alignment.center,
      width: size.width * 0.22,
      height: size.height * 0.06,
      child: Text(
        require ? '*' + title : title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      decoration: BoxDecoration(
          color: Color(0xFF9EE1E5), borderRadius: BorderRadius.circular(8)),
    );
  }
}
