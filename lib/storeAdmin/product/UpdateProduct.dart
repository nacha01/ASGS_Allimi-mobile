import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../util/ToastMessage.dart';

List<List<Widget>> _optionDetailList = []; // 선택지 항목 위젯에 대한 2차원 리스트
List<Widget> _optionCategoryList = []; // 옵션 항목 위젯에 대한 리스트
List<List<TextEditingController>> _detailTitleControllerList =
    []; // 선택지 이름 항목에 대한 텍스트 컨트롤러에 대한 2차원 리스트
List<List<TextEditingController>> _detailPriceControllerList =
    []; // 선택지 가격 항목에 대한 텍스트 컨트롤러에 대한 2차원 리스트
List<StreamController<List>> _streamControllerList =
    []; // 선택지 리스트의 변화를 감지해 위젯으로 보여주도록 하는 Stream 리스트
List<TextEditingController> _optionCategoryControllerList =
    []; // 옵션 항목에 대한 제목 텍스트 컨트롤러 리스트
List<List<DetailWidget>> _classList = []; // 리스트의 인덱스와 위젯이 담겨있는 클래스를 담는 2차원 리스트

class UpdatingProductPage extends StatefulWidget {
  UpdatingProductPage({this.product});

  final Product? product;

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
  List _initOptionList = [];
  List<XFile?> _images = [null, null, null];
  List<String> _imageNames = ['', '', ''];

  bool? _isBest = false;
  bool? _isNew = false;
  bool _isReservation = false;
  bool _useOptions = false;
  bool _imageInitial = true;

  bool _useSub1 = false;
  bool _useSub2 = false;

  int _index = 0;
  int _clickCount = 0;

  Category? _selectedCategory = Categories.categories[0]; // 드롭다운 아이템 default
  String serverImageUri =
      '${ApiUtil.API_HOST}arlimi_productImage/'; // 이미지 저장 서버 URI

  /// 이미지를 가져오는 작업
  /// [index] = {0 : main, 1 : sub1, 2 : sub3}
  /// [useGallery] = {true: 갤러리, false: 카메라}
  Future<void> _getImage(int index, {bool useGallery = true}) async {
    var image = await ImagePicker().pickImage(
        source: useGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 50);
    setState(() {
      _images[index] = image;
    });
  }

