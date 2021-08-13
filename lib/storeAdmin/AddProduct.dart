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

//나중에 실사용될 때, 상품 등록할 때 어드민 계정으로 비밀번호로 재확인

class _AddingProductPageState extends State<AddingProductPage> {
  var _productNameController = TextEditingController();
  var _productPriceController = TextEditingController();
  var _productCountController = TextEditingController();
  var _productExplainController = TextEditingController();

  var _mainImageNameController = TextEditingController();
  var _subImage1NameController = TextEditingController();
  var _subImage2NameController = TextEditingController();

  var _mainImage;
  var _subImage1;
  var _subImage2;

  var _mainImageFileName;
  var _subImage1FileName;
  var _subImage2FileName;

  bool _mainSent = false;
  bool _sub1Sent = false;
  bool _sub2Sent = false;

  bool _isBest = false;
  bool _isNew = false;

  bool _useSub1 = false;
  bool _useSub2 = false;

  int _clickCount = 0;

  final _categoryList = ['음식류', '간식류', '음료류', '문구류', '핸드메이드']; //드롭다운 아이템
  final _categoryMap = {
    '음식류': 0,
    '간식류': 1,
    '음료류': 2,
    '문구류': 3,
    '핸드메이드': 4
  }; // 드롭다운 mapping
  var _selectedCategory = '음식류'; // 드롭다운 아이템 default

