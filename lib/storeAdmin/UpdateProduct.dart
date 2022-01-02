import 'dart:convert';
import 'dart:io';
import 'dart:ui';

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

  var _cumulativeSellCount = TextEditingController();
  var _reservationCountController = TextEditingController();

  PickedFile _mainImage;
  PickedFile _subImage1;
  PickedFile _subImage2;

  bool _isBest = false;
  bool _isNew = false;
  bool _isReservation = false;

  bool _useSub1 = false;
  bool _useSub2 = false;

  int _clickCount = 0;
  bool _imageInitial = true;

  String _mainName;
  String _sub1Name;
  String _sub2Name;

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

  /// 갤러리에서 이미지를 가져오는 작업
  /// [index] : {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromGallery(int index) async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
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

  /// 카메로에서 찍은 이미지를 가져오는 작업
  /// [index] : {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromCamera(int index) async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
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

  /// 최종 요청하기 전 수정하고자 하는 이미지를 서버에 업데이트 요청을 하는 작업
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

  /// 이미지 수정 시에 호출되는 함수
  /// 이미지 파일 이름 규칙에 의한 새로운 이미지 파일 이름 문자열을 반환
  String _getFileNameByRule(String origin) {
    if (origin.contains('_')) {
      origin = origin.substring(0, origin.length - 1) +
          (int.parse(origin[origin.length - 1]) + 1).toString();
      return origin;
    } else {
      return origin + '_1';
    }
  }

  /// 상품을 수정하는 요청을 하는 작업
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
      'img1': _mainImage == null ? 'NOT' : serverImageUri + _mainName + '.jpg',
      'img2': _useSub1 ? serverImageUri + _sub1Name + '.jpg' : 'None',
      'img3': _useSub2 ? serverImageUri + _sub2Name + '.jpg' : 'None'
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

  /// 상품 수정을 위한 과정 process 함수
  /// 이미지 업데이트, 상품 변경 내용 업데이트
  Future<int> _doUpdateForProduct() async {
    if (_useSub1) {
      _sub1Name = _getFileNameByRule(widget.product.imgUrl2
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));

      var sub1Result = await _updateImageBeforeRequest(
          _subImage1, _sub1Name, widget.product.imgUrl2);

      if (!sub1Result) return 402;
    }
    if (_useSub2) {
      _sub2Name = _getFileNameByRule(widget.product.imgUrl3
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));

      var sub2Result = await _updateImageBeforeRequest(
          _subImage2, _sub2Name, widget.product.imgUrl3);

      if (!sub2Result) return 403;
    }
    if (_mainImage != null) {
      _mainName = _getFileNameByRule(widget.product.imgUrl1
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));
      var mainResult = await _updateImageBeforeRequest(
          _mainImage, _mainName, widget.product.imgUrl1);
      if (!mainResult) return 401;
    }
    var registerResult = await _updateProductRequest();
    if (!registerResult) return 500;

    var limit = await _setReservationCountLimit();
    if (!limit) return 500;
    return 200; // 성공 코드
  }

  Future<void> _getCountLimit() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getResvCount.php?pid=${widget.product.prodID}';

    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      var data = json.decode(result);
      setState(() {
        _reservationCountController.text = data['max_count'];
      });
    }
  }

  Future<bool> _setReservationCountLimit() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_resvLimit.php';
    int value = int.parse(_reservationCountController.text) < 0 &&
            int.parse(_reservationCountController.text) != -1
        ? -1
        : int.parse(_reservationCountController.text);
    final response = await http.post(url, body: <String, String>{
      'pid': widget.product.prodID.toString(),
      'max_count': value.toString()
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();

      if (result == 'UPDATE1' || result == 'INSERT1') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _productNameController.text = widget.product.prodName;
    _productExplainController.text = widget.product.prodInfo;
    _productPriceController.text = widget.product.price.toString();
    _productCountController.text = widget.product.stockCount.toString();
    _selectedCategory = _categoryReverseMap[widget.product.category];
    _isBest = widget.product.isBest == 1 ? true : false;
    _isNew = widget.product.isNew == 1 ? true : false;
    _cumulativeSellCount.text = widget.product.cumulBuyCount.toString();
    _productDiscountController.text = widget.product.discount.toString();
    _isReservation = widget.product.isReservation;
    _getCountLimit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context, true),
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
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text('※ Best 메뉴 여부와 New 메뉴 여부는 등록할 상품이 해당되면 체크하세요.'),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text('※ 대표 이미지는 카메라로 즉석에서 찍은 사진, 혹은 갤러리에서 가져와서 사용하면 됩니다.'),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                        '※ 추가 이미지는 필수가 아니며, 필요시 추가할 때는 이미지와 파일이름을 반드시 적어주세요. '),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text('※ "할인율"을 수정할 경우 반드시 .(온점)을 붙여서 소수점 한 자리까지 작성바랍니다.'
                        '\nex) 2.4 , 50.0 \n(형식을 맞추지 않을 시 치명적인 오류가 발생할 수 있습니다.)'),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 2,
                endIndent: 15,
                indent: 15,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: size.width * 0.42,
                    height: size.height * 0.06,
                    child: Text(
                      '*재고가 0일 때 처리',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFF9EE1E5),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  Container(
                    width: size.width * 0.22,
                    child: CheckboxListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          '예약',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        value: _isReservation,
                        onChanged: (value) {
                          setState(() {
                            _isReservation = true;
                          });
                        }),
                  ),
                  Container(
                    width: size.width * 0.22,
                    child: CheckboxListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text('품절',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        value: !_isReservation,
                        onChanged: (value) {
                          setState(() {
                            _isReservation = false;
                          });
                        }),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.015),
                child: Text(
                  '* 재고가 0일 때 처리의 의미는 상품이 팔려서 재고가 0이 되었을 때 "품절"처리 할 것인가 아니면 "예약"을 받을 것인가에 대한 처리를 뜻합니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              _isReservation
                  ? Padding(
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '※ 예약 가능한 최대 수량 설정',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _reservationCountController,
                                  keyboardType: TextInputType.number,
                                ),
                                width: size.width * 0.2,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '* 최대 수량을 -1로 설정할 경우 제한을 정하지 않는다는 뜻입니다.\n (제한 없음 = -1)',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
              Row(
                children: [
                  titleLayoutWidget(
                      title: '할인율(%)', require: false, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.07,
                      controller: _productDiscountController,
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
                  titleLayoutWidget(
                      title: '누적 구매수', require: false, size: size),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  textFieldLayoutWidget(
                      width: size.width * 0.7,
                      height: size.height * 0.07,
                      controller: _cumulativeSellCount,
                      formatType: true,
                      isReadOnly: true,
                      isInteractive: false)
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
                            color: Colors.redAccent,
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
                            Image.network(
                              widget.product.imgUrl1,
                              width: size.width * 0.9,
                              height: size.width * 0.9 * 1.4,
                              fit: BoxFit.cover,
                              errorBuilder: (context, object, tract) {
                                return Text(
                                  '이미지를 불러오는데 실패하였습니다!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                );
                              },
                            ),
                          ],
                        )
                      : _mainImage == null
                          ? imageLoadLayout(size)
                          : Image.file(
                              File(_mainImage.path),
                              fit: BoxFit.cover,
                              width: size.width * 0.9,
                              height: size.width * 0.9 * 1.4,
                            ),
                  SizedBox(
                    height: 10,
                  ),
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
                                fit: BoxFit.cover,
                                width: size.width * 0.9,
                                height: size.width * 0.9 * 1.4,
                              ),
                        SizedBox(
                          height: 10,
                        ),
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
                                fit: BoxFit.cover,
                                width: size.width * 0.9,
                                height: size.width * 0.9 * 1.4,
                              ),
                        SizedBox(
                          height: 10,
                        ),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.black)),
                  width: size.width * 0.85,
                  height: size.height * 0.04,
                  alignment: Alignment.center,
                  child: Text(
                    '이미지 추가하기(최대 2개)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
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
                    '최종 수정하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_productNameController.text.isEmpty) {
                      showErrorDialog('상품명 미입력');
                      return;
                    }
                    if (_productExplainController.text.isEmpty) {
                      showErrorDialog('상품 설명 미입력');
                      return;
                    }
                    if (_productCountController.text.isEmpty) {
                      showErrorDialog('재고 미입력');
                      return;
                    }
                    if (_productPriceController.text.isEmpty) {
                      showErrorDialog('가격 미입력');
                      return;
                    }
                    if (_productDiscountController.text.isNotEmpty) {
                      try {
                        var a = double.parse(_productDiscountController.text);
                      } catch (e) {
                        showErrorDialog('할인율 형식 오류');
                        return;
                      }
                    }
                    if (_useSub1 && _subImage1 == null) {
                      showErrorDialog('추가 이미지1 미설정');
                      return;
                    }
                    if (_useSub2 && _subImage2 == null) {
                      showErrorDialog('추가 이미지2 미설정');
                      return;
                    }
                    if (int.parse(_productCountController.text) < 0) {
                      showErrorDialog('재고가 음수');
                      return;
                    }
                    if (int.parse(_productPriceController.text) < 0) {
                      showErrorDialog('가격이 음수');
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
                    Navigator.pop(context, true);
                  },
                ),
              ),
              SizedBox(
                height: 15,
              )
            ],
          )),
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
      bool formatType = false,
      bool isReadOnly = false,
      bool isInteractive = true}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(3),
      width: width,
      child: TextField(
        style: TextStyle(color: isInteractive ? Colors.black : Colors.grey),
        readOnly: isReadOnly,
        textAlign: TextAlign.center,
        keyboardType: formatType ? TextInputType.number : TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        decoration: InputDecoration(border: InputBorder.none),
        maxLines: null,
        maxLength: maxCharNum,
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
        width: size.width * 0.92,
        height: size.height * 0.6,
        child: Text(
          '이미지를 불러와주세요',
          style: TextStyle(color: Colors.grey[400]),
        ),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(border: Border.all(width: 5, color: Colors.grey)));
  }

  void showErrorDialog(String errorLocation) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('문제 발생'),
              content: Text('입력사항을 재확인 바랍니다.\n[$errorLocation]'),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context), child: Text('확인'))
              ],
            ));
  }
}