  /// 최종 요청하기 전 수정하고자 하는 이미지를 서버에 업데이트 요청을 하는 작업
  Future<bool> _updateImageBeforeRequest(
      XFile img, String fileName, String? originName) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiUtil.API_HOST}arlimi_addImgForUpdate.php'));
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
    String url = '${ApiUtil.API_HOST}arlimi_updateProduct.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'prodID': widget.product!.prodID.toString(),
      'prodName': _productNameController.text,
      'prodInfo': _productExplainController.text,
      'category': _selectedCategory!.id.toString(),
      'price': _productPriceController.text,
      'stockCount': _productCountController.text,
      'discount': _productDiscountController.text,
      'isBest': _isBest! ? '1' : '0',
      'isNew': _isNew! ? '1' : '0',
      'img1':
          _images[0] == null ? 'NOT' : serverImageUri + _imageNames[0] + '.jpg',
      'img2': _useSub1 ? serverImageUri + _imageNames[1] + '.jpg' : 'None',
      'img3': _useSub2 ? serverImageUri + _imageNames[2] + '.jpg' : 'None',
      'empty': _isReservation ? '1' : '0'
    });

    if (response.statusCode == 200) {
      var replace = ApiUtil.getPureBody(response.bodyBytes);
      if (replace.trim() != '1') {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _setReservationCountLimit() async {
    String url = '${ApiUtil.API_HOST}arlimi_resvLimit.php';
    int value = int.parse(_reservationCountController.text) < 0 &&
            int.parse(_reservationCountController.text) != -1
        ? -1
        : int.parse(_reservationCountController.text);
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'pid': widget.product!.prodID.toString(),
      'max_count': value.toString()
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);

      if (result == 'UPDATE1' || result == 'INSERT1') {
        return true;
      }
    }
    return false;
  }

  /// 상품 수정을 위한 과정 process 함수
  /// 이미지 업데이트, 상품 변경 내용 업데이트
  Future<int> _doUpdateForProduct() async {
    if (_useSub1) {
      _imageNames[1] = _getFileNameByRule(widget.product!.imgUrl2!
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));

      var sub1Result = await _updateImageBeforeRequest(
          _images[1]!, _imageNames[1], widget.product!.imgUrl2);

      if (!sub1Result) return 402;
    }
    if (_useSub2) {
      _imageNames[2] = _getFileNameByRule(widget.product!.imgUrl3!
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));

      var sub2Result = await _updateImageBeforeRequest(
          _images[2]!, _imageNames[2], widget.product!.imgUrl3);

      if (!sub2Result) return 403;
    }
    if (_images[0] != null) {
      _imageNames[0] = _getFileNameByRule(widget.product!.imgUrl1!
          .replaceAll(serverImageUri, '')
          .replaceAll('.jpg', ''));
      var mainResult = await _updateImageBeforeRequest(
          _images[0]!, _imageNames[0], widget.product!.imgUrl1);
      if (!mainResult) return 401;
    }
    var registerResult = await _updateProductRequest();
    if (!registerResult) return 500;

    var optionResult = await _addOptionCategory();
    if (!optionResult) return 500;

    var limit = await _setReservationCountLimit();
    if (!limit) return 500;

    return 200; // 성공 코드
  }

  Future<bool> _deleteAllOptions() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_deleteProductOptions.php?pid=${widget.product!.prodID}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _getCountLimit() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getResvCount.php?pid=${widget.product!.prodID}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      var data = json.decode(result);
      setState(() {
        _reservationCountController.text = data['max_count'];
      });
    }
  }

  Future<void> _getAllOptions() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getProductOptions.php?pid=${widget.product!.prodID}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('NO OPTION')) {
        _useOptions = false;
      } else {
        List map1st = json.decode(result);
        for (int i = 0; i < map1st.length; ++i) {
          map1st[i] = json.decode(map1st[i]);
          for (int j = 0; j < map1st[i]['detail'].length; ++j) {
            map1st[i]['detail'][j] = jsonDecode(map1st[i]['detail'][j]);
          }
        }
        _initOptionList = map1st;
        setState(() {
          _useOptions = true;
        });
        _initialOptionSetting();
      }
    }
  }

  void _initialOptionSetting() async {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < _initOptionList.length; ++i) {
      _optionDetailList.add([]);
      _detailTitleControllerList.add([]);
      _detailPriceControllerList.add([]);
      _classList.add([]);
      _optionCategoryControllerList.add(TextEditingController());
      _optionCategoryControllerList.last.text =
          _initOptionList[i]['optionCategory'];
      _streamControllerList.add(StreamController.broadcast());
      _optionCategoryList.add(_optionCategoryLayout(size, _index++));
      for (int j = 0; j < _initOptionList[i]['detail'].length; ++j) {
        _detailPriceControllerList[i]
            .add(TextEditingController()); // index 에 해당하는 옵션에 가격 컨트롤러 하나를 추가한다.
        _detailPriceControllerList[i].last.text =
            _initOptionList[i]['detail'][j]['optionPrice'];
        _detailTitleControllerList[i]
            .add(TextEditingController()); // index 에 해당하는 옵션에 이름 컨트롤러 하나를 추가한다.
        _detailTitleControllerList[i].last.text =
            _initOptionList[i]['detail'][j]['optionName'];
        setState(() {
          _classList[i].add(DetailWidget(_detailPriceControllerList[i].length -
              1)); // 리스트 마지막에 동적 인덱스를 갖는 선택지 객체를 추가한다.
        });
        _optionDetailList[i].add(_classList[i].last.optionDetailLayout(
            size, i)); // 선택지 객체의 위젯을 _optionDetailList 에 추가한다.
      }
      await Future.delayed(Duration(milliseconds: 50));
      // 바로바로 스트림에 데이터를 전달하면 반응을 못하나... 그래서 나름의 딜레이를 주도록 한다.
      _streamControllerList[i].sink.add(_optionDetailList[i]);
    }
  }

  Future<int> _registerOptionCategory(String optionCategory) async {
    String url = '${ApiUtil.API_HOST}arlimi_registerOptionCategory.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'pName': _productNameController.text,
      'pInfo': _productExplainController.text,
      'category': _selectedCategory!.id.toString(),
      'price': _productPriceController.text,
      'optionCategory': optionCategory
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      return int.parse(result);
    } else {
      return -1;
    }
  }

  Future<bool> _registerOptionDetail(
      String optionCategory, String optionName, String optionPrice) async {
    String url = '${ApiUtil.API_HOST}arlimi_registerOptionDetail.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'pid': widget.product!.prodID.toString(),
      'optionCategory': optionCategory,
      'optionName': optionName,
      'optionPrice': optionPrice
    });
    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result == '1') return true;
    }
    return false;
  }

  Future<bool> _addOptionCategory() async {
    var deleteResult = await _deleteAllOptions();
    if (deleteResult) {
      try {
        for (int i = 0; i < _optionCategoryControllerList.length; ++i) {
          var pid = await _registerOptionCategory(
              _optionCategoryControllerList[i].text);
          for (int j = 0; j < _optionDetailList[i].length; ++j) {
            var res = await _registerOptionDetail(
                _optionCategoryControllerList[i].text,
                _detailTitleControllerList[i][j].text,
                _detailPriceControllerList[i][j].text);
          }
        }
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _productNameController.text = widget.product!.prodName!;
    _productExplainController.text = widget.product!.prodInfo!;
    _productPriceController.text = widget.product!.price.toString();
    _productCountController.text = widget.product!.stockCount.toString();
    _selectedCategory = Categories.categories[widget.product!.category];
    _isBest = widget.product!.isBest == 1 ? true : false;
    _isNew = widget.product!.isNew == 1 ? true : false;
    _cumulativeSellCount.text = widget.product!.cumulBuyCount.toString();
    _productDiscountController.text = widget.product!.discount.toString();
    _isReservation = widget.product!.isReservation;
    _getCountLimit();
    _getAllOptions();
    super.initState();
  }

  @override
  void dispose() {
    _optionDetailList.clear();
    _optionCategoryList.clear();
    _detailPriceControllerList.clear();
    _detailTitleControllerList.clear();
    _streamControllerList.clear();
    _optionCategoryControllerList.clear();
    _classList.clear();
    // 전역변수는 페이지가 dispose 되어도 사라지지 않는 듯 하다.
    // 다시 이 페이지로 들어올 때 위의 리스트들이 계속 존재함
    // 그래서 페이지 종료될 때 강제로 아이템을 모두 지우도록 한다.
    super.dispose();
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
        appBar: ThemeAppBar(
            barTitle: '상품 수정하기',
            leadingClick: () => Navigator.pop(context, true)),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
            children: [
              _spaceBox(size),
              Text(
                '*표시는 필수 입력 사항',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Column(
                  children: [
                    _spaceBox(size),
                    Text('※ Best 메뉴 여부와 New 메뉴 여부는 등록할 상품이 해당되면 체크하세요.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    _spaceBox(size),
                    Text('※ 대표 이미지는 카메라로 즉석에서 찍은 사진, 혹은 갤러리에서 가져와서 사용하면 됩니다.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    _spaceBox(size),
                    Text('※ 추가 이미지는 필수가 아니며, 필요시 추가할 때는 이미지를 반드시 추가해주세요. ',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    _spaceBox(size),
                    Text(
                        '※ "할인율"을 수정할 경우 반드시 .(온점)을 붙여서 소수점 한 자리까지 작성바랍니다.'
                        '\nex) 2.4 , 50.0',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    _spaceBox(size),
                  ],
                ),
              ),
              _normalDivider(size),
              _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
                      items: Categories.categories.map((value) {
                        return DropdownMenuItem(
                          child: Center(child: Text(value.name)),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: size.width * 0.32,
                    height: size.height * 0.06,
                    child: Text(
                      'Best 메뉴 여부',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    width: size.width * 0.32,
                    height: size.height * 0.06,
                    child: Text(
                      'New 메뉴 여부',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                  '* "재고가 0일 때 처리"의 의미는 상품이 팔려서 재고가 0이 되었을 때 "품절"처리 할 것인가 아니면 "예약"을 받을 것인가에 대한 처리를 뜻합니다.',
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
                          _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _useOptions = !_useOptions;
                    if (!_useOptions) {
                      _optionDetailList.clear();
                      _optionCategoryList.clear();
                      _detailPriceControllerList.clear();
                      _detailTitleControllerList.clear();
                      _streamControllerList.clear();
                      _optionCategoryControllerList.clear();
                      _classList.clear();
                      _index = 0;
                    }
                  });
                },
                child: Container(
                  width: size.width * 0.5,
                  height: size.height * 0.05,
                  alignment: Alignment.center,
                  child: Text(
                    _useOptions ? '상품 옵션 삭제하기' : '상품 옵션 추가하기',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xFF9161E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black)),
                ),
              ),
              _spaceBox(size),
              _useOptions
                  ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.02),
                          child: Text(
                            '* 옵션 전체를 지울 경우에는 마지막으로 추가한 옵션부터 삭제 가능합니다',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _optionDivider(size),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _optionCategoryList,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DefaultButtonComp(
                                onPressed: () {
                                  _optionDetailList.add([]);
                                  _detailTitleControllerList.add([]);
                                  _detailPriceControllerList.add([]);
                                  _classList.add([]);
                                  _optionCategoryControllerList
                                      .add(TextEditingController());
                                  _streamControllerList
                                      .add(StreamController.broadcast());
                                  _optionCategoryList.add(
                                      _optionCategoryLayout(size, _index++));
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * 0.01,
                                      horizontal: size.width * 0.03),
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        ' 옵션 추가',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        _normalDivider(size),
                      ],
                    )
                  : _normalDivider(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
              _spaceBox(size),
              _normalDivider(size),
              _spaceBox(size),
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
                  _spaceBox(size),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.2,
                        child: IconButton(
                            onPressed: () => _getImage(0, useGallery: false),
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
                            onPressed: () => _getImage(0),
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
                  _spaceBox(size),
                  _imageInitial
                      ? Column(
                          children: [
                            Image.network(
                              widget.product!.imgUrl1!,
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
                      : _images[0] == null
                          ? imageLoadLayout(size)
                          : _imageFile(size, _images[0]!.path),
                  _spaceBox(size),
                ],
              ),
              _spaceBox(size),
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
                                  _images[1] = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                              color: Colors.red,
                            )
                          ],
                        ),
                        _spaceBox(size),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () =>
                                      _getImage(1, useGallery: false),
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
                                  onPressed: () => _getImage(1),
                                  icon: Icon(Icons.photo_outlined)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            )
                          ],
                        ),
                        _images[1] == null
                            ? imageLoadLayout(size)
                            : _imageFile(size, _images[1]!.path),
                        _spaceBox(size),
                      ],
                    )
                  : SizedBox(),
              /* ---------------------------------------------------- */
              _useSub2
                  ? Column(
                      children: [
                        _spaceBox(size),
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
                                  _images[2] = null;
                                });
                              },
                              icon: Icon(Icons.cancel),
                              color: Colors.red,
                            )
                          ],
                        ),
                        _spaceBox(size),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(3),
                              width: size.width * 0.2,
                              child: IconButton(
                                  onPressed: () =>
                                      _getImage(2, useGallery: false),
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
                                  onPressed: () => _getImage(2),
                                  icon: Icon(Icons.photo_outlined)),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.teal),
                                  color: Color(0xFF9EE1E5),
                                  borderRadius: BorderRadius.circular(5)),
                            )
                          ],
                        ),
                        _images[2] == null
                            ? imageLoadLayout(size)
                            : _imageFile(size, _images[2]!.path),
                        _spaceBox(size)
                      ],
                    )
                  : SizedBox(),
              _spaceBox(size),
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
              _spaceBox(size),
              Container(
                width: size.width * 0.5,
                decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    border: Border.all(width: 1, color: Colors.indigo),
                    borderRadius: BorderRadius.circular(12)),
                child: DefaultButtonComp(
                  child: Text(
                    '최종 수정하기',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black),
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
                    if (_useSub1 && _images[1] == null) {
                      showErrorDialog('추가 이미지1 미설정');
                      return;
                    }
                    if (_useSub2 && _images[2] == null) {
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
                    late String message;
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
                    ToastMessage.show(message);

                    Navigator.pop(context, true);
                  },
                ),
              ),
              _spaceBox(size)
            ],
          )),
        ),
      ),
    );
  }

  Widget textFieldLayoutWidget(
      {double? height,
      double? width,
      TextEditingController? controller,
      int? maxCharNum,
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
      {required String title, required bool require, required Size size}) {
    return Container(
      margin: EdgeInsets.all(5),
      alignment: Alignment.center,
      width: size.width * 0.23,
      height: size.height * 0.06,
      child: Text(
        require ? '*' + title : title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                DefaultButtonComp(
                    onPressed: () => Navigator.pop(context), child: Text('확인'))
              ],
            ));
  }

  Widget _optionCategoryLayout(Size size, int index) {
    return Column(
      children: [
        Container(
          width: size.width * 0.94,
          height: size.height * 0.05,
          padding: EdgeInsets.all(size.width * 0.02),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(6)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_optionCategoryControllerList.length - 1 == index) {
                    // 선택한 인덱스가 마지막으로 추가한 인덱스인가?
                    if (index > 0 && index >= _optionCategoryList.length - 1) {
                      index = _optionCategoryList.length - 1;
                    }
                    setState(() {
                      _optionCategoryControllerList[index].removeListener(
                          () {}); // index 에 해당하는 제목 컨트롤러의 연결을 끊는다.
                      _optionCategoryControllerList
                          .removeAt(index); // index 에 해당하는 제목 컨트롤러 공간을 지운다.
                      _optionCategoryList
                          .removeAt(index); // index 에 해당하는 실제 옵션 위젯을 지운다.

                      for (int i = 0;
                          i < _optionDetailList[index].length;
                          ++i) {
                        _detailTitleControllerList[index][i]
                            .removeListener(() {});
                        _detailPriceControllerList[index][i]
                            .removeListener(() {});
                      }
                      // 특정 옵션에 대해 모든 선택지에 대한 가격, 이름 컨트롤러의 연결을 끊는다.

                      _optionDetailList[index]
                          .clear(); // index 에 해당하는 옵션 리스트의 모든 선택지를 지운다.
                      _detailTitleControllerList[index]
                          .clear(); // index 에 해당하는 옵션 리스트의 제목 컨트롤러를 모두 비운다.
                      _detailPriceControllerList[index]
                          .clear(); // index 에 해당하는 옵션 리스트의 가격 컨트롤러를 모두 비운다.
                      _optionDetailList
                          .removeAt(index); // index 에 해당하는 실제 옵션 위젯을 지운다.
                      _detailTitleControllerList.removeAt(
                          index); // index 에 해당하는 옵션 리스트의 제목 컨트롤러의 공간을 지운다.
                      _detailPriceControllerList.removeAt(
                          index); // index 에 해당하는 옵션 리스트의 가격 컨트롤러의 공간을 지운다.
                      _classList.removeAt(
                          index); // index 에 해당하는 옵션 리스트의 동적 인덱스를 갖는 선택지 객체를 지운다.
                      _index--; // 옵션 리스트의 index 를 하나 줄인다. (옵션 리스트의 동적 인덱스 역할)
                    });
                    late StreamSubscription sub;
                    sub = _streamControllerList[index].stream.listen((event) {
                      sub.cancel(); // index 에 해당하는 옵션 리스트의 연결되어 있는 스트림 통로를 끊는다.
                    });
                    _streamControllerList
                        .removeAt(index); // index 에 해당하는 옵션 리스트의 스트림 객체를 지운다.
                  } else {
                    ToastMessage.show('마지막으로 추가한 옵션이 아닙니다.');
                  }
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.deepOrange,
                ),
                padding: EdgeInsets.all(0),
              ),
              Text(
                '옵션 이름 /',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                width: size.width * 0.5,
                child: TextField(
                  controller: _optionCategoryControllerList[index],
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<List>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: snapshot.data as List<Widget>,
              );
            } else {
              return SizedBox(
                height: size.height * 0.008,
              );
            }
          },
          stream: _streamControllerList[index].stream,
        ),
        Row(
          children: [
            DefaultButtonComp(
                onPressed: () {
                  _detailPriceControllerList[index].add(
                      TextEditingController()); // index 에 해당하는 옵션에 가격 컨트롤러 하나를 추가한다.
                  _detailTitleControllerList[index].add(
                      TextEditingController()); // index 에 해당하는 옵션에 이름 컨트롤러 하나를 추가한다.

                  setState(() {
                    _classList[index].add(DetailWidget(
                        _detailPriceControllerList[index].length -
                            1)); // 리스트 마지막에 동적 인덱스를 갖는 선택지 객체를 추가한다.
                  });
                  _optionDetailList[index].add(_classList[index]
                      .last
                      .optionDetailLayout(size,
                          index)); // 선택지 객체의 위젯을 _optionDetailList 에 추가한다.

                  _streamControllerList[index].add(_optionDetailList[
                      index]); // _optionDetailList[index]의 변화를 Stream 이 듣도록 추가한다.
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.width * 0.01),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: Colors.black),
                      color: Color(0xFF91EFAA)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      Text(
                        ' 선택지 추가',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )),
          ],
        ),
        _optionDivider(size)
      ],
    );
  }

  Widget _optionDivider(Size size) {
    return Divider(
        thickness: 1.5,
        indent: size.width * 0.02,
        endIndent: size.width * 0.02,
        color: Colors.deepOrange);
  }

  Widget _normalDivider(Size size) {
    return Divider(
      thickness: 2,
      endIndent: size.width * 0.03,
      indent: size.width * 0.03,
    );
  }

  Widget _spaceBox(Size size) {
    return SizedBox(height: size.width * 0.02);
  }

  Widget _imageFile(Size size, String path) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: size.width * 0.9,
      height: size.width * 0.9 * 1.4,
    );
  }
}

