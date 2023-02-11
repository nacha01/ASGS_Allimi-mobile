import 'dart:convert';
import 'package:asgshighschool/component/CorporationComp.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/DetailProductPage.dart';
import 'package:asgshighschool/store/EventPage.dart';
import '../component/DefaultButtonComp.dart';
import '../storeAdmin/product/AddProduct.dart';
import '../storeAdmin/product/UpdateProduct.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class StoreHomePage extends StatefulWidget {
  StoreHomePage({this.user, this.product, this.existCart});

  final User? user;
  final List<Product>? product;
  final bool? existCart;

  @override
  _StoreHomePageState createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage>
    with TickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _adminKeyController = TextEditingController();
  TabController? _tabController;
  ScrollController? _scrollViewController;
  int _selectedCategory = 0; // MENU 탭에서 어느 카테고리인지에 대한 값
  int? _selectRadio = 0; // 정렬 기준 선택 라디오 버튼 값
  List _sortTitleList = ['등록순', '이름순', '가격순']; // 정렬 기준 라디오 버튼 title 리스트
  bool _isAsc = true; // true : 오름차순 , false : 내림차순
  bool _isSearch = false; // 검색 기능 사용했는지 판단
  bool _isLoading = true; // 상품 데이터 가져오는 동안의 로딩 상태
  bool _corporationInfoClicked = false;

  List<Product> _searchProductList = [];
  List<Widget> _searchProductLayoutList = [];

  List<Product> _productList = [];
  List<Widget> _productLayoutList = [];

  List<Product> _newProductList = [];
  List<Widget> _newProductLayoutList = [];

  List<Product> _bestProductList = [];
  List<Widget> _bestProductLayoutList = [];

  List<Product> _foodProductList = [];
  List<Widget> _foodProductLayoutList = [];

  List<Product> _snackProductList = [];
  List<Widget> _snackProductLayoutList = [];

  List<Product> _beverageProductList = [];
  List<Widget> _beverageProductLayoutList = [];

  List<Product> _stationeryProductList = [];
  List<Widget> _stationeryProductLayoutList = [];

  List<Product> _handmadeProductList = [];
  List<Widget> _handmadeProductLayoutList = [];

  /// 전체 상품을 카테고리 별 상품, 베스트 상품, 신규 상품 별로 각 List 에 분류
  void _groupingProduct(Size size) {
    for (int i = 0; i < _productList.length; ++i) {
      if (_productList[i].isBest == 1 && _productList[i].isNew == 1) {
        _bestProductList.add(_productList[i]);
        _newProductList.add(_productList[i]);
      } else if (_productList[i].isBest == 1) {
        _bestProductList.add(_productList[i]);
      } else if (_productList[i].isNew == 1) {
        _newProductList.add(_productList[i]);
      }
      switch (_productList[i].category) {
        case 0: // 음식류
          _foodProductList.add(_productList[i]);
          break;
        case 1: // 간식류
          _snackProductList.add(_productList[i]);
          break;
        case 2: // 음료류
          _beverageProductList.add(_productList[i]);
          break;
        case 3: // 문구류
          _stationeryProductList.add(_productList[i]);
          break;
        case 4: // 핸드메이드
          _handmadeProductList.add(_productList[i]);
          break;
      }
    }
    getBestProdLayout(size);
    getNewProdLayout(size);
    getFoodProdLayout(size);
    getSnackProdLayout(size);
    getBeverageProdLayout(size);
    getStationeryProdLayout(size);
    getHandmadeProdLayout(size);
  }

  /// 모든 각 상품 리스트를 method 에 따라 정렬시키는 작업
  /// @param : 정렬 기준 정수 값
  /// 0 : 등록순 - prodID 필드 기준으로 정렬
  /// 1 : 이름순 - prodName 필드 기준으로 정렬
  /// 2 : 가격순 - price 필드 기준으로 정렬
  void _sortProductByIndex(int? sortMethod, Size size) {
    switch (sortMethod) {
      case 0:
        _productList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _productLayoutList.clear();
        if (!_isAsc) _productList = List.from(_productList.reversed);
        for (int i = 0; i < _productList.length; ++i) {
          _productLayoutList.add(itemTile(
              _productList[i].imgUrl1!,
              _productList[i].price,
              _productList[i].prodName!,
              false,
              _productList[i],
              size));
        }
        _foodProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _foodProductLayoutList.clear();
        if (!_isAsc) _foodProductList = List.from(_foodProductList.reversed);
        for (int i = 0; i < _foodProductList.length; ++i) {
          _foodProductLayoutList.add(itemTile(
              _foodProductList[i].imgUrl1!,
              _foodProductList[i].price,
              _foodProductList[i].prodName!,
              false,
              _foodProductList[i],
              size));
        }
        _snackProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _snackProductLayoutList.clear();
        if (!_isAsc) _snackProductList = List.from(_snackProductList.reversed);
        for (int i = 0; i < _snackProductList.length; ++i) {
          _snackProductLayoutList.add(itemTile(
              _snackProductList[i].imgUrl1!,
              _snackProductList[i].price,
              _snackProductList[i].prodName!,
              false,
              _snackProductList[i],
              size));
        }
        _beverageProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _beverageProductLayoutList.clear();
        if (!_isAsc)
          _beverageProductList = List.from(_beverageProductList.reversed);
        for (int i = 0; i < _beverageProductList.length; ++i) {
          _beverageProductLayoutList.add(itemTile(
              _beverageProductList[i].imgUrl1!,
              _beverageProductList[i].price,
              _beverageProductList[i].prodName!,
              false,
              _beverageProductList[i],
              size));
        }
        _stationeryProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _stationeryProductLayoutList.clear();
        if (!_isAsc)
          _stationeryProductList = List.from(_stationeryProductList.reversed);
        for (int i = 0; i < _stationeryProductList.length; ++i) {
          _stationeryProductLayoutList.add(itemTile(
              _stationeryProductList[i].imgUrl1!,
              _stationeryProductList[i].price,
              _stationeryProductList[i].prodName!,
              false,
              _stationeryProductList[i],
              size));
        }
        _handmadeProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _handmadeProductLayoutList.clear();
        if (!_isAsc)
          _handmadeProductList = List.from(_handmadeProductList.reversed);
        for (int i = 0; i < _handmadeProductList.length; ++i) {
          _handmadeProductLayoutList.add(itemTile(
              _handmadeProductList[i].imgUrl1!,
              _handmadeProductList[i].price,
              _handmadeProductList[i].prodName!,
              false,
              _handmadeProductList[i],
              size));
        }
        _bestProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _bestProductLayoutList.clear();
        if (!_isAsc) _bestProductList = List.from(_bestProductList.reversed);
        for (int i = 0; i < _bestProductList.length; ++i) {
          _bestProductLayoutList.add(itemTile(
              _bestProductList[i].imgUrl1!,
              _bestProductList[i].price,
              _bestProductList[i].prodName!,
              false,
              _bestProductList[i],
              size));
        }

        _newProductList.sort((a, b) => a.prodID.compareTo(b.prodID));
        _newProductLayoutList.clear();
        if (!_isAsc) _newProductList = List.from(_newProductList.reversed);
        for (int i = 0; i < _newProductList.length; ++i) {
          _newProductLayoutList.add(itemTile(
              _newProductList[i].imgUrl1!,
              _newProductList[i].price,
              _newProductList[i].prodName!,
              false,
              _newProductList[i],
              size));
        }
        break;
      case 1:
        _productList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _productLayoutList.clear();
        if (!_isAsc) _productList = List.from(_productList.reversed);
        for (int i = 0; i < _productList.length; ++i) {
          _productLayoutList.add(itemTile(
              _productList[i].imgUrl1!,
              _productList[i].price,
              _productList[i].prodName!,
              false,
              _productList[i],
              size));
        }
        _foodProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _foodProductLayoutList.clear();
        if (!_isAsc) _foodProductList = List.from(_foodProductList.reversed);
        for (int i = 0; i < _foodProductList.length; ++i) {
          _foodProductLayoutList.add(itemTile(
              _foodProductList[i].imgUrl1!,
              _foodProductList[i].price,
              _foodProductList[i].prodName!,
              false,
              _foodProductList[i],
              size));
        }
        _snackProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _snackProductLayoutList.clear();
        if (!_isAsc) _snackProductList = List.from(_snackProductList.reversed);
        for (int i = 0; i < _snackProductList.length; ++i) {
          _snackProductLayoutList.add(itemTile(
              _snackProductList[i].imgUrl1!,
              _snackProductList[i].price,
              _snackProductList[i].prodName!,
              false,
              _snackProductList[i],
              size));
        }
        _beverageProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _beverageProductLayoutList.clear();
        if (!_isAsc)
          _beverageProductList = List.from(_beverageProductList.reversed);
        for (int i = 0; i < _beverageProductList.length; ++i) {
          _beverageProductLayoutList.add(itemTile(
              _beverageProductList[i].imgUrl1!,
              _beverageProductList[i].price,
              _beverageProductList[i].prodName!,
              false,
              _beverageProductList[i],
              size));
        }
        _stationeryProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _stationeryProductLayoutList.clear();
        if (!_isAsc)
          _stationeryProductList = List.from(_stationeryProductList.reversed);
        for (int i = 0; i < _stationeryProductList.length; ++i) {
          _stationeryProductLayoutList.add(itemTile(
              _stationeryProductList[i].imgUrl1!,
              _stationeryProductList[i].price,
              _stationeryProductList[i].prodName!,
              false,
              _stationeryProductList[i],
              size));
        }
        _handmadeProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _handmadeProductLayoutList.clear();
        if (!_isAsc)
          _handmadeProductList = List.from(_handmadeProductList.reversed);
        for (int i = 0; i < _handmadeProductList.length; ++i) {
          _handmadeProductLayoutList.add(itemTile(
              _handmadeProductList[i].imgUrl1!,
              _handmadeProductList[i].price,
              _handmadeProductList[i].prodName!,
              false,
              _handmadeProductList[i],
              size));
        }
        _bestProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _bestProductLayoutList.clear();
        if (!_isAsc) _bestProductList = List.from(_bestProductList.reversed);
        for (int i = 0; i < _bestProductList.length; ++i) {
          _bestProductLayoutList.add(itemTile(
              _bestProductList[i].imgUrl1!,
              _bestProductList[i].price,
              _bestProductList[i].prodName!,
              false,
              _bestProductList[i],
              size));
        }

        _newProductList.sort((a, b) => a.prodName!.compareTo(b.prodName!));
        _newProductLayoutList.clear();
        if (!_isAsc) _newProductList = List.from(_newProductList.reversed);
        for (int i = 0; i < _newProductList.length; ++i) {
          _newProductLayoutList.add(itemTile(
              _newProductList[i].imgUrl1!,
              _newProductList[i].price,
              _newProductList[i].prodName!,
              false,
              _newProductList[i],
              size));
        }
        break;
      case 2:
        _productList.sort((a, b) => a.price.compareTo(b.price));
        _productLayoutList.clear();
        if (!_isAsc) _productList = List.from(_productList.reversed);
        for (int i = 0; i < _productList.length; ++i) {
          _productLayoutList.add(itemTile(
              _productList[i].imgUrl1!,
              _productList[i].price,
              _productList[i].prodName!,
              false,
              _productList[i],
              size));
        }
        _foodProductList.sort((a, b) => a.price.compareTo(b.price));
        _foodProductLayoutList.clear();
        if (!_isAsc) _foodProductList = List.from(_foodProductList.reversed);
        for (int i = 0; i < _foodProductList.length; ++i) {
          _foodProductLayoutList.add(itemTile(
              _foodProductList[i].imgUrl1!,
              _foodProductList[i].price,
              _foodProductList[i].prodName!,
              false,
              _foodProductList[i],
              size));
        }
        _snackProductList.sort((a, b) => a.price.compareTo(b.price));
        _snackProductLayoutList.clear();
        if (!_isAsc) _snackProductList = List.from(_snackProductList.reversed);
        for (int i = 0; i < _snackProductList.length; ++i) {
          _snackProductLayoutList.add(itemTile(
              _snackProductList[i].imgUrl1!,
              _snackProductList[i].price,
              _snackProductList[i].prodName!,
              false,
              _snackProductList[i],
              size));
        }
        _beverageProductList.sort((a, b) => a.price.compareTo(b.price));
        _beverageProductLayoutList.clear();
        if (!_isAsc)
          _beverageProductList = List.from(_beverageProductList.reversed);
        for (int i = 0; i < _beverageProductList.length; ++i) {
          _beverageProductLayoutList.add(itemTile(
              _beverageProductList[i].imgUrl1!,
              _beverageProductList[i].price,
              _beverageProductList[i].prodName!,
              false,
              _beverageProductList[i],
              size));
        }
        _stationeryProductList.sort((a, b) => a.price.compareTo(b.price));
        _stationeryProductLayoutList.clear();
        if (!_isAsc)
          _stationeryProductList = List.from(_stationeryProductList.reversed);
        for (int i = 0; i < _stationeryProductList.length; ++i) {
          _stationeryProductLayoutList.add(itemTile(
              _stationeryProductList[i].imgUrl1!,
              _stationeryProductList[i].price,
              _stationeryProductList[i].prodName!,
              false,
              _stationeryProductList[i],
              size));
        }
        _handmadeProductList.sort((a, b) => a.price.compareTo(b.price));
        _handmadeProductLayoutList.clear();
        if (!_isAsc)
          _handmadeProductList = List.from(_handmadeProductList.reversed);
        for (int i = 0; i < _handmadeProductList.length; ++i) {
          _handmadeProductLayoutList.add(itemTile(
              _handmadeProductList[i].imgUrl1!,
              _handmadeProductList[i].price,
              _handmadeProductList[i].prodName!,
              false,
              _handmadeProductList[i],
              size));
        }
        _bestProductList.sort((a, b) => a.price.compareTo(b.price));
        _bestProductLayoutList.clear();
        if (!_isAsc) _bestProductList = List.from(_bestProductList.reversed);
        for (int i = 0; i < _bestProductList.length; ++i) {
          _bestProductLayoutList.add(itemTile(
              _bestProductList[i].imgUrl1!,
              _bestProductList[i].price,
              _bestProductList[i].prodName!,
              false,
              _bestProductList[i],
              size));
        }

        _newProductList.sort((a, b) => a.price.compareTo(b.price));
        _newProductLayoutList.clear();
        if (!_isAsc) _newProductList = List.from(_newProductList.reversed);
        for (int i = 0; i < _newProductList.length; ++i) {
          _newProductLayoutList.add(itemTile(
              _newProductList[i].imgUrl1!,
              _newProductList[i].price,
              _newProductList[i].prodName!,
              false,
              _newProductList[i],
              size));
        }
        break;
    }
    setState(() {});
  }

  /// parameter로 들어온 검색하고 싶은 키워드로 상품들을 검색하여 검색 List 에 추가하는 작업
  /// @param : 검색하고자 하는 문자열
  void _searchProducts(String toSearch, Size size) {
    _tabController!.index = 0;
    _isSearch = true;
    _searchProductList.clear();
    _searchProductLayoutList.clear();
    for (int i = 0; i < _productList.length; ++i) {
      if (_productList[i].prodName!.contains('$toSearch')) {
        _searchProductList.add(_productList[i]);
        _searchProductLayoutList.add(itemTile(
            _productList[i].imgUrl1!,
            _productList[i].price,
            _productList[i].prodName!,
            false,
            _productList[i],
            size));
      }
    }
    setState(() {});
  }

  /// 일반 숫자에 ,를 붙여서 직관적인 가격을 보이게 하는 작업
  /// @param : 직관적인 가격을 보여줄 실제 int 가격[price]
  /// @return : 직관적인 가격 문자열
  String _formatPrice(int price) {
    String p = price.toString();
    String newFormat = '';
    int count = 0;
    for (int i = p.length - 1; i >= 0; --i) {
      if ((count + 1) % 4 == 0) {
        newFormat += ',';
        ++i;
      } else
        newFormat += p[i];
      ++count;
    }
    return _reverseString(newFormat);
  }

  /// 문자열을 뒤집는 작업
  /// @param : 뒤집고 싶은 문자열[str]
  /// @return : 뒤집은 문자열
  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  /// 신규 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getNewProdLayout(Size size) {
    for (int i = 0; i < _newProductList.length; ++i) {
      var tmp = _newProductList[i];
      _newProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 베스트 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getBestProdLayout(Size size) {
    for (int i = 0; i < _bestProductList.length; ++i) {
      var tmp = _bestProductList[i];
      _bestProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 음식류 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getFoodProdLayout(Size size) {
    for (int i = 0; i < _foodProductList.length; ++i) {
      var tmp = _foodProductList[i];
      _foodProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 간식류 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getSnackProdLayout(Size size) {
    for (int i = 0; i < _snackProductList.length; ++i) {
      var tmp = _snackProductList[i];
      _snackProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 음료류 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getBeverageProdLayout(Size size) {
    for (int i = 0; i < _beverageProductList.length; ++i) {
      var tmp = _beverageProductList[i];
      _beverageProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 문구류 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getStationeryProdLayout(Size size) {
    for (int i = 0; i < _stationeryProductList.length; ++i) {
      var tmp = _stationeryProductList[i];
      _stationeryProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// 핸드메이드 상품 List 를 토대로 신규 상품 Widget List 에 추가
  void getHandmadeProdLayout(Size size) {
    for (int i = 0; i < _handmadeProductList.length; ++i) {
      var tmp = _handmadeProductList[i];
      _handmadeProductLayoutList.add(
          itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
    }
  }

  /// MENU 탭에서 현재 보여지는 카테고리의 상품 개수를 반환
  /// @param : 현재 카테고리 위치 index
  int _getLengthOfCurrentCategory(int position) {
    switch (position) {
      case 0:
        return _productLayoutList.length;
      case 1:
        return _foodProductLayoutList.length;
      case 2:
        return _snackProductLayoutList.length;
      case 3:
        return _beverageProductLayoutList.length;
      case 4:
        return _stationeryProductLayoutList.length;
      case 5:
        return _handmadeProductLayoutList.length;
      default:
        return -1;
    }
  }

  /// product table에 있는 모든 상품 데이터를 요청
  /// @param : X
  /// @result : X [중간 과정에 상품을 분류하는 작업을 함]
  Future<void> _getProducts() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        print('일일 트래픽 모두 사용');
        return ;
      }
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List productList = json.decode(result);
      List<Product> prodObjects = [];
      for (int i = 0; i < productList.length; ++i) {
        prodObjects.add(Product.fromJson(json.decode(productList[i])));
      }
      _productList = prodObjects;
      _productLayoutList.clear();
      _newProductLayoutList.clear();
      _bestProductLayoutList.clear();
      _newProductList.clear();
      _bestProductList.clear();
      _handmadeProductLayoutList.clear();
      _handmadeProductList.clear();
      _beverageProductList.clear();
      _beverageProductLayoutList.clear();
      _foodProductList.clear();
      _foodProductLayoutList.clear();
      _snackProductList.clear();
      _snackProductLayoutList.clear();
      _stationeryProductLayoutList.clear();
      _stationeryProductList.clear();

      var size = MediaQuery.of(context).size;
      for (int i = 0; i < _productList.length; ++i) {
        var tmp = _productList[i];
        _productLayoutList.add(
            itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
      }
      setState(() {
        _groupingProduct(size);
        _isAsc = true;
        _selectRadio = 0;
        _isLoading = false;
      });
    }
  }

  /// 관리자가 상품을 삭제하는 HTTP 요청
  /// @param : 상품 ID -> PK of product table
  /// @result : 삭제가 정상적으로 되었는지에 대한 bool 값
  Future<bool> _deleteProductRequest(int productID) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_deleteProduct.php';
    final response = await http.get(Uri.parse(url + '?id=$productID'));
    if (response.statusCode == 200) {
      if (response.body.contains('DELETED')) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  /// 관리자임을 인증하는 HTTP 요청
  /// @param : HTTP GET : UID 값과 ADMIN KEY 값
  /// @result : 관리자 인증이 되었는지에 대한 bool 값
  Future<bool> _certifyAdminAccess() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_adminCertified.php';
    final response = await http
        .get(Uri.parse(url + '?uid=${widget.user!.uid}&key=${_adminKeyController.text}'));

    if (response.statusCode == 200) {
      if (response.body.contains('CERTIFIED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 토스트 메세지 출력
  /// @param : message : 출력할 메세지, fail : 특정 동작에 대해 에러 발생 시 true
  Future<bool?> showToast(String message, bool fail) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        textColor: fail ? Colors.deepOrange : Colors.black);
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _scrollViewController = ScrollController();
    _getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: _getProducts,
      child: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              forceElevated: innerBoxIsScrolled,
              leadingWidth: size.width * 0.25,
              centerTitle: true,
              title: aboveTap(size),
              leading: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: DefaultButtonComp(
                    onPressed: () {
                      _tabController!.index = 0;
                    },
                    child: Image.asset(
                      'assets/images/duruduru_logo.png',
                    ),
                  )),
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: 'MENU',
                  ),
                  Tab(
                    text: 'BEST',
                  ),
                  Tab(
                    text: 'NEW',
                  ),
                  Tab(
                    text: 'EVENT',
                  )
                ],
                labelColor: Colors.black,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                indicatorColor: Color(0xFF9EE1E5),
                indicatorWeight: 6.0,
                controller: _tabController,
                unselectedLabelColor: Colors.grey,
              ),
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: [
          _isSearch
              ? _searchProductLayoutList.length == 0
                  ? Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text(
                          '상품 검색 결과',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        _removeSearchResultWidget(size),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Expanded(
                            child: Center(
                                child: Text(
                          '검색 결과가 없습니다!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        )))
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text('상품 검색 결과',
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        _removeSearchResultWidget(size),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Expanded(
                          child: Container(
                            child: GridView.builder(
                                itemCount: _searchProductLayoutList.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: size.height * 0.025,
                                        crossAxisSpacing: size.width * 0.01),
                                itemBuilder: (context, index) {
                                  return _searchProductLayoutList[index];
                                }),
                          ),
                        ),
                      ],
                    )
              : _productLayoutList.length == 0
                  ? _isLoading
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('불러오는 중...'),
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _getProducts,
                          child: Column(
                            children: [
                              addProductForAdmin(size),
                              Expanded(
                                child: Center(
                                    child: Text(
                                  '상품이 없습니다.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                )),
                              ),
                            ],
                          ),
                        )
                  : RefreshIndicator(
                      onRefresh: _getProducts,
                      child: Column(
                        children: [
                          addProductForAdmin(size),
                          Card(
                            elevation: 2,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              height: size.height * 0.085,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategory != 1)
                                          _selectedCategory = 1;
                                        else
                                          _selectedCategory = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 0.19,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Image.asset(_selectedCategory ==
                                                    1
                                                ? "assets/images/new_drink_on_icon.jpg"
                                                : "assets/images/new_drink_icon.jpg"),
                                            height: size.height * 0.06,
                                          ),
                                          Text('${Category.c1}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedCategory == 1
                                                      ? Color(0xFF9EE1E5)
                                                      : Colors.black))
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategory != 2)
                                          _selectedCategory = 2;
                                        else
                                          _selectedCategory = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 0.19,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Image.asset(_selectedCategory ==
                                                    2
                                                ? "assets/images/snack_on_icon.jpg"
                                                : "assets/images/snack_icon.jpg"),
                                            height: size.height * 0.06,
                                          ),
                                          Text('${Category.c2}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedCategory == 2
                                                      ? Color(0xFF9EE1E5)
                                                      : Colors.black))
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategory != 3)
                                          _selectedCategory = 3;
                                        else
                                          _selectedCategory = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 0.19,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Image.asset(_selectedCategory ==
                                                    3
                                                ? "assets/images/icecream_on_icon.jpg"
                                                : "assets/images/icecream_icon.jpg"),
                                            height: size.height * 0.06,
                                          ),
                                          Text('${Category.c3}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedCategory == 3
                                                      ? Color(0xFF9EE1E5)
                                                      : Colors.black))
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategory != 4)
                                          _selectedCategory = 4;
                                        else
                                          _selectedCategory = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 0.19,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Image.asset(_selectedCategory ==
                                                    4
                                                ? "assets/images/drink_on_icon.jpg"
                                                : "assets/images/drink_icon.jpg"),
                                            height: size.height * 0.06,
                                          ),
                                          Text('${Category.c4}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedCategory == 4
                                                      ? Color(0xFF9EE1E5)
                                                      : Colors.black))
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedCategory != 5)
                                          _selectedCategory = 5;
                                        else
                                          _selectedCategory = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 0.19,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Image.asset(_selectedCategory ==
                                                    5
                                                ? "assets/images/handmade_on_icon.jpg"
                                                : "assets/images/handmadeicon.jpg"),
                                            height: size.height * 0.06,
                                          ),
                                          Text('${Category.c5}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: _selectedCategory == 5
                                                      ? Color(0xFF9EE1E5)
                                                      : Colors.black))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isAsc = !_isAsc;
                                    _productList =
                                        List.from(_productList.reversed);
                                    _productLayoutList =
                                        List.from(_productLayoutList.reversed);
                                    _foodProductList =
                                        List.from(_foodProductList.reversed);
                                    _foodProductLayoutList = List.from(
                                        _foodProductLayoutList.reversed);

                                    _snackProductList =
                                        List.from(_snackProductList.reversed);
                                    _snackProductLayoutList = List.from(
                                        _snackProductLayoutList.reversed);

                                    _beverageProductList = List.from(
                                        _beverageProductList.reversed);
                                    _beverageProductLayoutList = List.from(
                                        _beverageProductLayoutList.reversed);

                                    _stationeryProductList = List.from(
                                        _stationeryProductList.reversed);
                                    _stationeryProductLayoutList = List.from(
                                        _stationeryProductLayoutList.reversed);

                                    _handmadeProductList = List.from(
                                        _handmadeProductList.reversed);
                                    _handmadeProductLayoutList = List.from(
                                        _handmadeProductLayoutList.reversed);

                                    _bestProductList =
                                        List.from(_bestProductList.reversed);
                                    _bestProductLayoutList = List.from(
                                        _bestProductLayoutList.reversed);

                                    _newProductList =
                                        List.from(_newProductList.reversed);
                                    _newProductLayoutList = List.from(
                                        _newProductLayoutList.reversed);
                                  });
                                },
                                icon: Icon(_isAsc
                                    ? Icons.arrow_circle_up
                                    : Icons.arrow_circle_down),
                                iconSize: 27,
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            shape: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 2)),
                                            title: Center(
                                              child: Text(
                                                '상품정렬 기준 선택',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            content: StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children:
                                                      List.generate(3, (index) {
                                                    return RadioListTile<int>(
                                                      title: Center(
                                                          child: Text(
                                                              _sortTitleList[
                                                                  index])),
                                                      value: index,
                                                      groupValue: _selectRadio,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectRadio = value;
                                                        });
                                                        _sortProductByIndex(
                                                            _selectRadio, size);
                                                      },
                                                    );
                                                  }),
                                                );
                                              },
                                            ),
                                          ));
                                },
                                icon: Icon(Icons.sort),
                                padding: EdgeInsets.all(0),
                                iconSize: 27,
                              ),
                              SizedBox(
                                width: size.width * 0.02,
                              )
                            ],
                          ),
                          _getLengthOfCurrentCategory(_selectedCategory) == 0
                              ? Expanded(
                                  child: Center(
                                      child: Text(
                                    '상품이 없습니다!',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21),
                                  )),
                                )
                              : Expanded(
                                  child: Container(
                                    height: size.height,
                                    child: GridView.builder(
                                        itemCount: _getLengthOfCurrentCategory(
                                            _selectedCategory),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing:
                                                    size.height * 0.025,
                                                crossAxisSpacing:
                                                    size.width * 0.01),
                                        itemBuilder: (context, index) {
                                          return _getItemTileOfCurrentCategory(
                                              index, _selectedCategory);
                                        }),
                                  ),
                                ),
                          CorporationInfo(isOpenable: true)
                        ],
                      ),
                    ),
          /*------------------------ MENU TAB -------------------------*/
          _bestProductLayoutList.length == 0
              ? RefreshIndicator(
                  onRefresh: _getProducts,
                  child: Column(
                    children: [
                      addProductForAdmin(size),
                      Expanded(
                        child: Center(
                            child: Text(
                          '베스트 상품이 없습니다!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        )),
                      ),
                      CorporationInfo(isOpenable: true)
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _getProducts,
                  child: Column(
                    children: [
                      addProductForAdmin(size),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isAsc = !_isAsc;
                                _productList = List.from(_productList.reversed);
                                _productLayoutList =
                                    List.from(_productLayoutList.reversed);
                                _foodProductList =
                                    List.from(_foodProductList.reversed);
                                _foodProductLayoutList =
                                    List.from(_foodProductLayoutList.reversed);

                                _snackProductList =
                                    List.from(_snackProductList.reversed);
                                _snackProductLayoutList =
                                    List.from(_snackProductLayoutList.reversed);

                                _beverageProductList =
                                    List.from(_beverageProductList.reversed);
                                _beverageProductLayoutList = List.from(
                                    _beverageProductLayoutList.reversed);

                                _stationeryProductList =
                                    List.from(_stationeryProductList.reversed);
                                _stationeryProductLayoutList = List.from(
                                    _stationeryProductLayoutList.reversed);

                                _handmadeProductList =
                                    List.from(_handmadeProductList.reversed);
                                _handmadeProductLayoutList = List.from(
                                    _handmadeProductLayoutList.reversed);

                                _bestProductList =
                                    List.from(_bestProductList.reversed);
                                _bestProductLayoutList =
                                    List.from(_bestProductLayoutList.reversed);

                                _newProductList =
                                    List.from(_newProductList.reversed);
                                _newProductLayoutList =
                                    List.from(_newProductLayoutList.reversed);
                              });
                            },
                            icon: Icon(_isAsc
                                ? Icons.arrow_circle_up
                                : Icons.arrow_circle_down),
                            iconSize: 27,
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 2)),
                                        title: Center(
                                          child: Text(
                                            '상품정렬 기준 선택',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        content: StatefulBuilder(
                                          builder: (context, setState) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                                  List.generate(3, (index) {
                                                return RadioListTile<int>(
                                                  title: Center(
                                                      child: Text(
                                                          _sortTitleList[
                                                              index])),
                                                  value: index,
                                                  groupValue: _selectRadio,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectRadio = value;
                                                    });
                                                    _sortProductByIndex(
                                                        _selectRadio, size);
                                                  },
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ));
                            },
                            icon: Icon(Icons.sort),
                            padding: EdgeInsets.all(0),
                            iconSize: 27,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(
                          child: GridView.builder(
                              itemCount: _bestProductLayoutList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: size.height * 0.025,
                                      crossAxisSpacing: size.width * 0.01),
                              itemBuilder: (context, index) {
                                return _bestProductLayoutList[index];
                              }),
                        ),
                      ),
                      CorporationInfo(isOpenable: true)
                    ],
                  ),
                ),
          /*------------ BEST TAB ---------------*/
          _newProductLayoutList.length == 0
              ? RefreshIndicator(
                  onRefresh: _getProducts,
                  child: Column(
                    children: [
                      addProductForAdmin(size),
                      Expanded(
                        child: Center(
                            child: Text(
                          '신규 상품이 없습니다!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        )),
                      ),
                      CorporationInfo(isOpenable: true)
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _getProducts,
                  child: Column(
                    children: [
                      addProductForAdmin(size),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isAsc = !_isAsc;
                                _productList = List.from(_productList.reversed);
                                _productLayoutList =
                                    List.from(_productLayoutList.reversed);
                                _foodProductList =
                                    List.from(_foodProductList.reversed);
                                _foodProductLayoutList =
                                    List.from(_foodProductLayoutList.reversed);

                                _snackProductList =
                                    List.from(_snackProductList.reversed);
                                _snackProductLayoutList =
                                    List.from(_snackProductLayoutList.reversed);

                                _beverageProductList =
                                    List.from(_beverageProductList.reversed);
                                _beverageProductLayoutList = List.from(
                                    _beverageProductLayoutList.reversed);

                                _stationeryProductList =
                                    List.from(_stationeryProductList.reversed);
                                _stationeryProductLayoutList = List.from(
                                    _stationeryProductLayoutList.reversed);

                                _handmadeProductList =
                                    List.from(_handmadeProductList.reversed);
                                _handmadeProductLayoutList = List.from(
                                    _handmadeProductLayoutList.reversed);

                                _bestProductList =
                                    List.from(_bestProductList.reversed);
                                _bestProductLayoutList =
                                    List.from(_bestProductLayoutList.reversed);

                                _newProductList =
                                    List.from(_newProductList.reversed);
                                _newProductLayoutList =
                                    List.from(_newProductLayoutList.reversed);
                              });
                            },
                            icon: Icon(_isAsc
                                ? Icons.arrow_circle_up
                                : Icons.arrow_circle_down),
                            iconSize: 27,
                            padding: EdgeInsets.all(0.0),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 2)),
                                        title: Center(
                                          child: Text(
                                            '상품정렬 기준 선택',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        content: StatefulBuilder(
                                          builder: (context, setState) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                                  List.generate(3, (index) {
                                                return RadioListTile<int>(
                                                  title: Center(
                                                      child: Text(
                                                          _sortTitleList[
                                                              index])),
                                                  value: index,
                                                  groupValue: _selectRadio,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectRadio = value;
                                                    });
                                                    _sortProductByIndex(
                                                        _selectRadio, size);
                                                  },
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ));
                            },
                            icon: Icon(Icons.sort),
                            padding: EdgeInsets.all(0),
                            iconSize: 27,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(
                          child: GridView.builder(
                              itemCount: _newProductLayoutList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: size.height * 0.025,
                                      crossAxisSpacing: size.width * 0.01),
                              itemBuilder: (context, index) {
                                return _newProductLayoutList[index];
                              }),
                        ),
                      ),
                    CorporationInfo(isOpenable: true)
                    ],
                  ),
                ),
          /*------------ NEW TAB ---------------*/
          EventPage(),
          /*------------ EVENT TAB ---------------*/
        ]),
      ),
    );
  }

  Widget itemTile(String imgUrl, int price, String prodName, bool isWish,
      Product product, Size size) {
    return GestureDetector(
      onTap: () async {
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailProductPage(
                      user: widget.user,
                      product: product,
                    )));
        if (res) {
          await _getProducts();
        }
      },
      onLongPress: () async {
        // 상품 수정 및 삭제 기능 -> 어드민 권한으로 동작
        if (widget.user!.isAdmin) {
          // 메뉴에서 선택한 값(value)를 리턴함
          var selected = await showMenu(
            color: Colors.cyan[100],
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black26, width: 2)),
            context: context,
            position: RelativeRect.fromLTRB(120, 75, 165, 75),
            items: [
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.delete),
                    Text('삭제하기'),
                  ],
                ),
                value: 'delete',
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.update),
                    Text('수정하기'),
                  ],
                ),
                value: 'modify',
              ),
            ],
          );
          switch (selected) {
            case 'delete':
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                        title: Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.red,
                          size: 60,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '※이 상품을 삭제하시겠습니까?',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '[${product.prodName}]',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )
                          ],
                        ),
                        actions: [
                          DefaultButtonComp(
                              onPressed: () => Navigator.pop(context),
                              child: Text('아니요')),
                          DefaultButtonComp(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('관리자 키 Key 입력'),
                                          content: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.orange[200]!),
                                                color: Colors.blue[100]),
                                            child: TextField(
                                              inputFormatters: [
                                                UpperCaseTextFormatter()
                                              ],
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Admin Key'),
                                              controller: _adminKeyController,
                                            ),
                                          ),
                                          actions: [
                                            DefaultButtonComp(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text('취소')),
                                            DefaultButtonComp(
                                                onPressed: () async {
                                                  var result =
                                                      await _certifyAdminAccess(); // 어드민 키 인증
                                                  if (result) {
                                                    var res =
                                                        await _deleteProductRequest(
                                                            product
                                                                .prodID); // DB에서 상품 삭제
                                                    if (res) {
                                                      Navigator.pop(ctx);
                                                      showToast(
                                                          '삭제가 완료되었습니다. 목록을 새로고침 바랍니다.',
                                                          false);
                                                      await _getProducts();
                                                    } else {
                                                      Navigator.pop(ctx);
                                                      showToast('삭제에 실패하였습니다!!',
                                                          true);
                                                    }
                                                  } else {
                                                    showToast(
                                                        '인증에 실패하였습니다!', true);
                                                  }
                                                },
                                                child: Text('인증'))
                                          ],
                                        ));
                              },
                              child: Text('예'))
                        ],
                      ));
              break;
            case 'modify':
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdatingProductPage(
                            product: product,
                          )));
              if (res) {
                await _getProducts();
              }
              break;
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            //핵심 : Stack() 의 높이는 정해져있지 않기 때문에 Expanded() 로
            child: Stack(
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    // 가로 : 세로 비율 어떻게?
                    // 현재 1:1
                    width: size.width * 0.4,
                    height: size.width * 0.4 * 1.4,
                    imageUrl: imgUrl,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                          alignment: Alignment.center,
                          color: Colors.grey[400],
                          child: Text('No Image'));
                      //placeholder 추가하기 -> 로고로
                    },
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_formatPrice(price)}원',
                style: TextStyle(
                    color: product.discount.toString() != '0.0'
                        ? Colors.red
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: product.discount.toString() == '0.0'
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                    fontSize: 12.5),
                textAlign: TextAlign.start,
              ),
              product.discount.toString() != '0.0'
                  ? Text(
                      '  ${_formatPrice((product.price * (1 - (product.discount / 100.0))).round())}원',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12.5),
                    )
                  : Text('')
            ],
          ),
          SizedBox(
            height: size.height * 0.004,
          ),
          Text(prodName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              textAlign: TextAlign.center)
        ],
      ),
    );
  }

  Widget managerAddingProductLayout(Size size) {
    return GestureDetector(
      onTap: () async {
        var res = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddingProductPage()));
        if (res) {
          await _getProducts();
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(size.width * 0.018),
        width: size.width * 0.98,
        margin: EdgeInsets.all(size.width * 0.015),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
        child: Text(
          '상품 추가하기 [관리자 모드]',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget addProductForAdmin(Size size) {
    return widget.user!.isAdmin ? managerAddingProductLayout(size) : SizedBox();
  }

  Widget _getItemTileOfCurrentCategory(int index, int position) {
    switch (position) {
      case 0:
        return _productLayoutList[index];
      case 1:
        return _foodProductLayoutList[index];
      case 2:
        return _snackProductLayoutList[index];
      case 3:
        return _beverageProductLayoutList[index];
      case 4:
        return _stationeryProductLayoutList[index];
      case 5:
        return _handmadeProductLayoutList[index];
      default:
        return Container(
          child: Text('Error'),
        );
    }
  }

  Widget aboveTap(Size size) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.01),
      width: size.width * 0.7,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xFF9EE1E5)),
      child: TextField(
        style: TextStyle(fontSize: 13),
        onSubmitted: (text) {
          if (text.isNotEmpty) {
            _searchProducts(text, size);
          }
        },
        decoration: InputDecoration(
          hintText: '상품 검색',
          hintStyle: TextStyle(fontSize: 13),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
        ),
        controller: _searchController,
      ),
    );
  }

  Widget _removeSearchResultWidget(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: size.width * 0.5,
      height: size.height * 0.05,
      decoration: BoxDecoration(
          color: Color(0xFF9EE1E5).withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFF9EE1E5), width: 2)),
      child: DefaultButtonComp(
        onPressed: () {
          setState(() {
            _isSearch = false;
            _searchController.text = '';
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.remove_circle,
              color: Colors.red,
            ),
            Text('검색 결과창 지우기')
          ],
        ),
      ),
    );
  }

}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