  // index : {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromGallery(int index) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      switch (index) {
        case 0:
          _mainImage = image;
          break;
        case 1:
          _subImage1 = image;
          break;
        case 2:
          _subImage2 = image;
          break;
      }
    });
  }

  // index : {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromCamera(int index) async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      switch (index) {
        case 0:
          _mainImage = image;
          break;
        case 1:
          _subImage1 = image;
          break;
        case 2:
          _subImage2 = image;
          break;
      }
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
      'prodName': _productNameController.text,
      'prodExp': _productExplainController.text,
      'category': _categoryMap[_selectedCategory].toString(),
      'price': _productPriceController.text,
      'stockCount': _productCountController.text,
      'isBest': 'false',
      'isNew': 'false'
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
                      height: size.height * 0.09,
                      controller: _productNameController,
                      maxCharNum: 100,
                      maxLine: 3)
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
                      height: size.height * 0.15,
                      controller: _productExplainController,
                      maxCharNum: 3000,
                      maxLine: 5)
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
              Divider(
                thickness: 2,
                endIndent: 15,
                indent: 15,
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
              Divider(
                thickness: 2,
                endIndent: 15,
                indent: 15,
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
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: size.width * 0.32,
                    height: size.height * 0.06,
                    child: Text(
                      'Best 메뉴 여부',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  Container(
                    width: size.width * 0.6,
                    child: Checkbox(
                        value: _isBest,
                        onChanged: (value) {
                          setState(() {
                            _isBest = value;
                          });
                        }),
                  )
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
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: size.width * 0.32,
                    height: size.height * 0.06,
                    child: Text(
                      'New 메뉴 여부',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  Container(
                    width: size.width * 0.6,
                    child: Checkbox(
                        value: _isNew,
                        onChanged: (value) {
                          setState(() {
                            _isNew = value;
                          });
                        }),
                  )
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
              SizedBox(
                height: 10,
              ),
              /*----------------------------------------------------*/
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
                            onPressed: () => _getImageFromCamera(0),
                            icon: Icon(Icons.camera_alt_rounded)),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.teal),
                            color: Color(0xFF9EE1E5),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.2,
                        child: IconButton(
                            onPressed: () => _getImageFromGallery(0),
                            icon: Icon(Icons.photo_outlined)),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.teal),
                            color: Color(0xFF9EE1E5),
                            borderRadius: BorderRadius.circular(5)),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _mainImage == null
                      ? imageLoadLayout(size)
                      : Image.file(
                          File((_mainImage as PickedFile).path),
                          fit: BoxFit.fill,
                          width: size.width * 0.8,
                          height: size.height * 0.4,
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: size.width * 0.52,
                        height: size.height * 0.06,
                        child: Text(
                          '*대표 이미지 파일 이름(영어,숫자 조합)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xFF9EE1E5),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      Container(
                        child: TextField(
                          controller: _mainImageNameController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: 'abcd123.jpg',
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                        width: size.width * 0.4,
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              /* ---------------------------------------------------- */
              _useSub1
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: size.width * 0.6,
                              height: size.height * 0.05,
                              child: Text(
                                '추가 이미지 1 선택',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _clickCount--;
                                  _useSub1 = false;
                                  _subImage1 = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                              color: Colors.red,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () => _getImageFromCamera(1),
                                  icon: Icon(Icons.camera_alt_rounded)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () => _getImageFromGallery(1),
                                  icon: Icon(Icons.photo_outlined)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            )
                          ],
                        ),
                        _subImage1 == null
                            ? imageLoadLayout(size)
                            : Image.file(
                                File((_subImage1 as PickedFile).path),
                                fit: BoxFit.fill,
                                width: size.width * 0.8,
                                height: size.height * 0.4,
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.center,
                              width: size.width * 0.52,
                              height: size.height * 0.06,
                              child: Text(
                                '*이미지 파일 이름(영어,숫자 조합)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            Container(
                              child: TextField(
                                controller: _subImage1NameController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    hintText: 'abcd123.jpg',
                                    hintStyle: TextStyle(color: Colors.grey)),
                              ),
                              width: size.width * 0.4,
                            )
                          ],
                        )
                      ],
                    )
                  : SizedBox(),
              /* ---------------------------------------------------- */
              _useSub2
                  ? Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: size.width * 0.6,
                              height: size.height * 0.05,
                              child: Text(
                                '추가 이미지 2 선택',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _clickCount--;
                                  _useSub2 = false;
                                  _subImage2 = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                              color: Colors.red,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () => _getImageFromCamera(2),
                                  icon: Icon(Icons.camera_alt_rounded)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () => _getImageFromGallery(2),
                                  icon: Icon(Icons.photo_outlined)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            )
                          ],
                        ),
                        _subImage2 == null
                            ? imageLoadLayout(size)
                            : Image.file(
                                File((_subImage2 as PickedFile).path),
                                fit: BoxFit.fill,
                                width: size.width * 0.8,
                                height: size.height * 0.4,
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.center,
                              width: size.width * 0.52,
                              height: size.height * 0.06,
                              child: Text(
                                '*이미지 파일 이름(영어,숫자 조합)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            Container(
                              child: TextField(
                                controller: _subImage2NameController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    hintText: 'abcd123.jpg',
                                    hintStyle: TextStyle(color: Colors.grey)),
                              ),
                              width: size.width * 0.4,
                            )
                          ],
                        )
                      ],
                    )
                  : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.cyan, borderRadius: BorderRadius.circular(8)),
                width: size.width * 0.85,
                height: size.height * 0.04,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미지 추가하기(최대 2개)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        print(_clickCount);
                        if (_clickCount == 0) {
                          ++_clickCount;
                          setState(() {
                            if (!_useSub1)
                              _useSub1 = true;
                            else if (!_useSub2) _useSub2 = true;
                          });
                        } else if (_clickCount == 1) {
                          ++_clickCount;
                          setState(() {
                            if (!_useSub1)
                              _useSub1 = true;
                            else if (!_useSub2) _useSub2 = true;
                          });
                        }
                      },
                      icon: Icon(Icons.add_circle),
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Container(
                width: size.width * 0.5,
                decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    border: Border.all(width: 2, color: Colors.indigo),
                    borderRadius: BorderRadius.circular(20)),
                child: FlatButton(
                  child: Text('최종 등록하기',style: TextStyle(fontWeight: FontWeight.bold),),
                  onPressed: () {

                  },
                ),
              ),
              SizedBox(height: 15,)
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
        textAlign: TextAlign.center,
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
      {@required String title, @required bool require, @required Size size}) {
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

  Widget imageLoadLayout(Size size) {
    return Container(
        width: size.width * 0.8,
        height: size.height * 0.4,
        child: Text(
          '이미지를 불러와주세요',
          style: TextStyle(color: Colors.grey[400]),
        ),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(border: Border.all(width: 5, color: Colors.grey)));
  }
}