/// 기존 방식은 optionDetailLayout() 함수가 멤버메소드로 존재했었는데
/// 이 방식을 사용하면 parameter 로 넘겨주는 dIndex 값이 항상 고정이 되어있다. (dIndex 값은 한 옵션에서 여러 선택지 중 현재 위치한 인덱스를 의미)
/// 하지만 자유자재로 원하는 인덱스에 해당하는 항목을 지우게 되면 dIndex 값도 그에 따라 변화해야 한다.
/// → 지우려고 하는 인덱스의 다음 요소들 전부가 인덱스 값이 하나씩 줄어야 한다.
/// 그렇지만 dIndex의 값이 고정되어 있기 때문에 그에 맞춰줘서 동적으로 dIndex 의 값을 바꿔야만 했었다.
/// 하지만 다양한 방법을 시도했지만 실패했다.
/// 결국에는 고정된 dIndex 값을(상수화된) 유동적으로 사용할 수 있도록(변수화된) 값으로 바꿔줘야 한다.
/// 즉, 어디서든 dIndex 값을 해당 범위내에서 바꾸는 것이 가능하도록 해야하는 것이다.
/// 그렇게 하기 위해서는 선택지에 해당하는 위젯과 dIndex 값이 동시에 갖고 있어야 하는데
/// 이를 위해서 하나의 Class 를 만들어주도록 한다.
/// 이러면 객체화 했을 때, 특정 인덱스가 삭제되면 변화해야할 나머지 선택지 객체의 멤버인 dIndex 로 접근해 값을 바꿀 수가 있게 되는 것이다.
/// 추가로, 기존에 Widget Class 의 멤버로 있던 옵션 관련 리스트들을 전역 변수로 설정한다.
/// 그래서 새로 생성한 Class 에서도 접근 가능하도록 한다.
/// 그리고 이 클래스를 각 옵션에 대해서 사용하기 위해 2차원 리스트로 사용한다. List<List<Class>>
class DetailWidget {
  int dIndex;

