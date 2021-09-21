import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AddingProductPage extends StatefulWidget {
  @override
  _AddingProductPageState createState() => _AddingProductPageState();
}

/// 어드민 전용 페이지
//상품 추가 페이지
//저장할 때 비밀번호로 어드민 DB에서 확인
//직접적으로 추가하는 목록

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

/// * later Additional functions
///나중에 실사용될 때, 상품 등록할 때 어드민 계정으로 비밀번호로 재확인 - resolved

/// 현재 글자수 보여주는 것 - resolved

/// 파일 이름 확장자 통일 - resolved

/// 상품 등록 성공한 화면에서 다시 되돌아오기?

class _AddingProductPageState extends State<AddingProductPage> {
  var _productNameController = TextEditingController();
  var _productPriceController = TextEditingController();
  var _productCountController = TextEditingController();
  var _productExplainController = TextEditingController();

  PickedFile _mainImage;
  PickedFile _subImage1;
  PickedFile _subImage2;

  bool _isBest = false;
  bool _isNew = false;

  bool _useSub1 = false;
  bool _useSub2 = false;

  int _clickCount = 0;
  bool _isNotRegister = true;

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
  final _prefix = {
    '음식류': 'F',
    '간식류': 'S',
    '음료류': 'D',
    '문구류': 'SS',
    '핸드메이드': 'H'
  };
  var _selectedCategory = '음식류'; // 드롭다운 아이템 default
  String serverImageUri =
      'http://nacha01.dothome.co.kr/sin/arlimi_productImage/';

  AsyncMemoizer<bool> _memoizer;

  /// 갤러리에서 이미지를 가져오는 작업
  /// [index] = {0 : main, 1 : sub1, 2 : sub3}
  Future<void> _getImageFromGallery(int index) async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
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

  /// 카메로에서 찍은 이미지를 가져오는 작업
  /// [index] = {0 -> main, 1 -> sub1, 2 -> sub3}
  Future<void> _getImageFromCamera(int index) async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
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

