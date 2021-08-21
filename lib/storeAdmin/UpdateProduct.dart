import 'dart:io';

import 'package:asgshighschool/data/product_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UpdatingProductPage extends StatefulWidget {
  UpdatingProductPage({this.product});
  final Product product;
  @override
  _UpdatingProductPageState createState() => _UpdatingProductPageState();
}

class _UpdatingProductPageState extends State<UpdatingProductPage> {
  var _productNameController = TextEditingController();
  var _productPriceController = TextEditingController();
  var _productCountController = TextEditingController();
  var _productExplainController = TextEditingController();
  var _productDiscountController = TextEditingController();
  var _mainImageNameController = TextEditingController();
  var _subImage1NameController = TextEditingController();
  var _subImage2NameController = TextEditingController();
  var _cumulativeSellCount = TextEditingController();

  PickedFile _mainImage;
  PickedFile _subImage1;
  PickedFile _subImage2;

  bool _isBest = false;
  bool _isNew = false;

  bool _useSub1 = false;
  bool _useSub2 = false;

  int _clickCount = 0;
  bool _imageInitial = true;

  final _categoryList = ['음식류', '간식류', '음료류', '문구류', '핸드메이드']; //드롭다운 아이템
  final _categoryMap = {
    '음식류': 0,
    '간식류': 1,
    '음료류': 2,
    '문구류': 3,
    '핸드메이드': 4
  }; // 드롭다운 mapping
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  }; // 드롭다운 reverse mapping
  var _selectedCategory = '음식류'; // 드롭다운 아이템 default
  String serverImageUri =
      'http://nacha01.dothome.co.kr/sin/arlimi_productImage/'; // 이미지 저장 서버 URI

  // index : {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromGallery(int index) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _imageInitial = false;
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
      _imageInitial = false;
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

  Future<bool> _updateImageBeforeRequest(
      PickedFile img, String fileName, String originName) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://nacha01.dothome.co.kr/sin/arlimi_addImgForUpdate.php'));
    var picture = await http.MultipartFile.fromPath('imgFile', img.path,
        filename: fileName + '.jpg');
    request.files.add(picture);
    request.fields['oriName'] =
        originName == null ? 'None' : originName.replaceAll(serverImageUri, '');
    request.fields['newName'] = fileName + '.jpg';

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      if (responseString.contains('일일 트래픽을 모두 사용하였습니다.')) {
        return false;
      }
      if (responseString != 'completeX0' && responseString != '1completeY0')
        return false;

      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateProductRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_updateProduct.php';
    final response = await http.post(url, body: <String, String>{
      'prodID': widget.product.prodID.toString(),
      'prodName': _productNameController.text,
      'prodInfo': _productExplainController.text,
      'category': _categoryMap[_selectedCategory].toString(),
      'price': _productPriceController.text,
      'stockCount': _productCountController.text,
      'discount': _productDiscountController.text,
      'isBest': _isBest ? '1' : '0',
      'isNew': _isNew ? '1' : '0',
      'img1': serverImageUri + _mainImageNameController.text + '.jpg',
      'img2': _useSub1
          ? serverImageUri + _subImage1NameController.text.trim() + '.jpg'
          : 'None',
      'img3': _useSub2
          ? serverImageUri + _subImage2NameController.text.trim() + '.jpg'
          : 'None'
    });

    if (response.statusCode == 200) {
      var replace = response.body.replaceAll(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
          '');
      if (replace.trim() != '1') {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<int> _doUpdateForProduct() async {
    if (_useSub1) {
      var sub1Result = await _updateImageBeforeRequest(
          _subImage1, _subImage1NameController.text, widget.product.imgUrl2);
      if (!sub1Result) return 402;
    }
    if (_useSub2) {
      var sub2Result = await _updateImageBeforeRequest(
          _subImage2, _subImage2NameController.text, widget.product.imgUrl3);
      if (!sub2Result) return 403;
    }

    var mainResult = await _updateImageBeforeRequest(
        _mainImage, _mainImageNameController.text, widget.product.imgUrl1);
    if (!mainResult) return 401;

    var registerResult = await _updateProductRequest();
    if (!registerResult) return 500;
    return 200; // 성공 코드
  }

  @override
  void initState() {
    _productNameController.text = widget.product.prodName;
    _productExplainController.text = widget.product.prodInfo;
    _productPriceController.text = widget.product.price.toString();
    _productCountController.text = widget.product.stockCount.toString();
    _mainImageNameController.text = widget.product.imgUrl1
        .replaceAll(serverImageUri, '')
        .replaceAll('.jpg', '');
    _subImage1NameController.text = widget.product.imgUrl2;
    _subImage2NameController.text = widget.product.imgUrl3;
    _selectedCategory = _categoryReverseMap[widget.product.category];
    _isBest = widget.product.isBest == 1 ? true : false;
    _isNew = widget.product.isNew == 1 ? true : false;
    _cumulativeSellCount.text = widget.product.cumulBuyCount.toString();
    _productDiscountController.text = widget.product.discount.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '상품 수정하기 [${widget.product.prodID}]',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '*표시는 필수 입력 사항',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 20,
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
                titleLayoutWidget(title: '가격(원)', require: true, size: size),
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
            Row(
              children: [
                titleLayoutWidget(title: '할인율(%)', require: false, size: size),
                SizedBox(
                  width: size.width * 0.02,
                ),
                textFieldLayoutWidget(
                    width: size.width * 0.7,
                    height: size.height * 0.07,
                    controller: _productDiscountController,
                    maxCharNum: 10,
                    formatType: false)
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
                titleLayoutWidget(title: '누적 구매수', require: false, size: size),
                SizedBox(
                  width: size.width * 0.02,
                ),
                textFieldLayoutWidget(
                    width: size.width * 0.7,
                    height: size.height * 0.07,
                    controller: _cumulativeSellCount,
                    maxCharNum: 10,
                    formatType: true,
                    isReadOnly: true)
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
                    ),
                    Container(
                      margin: EdgeInsets.all(3),
                      width: size.width * 0.2,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _imageInitial = true;
                            });
                          },
                          icon: Icon(Icons.refresh_rounded)),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.teal),
                          color: Color(0xFF9EE1E5),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _imageInitial
                    ? Column(
                        children: [
                          Text(
                            '※아래 이미지는 임시 이미지입니다. \n상품수정을 완료하려면 새로 이미지를 불러오세요!',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Image.network(
                            widget.product.imgUrl1,
                            width: size.width * 0.9,
                            height: size.height * 0.45,
                            fit: BoxFit.fill,
                          ),
                        ],
                      )
                    : _mainImage == null
                        ? imageLoadLayout(size)
                        : Image.file(
                            File(_mainImage.path),
                            fit: BoxFit.fill,
                            width: size.width * 0.9,
                            height: size.height * 0.45,
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
                        controller: _mainImageNameController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: 'abcd123',
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
                              File(_subImage1.path),
                              fit: BoxFit.fill,
                              width: size.width * 0.9,
                              height: size.height * 0.45,
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
                                  hintText: 'abcd123',
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
                              File(_subImage2.path),
                              fit: BoxFit.fill,
                              width: size.width * 0.9,
                              height: size.height * 0.45,
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
                                  hintText: 'abcd123',
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
            GestureDetector(
              onTap: () {
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
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Colors.black26)),
                width: size.width * 0.85,
                height: size.height * 0.04,
                alignment: Alignment.center,
                child: Text(
                  '이미지 추가하기(최대 2개)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                child: Text(
                  '최종 등록하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_mainImageNameController.text ==
                      widget.product.imgUrl1
                          .replaceAll(serverImageUri, '')
                          .replaceAll('.jpg', '')) {
                    Fluttertoast.showToast(
                        msg: '기존과 다른 이름의 파일명을 작성해주세요!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM);
                    return;
                  }
                  if (_productNameController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_productExplainController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_productCountController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_productPriceController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_mainImageNameController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_useSub1 && _subImage1NameController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_useSub2 && _subImage2NameController.text.isEmpty) {
                    showErrorDialog();
                    return;
                  }
                  if (_mainImage == null && !_imageInitial) {
                    showErrorDialog();
                    return;
                  }
                  if (_useSub1 && _subImage1 == null) {
                    showErrorDialog();
                    return;
                  }
                  if (_useSub2 && _subImage2 == null) {
                    showErrorDialog();
                    return;
                  }
                  var result = await _doUpdateForProduct();
                  String message;
                  switch (result) {
                    case 200:
                      message = '상품 수정에 성공하였습니다! 목록을 새로고침하세요';
                      break;
                    case 401:
                      message = '대표 이미지 수정에 실패했습니다!';
                      break;
                    case 402:
                      message = '추가 이미지 1 수정에 실패했습니다!';
                      break;
                    case 403:
                      message = '추가 이미지 2 수정에 실패했습니다!';
                      break;
                    case 500:
                      message = '최종 상품 수정에 실패하였습니다!';
                      break;
                  }
                  Fluttertoast.showToast(
                      msg: message,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM);
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        )),
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
      bool formatType = false,
      bool isReadOnly = false}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(3),
      height: height,
      width: width,
      child: TextField(
        readOnly: isReadOnly,
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
      width: size.width * 0.23,
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
        width: size.width * 0.9,
        height: size.height * 0.45,
        child: Text(
          '이미지를 불러와주세요',
          style: TextStyle(color: Colors.grey[400]),
        ),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(border: Border.all(width: 5, color: Colors.grey)));
  }

  void showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('문제 발생'),
              content: Text('입력사항을 재확인 바랍니다'),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context), child: Text('확인'))
              ],
            ));
  }
}