  DetailWidget(this.dIndex);

  Widget optionDetailLayout(Size size, int cIndex) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                for (int i = dIndex + 1; i < _classList[cIndex].length; ++i) {
                  _classList[cIndex][i].dIndex -= 1;
                }
                // 현재 지우고자 하는 인덱스의 다음 모든 인덱스의 dIndex 값을 한자리 땡긴다.

                _classList[cIndex]
                    .removeAt(dIndex); // dIndex 에 해당하는 동적 인덱스를 갖는 선택지 객체를 지운다.

                _optionDetailList[cIndex]
                    .removeAt(dIndex); // dIndex 에 해당하는 실제 선택지 위젯을 지운다.

                _detailPriceControllerList[cIndex][dIndex].removeListener(
                    () {}); // 특정 옵션(cIndex 에 위치한)에 대한 dIndex 에 해당하는 가격 텍스트 컨트롤러의 연결을 끊는다.
                _detailTitleControllerList[cIndex][dIndex].removeListener(
                    () {}); // 특정 옵션(cIndex 에 위치한)에 대한 dIndex 에 해당하는 이름 텍스트 컨트롤러의 연결을 끊는다.

                _detailPriceControllerList[cIndex].removeAt(
                    dIndex); // 특정 옵션(cIndex 에 위치한) 가격 컨트롤러 리스트에서 dIndex 에 위치한 공간을 지운다.
                _detailTitleControllerList[cIndex].removeAt(
                    dIndex); // 특정 옵션(cIndex 에 위치한) 이름 컨트롤러 리스트에서 dIndex 에 위치한 공간을 지운다.

                _streamControllerList[cIndex].add(_optionDetailList[
                    cIndex]); // _optionDetailList[cIndex]의 변화를 스트림이 듣도록 추가한다.
              },
              icon: Icon(
                Icons.remove_circle,
                color: Colors.red,
              )),
          Text(
            '* 선택지 이름',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Container(
            width: size.width * 0.3,
            child: TextField(
              controller: _detailTitleControllerList[cIndex][dIndex],
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            ' / ',
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          Text('가격',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Container(
            width: size.width * 0.2,
            child: TextField(
              controller: _detailPriceControllerList[cIndex][dIndex],
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(signed: true),
            ),
          )
        ],
      ),
    );
  }
}