  /// parameter로 가져온 이미지와 이미지 이름을 토대로 서버에 저장하는 요청
  /// @param : 선택한 이미지[img], 그 이미지의 이름[fileName]
  /// @return : 정상적으로 저장했으면 true, 그렇지 않으면 false
  /// @response : complete0
  /// ※ Multipart 요청
  Future<bool> _sendImageToServer(PickedFile img, String fileName) async {
    var request = http.MultipartRequest('POST',
        Uri.parse('http://nacha01.dothome.co.kr/sin/arlimi_storeImage.php'));
    var picture = await http.MultipartFile.fromPath('imgFile', img.path,
        filename: fileName + '.jpg');
    request.files.add(picture);
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      if (responseString.contains('일일 트래픽을 모두 사용하였습니다.')) {
        return false;
      }
      if (responseString != 'complete0') return false;

      return true;
    } else {
      return false;
    }
  }

  /// 상품 등록을 요청하는 작업
  /// 이미지를 먼저 저장하고 그 이미지 URL을 포함해 요청 BODY에 상품 정보 입력
  /// @return 정상적으로 DB에 저장이 되면 true, 그렇지 않으면 false
  /// @response : "1"
  Future<bool> _postRequestForInsertProduct() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_insertProduct.php';
    http.Response response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: <String, String>{
      'prodName': _productNameController.text,
      'prodExp': _productExplainController.text,
      'category': _categoryMap[_selectedCategory].toString(),
      'price': _productPriceController.text,
      'stockCount': _productCountController.text,
      'isBest': _isBest ? '1' : '0',
      'isNew': _isNew ? '1' : '0',
      'imgUrl1': serverImageUri + _mainName + '.jpg',
      'imgUrl2': _useSub1 ? serverImageUri + _sub1Name + '.jpg' : 'None',
      'imgUrl3': _useSub2 ? serverImageUri + _sub2Name + '.jpg' : 'None'
    });
    if (response.statusCode == 200) {
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        return false;
      }
      var replace = response.body.replaceAll(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
          '');
      if (replace.trim() != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  /// 최종적으로 상품을 등록하는 작업
  /// 먼저 대표이미지, 추가 이미지를 서버에 저장 요청
  /// 이를 바탕으로 최종으로 이미지 포함해서 정보와 같이 DB에 저장 요청
  /// @return 모든 작업이 true를 리턴하면 true, 하나라도 false면 false
  /// ※ AsyncMemoizer 를 사용하여 FutureBuilder 의 반복을 방지
  Future<bool> _doRegisterProduct() async {
    return this._memoizer.runOnce(() async {
      var now = DateTime.now();
      String identified = _formatting(now.month) +
          _formatting(now.day) +
          _formatting(now.hour) +
          _formatting(now.minute) +
          _formatting(now.second);

      if (_useSub1) {
        _sub1Name = _prefix[_selectedCategory] + identified + 'A';
        var sub1Result = await _sendImageToServer(_subImage1, _sub1Name);
        if (!sub1Result) return false;
      }
      if (_useSub2) {
        _sub2Name = _prefix[_selectedCategory] + identified + 'B';
        var sub2Result = await _sendImageToServer(
            _subImage2, _prefix[_selectedCategory] + identified + 'B');
        if (!sub2Result) return false;
      }
      _mainName = _prefix[_selectedCategory] + identified;
      var mainResult = await _sendImageToServer(_mainImage, _mainName);
      if (!mainResult) return false;

      var registerResult = await _postRequestForInsertProduct();
      if (!registerResult) return false;
      return true;
    });
  }

  String _formatting(int value) {
    return value > 9 ? value.toString() : '0' + value.toString();
  }

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
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
          '상품 등록하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _isNotRegister
              ? Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '* 표시는 필수 입력 사항',
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
                          Text(
                              '※ 대표 이미지는 카메라로 즉석에서 찍은 사진, 혹은 갤러리에서 가져와서 사용하면 됩니다.'),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Text(
                              '※ 추가 이미지는 필수가 아니며, 필요시 추가할 때는 이미지와 파일이름을 반드시 적어주세요. '),
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
                        titleLayoutWidget(
                            title: '상품명', require: true, size: size),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        textFieldLayoutWidget(
                            width: size.width * 0.7,
                            controller: _productNameController,
                            maxCharNum: 100,
                            maxLine: null)
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
                        titleLayoutWidget(
                            title: '상품 설명', require: true, size: size),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        textFieldLayoutWidget(
                            width: size.width * 0.7,
                            controller: _productExplainController,
                            maxCharNum: 3000,
                            maxLine: 30)
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
                            title: '카테고리', require: true, size: size),
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
                        titleLayoutWidget(
                            title: '가격', require: true, size: size),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        textFieldLayoutWidget(
                            width: size.width * 0.7,
                            // height: size.height * 0.07,
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
                        titleLayoutWidget(
                            title: '재고', require: true, size: size),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        textFieldLayoutWidget(
                            width: size.width * 0.7,
                            // height: size.height * 0.07,
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
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
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
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
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
                                File(_mainImage.path),
                                fit: BoxFit.fill,
                                width: size.width * 0.9,
                                height: size.height * 0.5,
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
                                        border: Border.all(
                                            width: 1, color: Colors.teal),
                                        color: Color(0xFF9EE1E5),
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(3),
                                    width: size.width * 0.2,
                                    child: IconButton(
                                        onPressed: () =>
                                            _getImageFromGallery(1),
                                        icon: Icon(Icons.photo_outlined)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.teal),
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
                                      width: size.width * 0.92,
                                      height: size.height * 0.46,
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
                                        border: Border.all(
                                            width: 1, color: Colors.teal),
                                        color: Color(0xFF9EE1E5),
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(3),
                                    width: size.width * 0.2,
                                    child: IconButton(
                                        onPressed: () =>
                                            _getImageFromGallery(2),
                                        icon: Icon(Icons.photo_outlined)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.teal),
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
                                      width: size.width * 0.92,
                                      height: size.height * 0.6,
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
                    FlatButton(
                      onPressed: _useSub1 && _useSub2
                          ? null
                          : () {
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
                              fontWeight: FontWeight.bold,
                              color: _useSub1 && _useSub2
                                  ? Colors.grey
                                  : Colors.blue),
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
                        onPressed: () {
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
                          if (_mainImage == null) {
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
                          setState(() {
                            _isNotRegister = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    )
                  ],
                )
              : FutureBuilder<bool>(
                  future: _doRegisterProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data) {
                        return Padding(
                          padding: EdgeInsets.all(15),
                          child: Container(
                            width: size.width,
                            height: size.height * 0.8,
                            alignment: Alignment.center,
                            child: Container(
                              width: size.width * 0.85,
                              height: size.height * 0.4,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2, color: Colors.black38),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[300]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '상품등록이 완료되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.06,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.black38),
                                        color: Colors.blueGrey),
                                    width: size.width * 0.45,
                                    height: size.height * 0.06,
                                    child: FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          '이전으로 돌아가기',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            alignment: Alignment.center,
                            width: size.width,
                            height: size.height * 0.8,
                            child: Container(
                              width: size.width * 0.85,
                              height: size.height * 0.5,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    color: Colors.red,
                                    size: size.width * 0.2,
                                  ),
                                  SizedBox(
                                    height: size.height * 0.03,
                                  ),
                                  Text(
                                    '상품 등록에 문제가 발생하였습니다. \n재확인바랍니다.',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: size.height * 0.03,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: size.width * 0.2,
                                        height: size.height * 0.06,
                                        decoration: BoxDecoration(
                                            color: Colors.orange,
                                            border: Border.all(
                                                color: Colors.black, width: 1)),
                                        child: FlatButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('이전')),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.15,
                                      ),
                                      Container(
                                        width: size.width * 0.4,
                                        height: size.height * 0.06,
                                        decoration: BoxDecoration(
                                            color: Colors.orange,
                                            border: Border.all(
                                                color: Colors.black, width: 1)),
                                        child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                _isNotRegister =
                                                    !_isNotRegister;
                                              });
                                            },
                                            child: Text('다시 작성하기')),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      print(snapshot.stackTrace);
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          alignment: Alignment.center,
                          width: size.width,
                          height: size.height * 0.8,
                          child: Container(
                            width: size.width * 0.85,
                            height: size.height * 0.5,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                border:
                                    Border.all(width: 2, color: Colors.black),
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  color: Colors.red,
                                  size: size.width * 0.2,
                                ),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                Text(
                                  '상품 등록에 문제가 발생하였습니다. \n[System Error]',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: size.width * 0.2,
                                      height: size.height * 0.06,
                                      decoration: BoxDecoration(
                                          color: Colors.orange,
                                          border: Border.all(
                                              color: Colors.black, width: 1)),
                                      child: FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('이전')),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.15,
                                    ),
                                    Container(
                                      width: size.width * 0.4,
                                      height: size.height * 0.06,
                                      decoration: BoxDecoration(
                                          color: Colors.orange,
                                          border: Border.all(
                                              color: Colors.black, width: 1)),
                                      child: FlatButton(
                                          onPressed: () {
                                            setState(() {
                                              _isNotRegister = !_isNotRegister;
                                            });
                                          },
                                          child: Text('다시 작성하기')),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                          alignment: Alignment.center,
                          width: size.width,
                          height: size.height,
                          child: Column(
                            children: [
                              Text(
                                '상품을 등록 중입니다...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 21),
                              ),
                              CircularProgressIndicator(),
                            ],
                          ));
                    }
                  }),
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
        maxLines: null,
        maxLength: maxCharNum,
        controller: controller,
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
