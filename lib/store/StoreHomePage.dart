import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/CorporationComp.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/store/product/DetailProductPage.dart';
import 'package:asgshighschool/store/EventPage.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
import '../component/DefaultButtonComp.dart';
import '../storeAdmin/product/AddProduct.dart';
import '../storeAdmin/product/UpdateProduct.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../util/NumberFormatter.dart';
import '../util/ToastMessage.dart';
import '../util/UpperCaseTextFormatter.dart';

class StoreHomePage extends StatefulWidget {
  StoreHomePage({this.user, this.existCart, required this.categories});

  final User? user;
  final bool? existCart;
  final List<Category> categories;

  @override
  _StoreHomePageState createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage>
    with TickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _adminKeyController = TextEditingController();
  late TabController _tabController;
  ScrollController? _scrollViewController;
  int _selectedCategory = 0; // MENU 탭에서 어느 카테고리인지에 대한 값
  int _selectRadio = 0; // 정렬 기준 선택 라디오 버튼 값
  List _sortTitleList = ['등록순', '이름순', '가격순']; // 정렬 기준 라디오 버튼 title 리스트
  bool _isAsc = true; // true : 오름차순 , false : 내림차순
  bool _isSearch = false; // 검색 기능 사용했는지 판단
  bool _isLoading = true; // 상품 데이터 가져오는 동안의 로딩 상태
  int _isBest = 0;
  int _isNew = 0;

  List<Product> _productList = [];
  List<Widget> _productLayoutList = [];

  Future<void> _getProductsWithFilters(
      String? sort, bool isAsc, int? isBest, int? isNew, int? category,
      {String? keyword = null}) async {
    String url = '${ApiUtil.API_HOST}arlimi_getProductsFilter.php?';
    url += 'sort=${_convertSortStrategy(sort)}&';
    url += (category == null || category == 0) ? '' : 'category=$category&';
    url += (isBest == null || isBest == 0) ? '' : 'best=$isBest&';
    url += (isNew == null || isNew == 0) ? '' : 'new=$isNew&';
    url += (keyword == null || keyword == '') ? '' : 'keyword=$keyword&';
    url += 'asc=${!isAsc}';
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(milliseconds: 50));
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List productList = json.decode(ApiUtil.getPureBody(response.bodyBytes));
      List<Product> prodObjects = [];
      for (int i = 0; i < productList.length; ++i) {
        prodObjects.add(Product.fromJson(json.decode(productList[i])));
      }
      _productList = prodObjects;
      _productLayoutList.clear();
      var size = MediaQuery.of(context).size;
      for (int i = 0; i < _productList.length; ++i) {
        var tmp = _productList[i];
        _productLayoutList.add(
            itemTile(tmp.imgUrl1!, tmp.price, tmp.prodName!, false, tmp, size));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _convertSortStrategy(String? sort) {
    switch (sort) {
      case '등록순':
        return 'ID';
      case '이름순':
        return 'NAME';
      case '가격순':
        return 'PRICE';
      default:
        return 'ID';
    }
  }

  /// 관리자가 상품을 삭제하는 HTTP 요청
  /// @param : 상품 ID -> PK of product table
  /// @result : 삭제가 정상적으로 되었는지에 대한 bool 값
  Future<bool> _deleteProductRequest(int productID) async {
    String url = '${ApiUtil.API_HOST}arlimi_deleteProduct.php';
    final response = await http.get(Uri.parse(url + '?id=$productID'));
    if (response.statusCode == 200) {
      if (response.body.contains('DELETED')) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() async {
      if (_tabController.index == 0) {
        setState(() {
          _isBest = 0;
          _isNew = 0;
        });
        await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
            null, null, _selectedCategory);
      } else if (_tabController.index == 1) {
        setState(() {
          _isBest = 1;
          _isNew = 0;
        });
        await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
            _isBest, null, _selectedCategory);
      } else if (_tabController.index == 2) {
        setState(() {
          _isBest = 0;
          _isNew = 1;
        });
        await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
            null, _isNew, _selectedCategory);
      }
    });
    _scrollViewController = ScrollController();
    _getProductsWithFilters(
        _sortTitleList[_selectRadio], _isAsc, null, null, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
        onRefresh: () async {
          await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
              null, null, _selectedCategory);
        },
        child: NestedScrollView(
            controller: _scrollViewController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                    backgroundColor: Colors.white,
                    forceElevated: innerBoxIsScrolled,
                    leadingWidth: size.width * 0.23,
                    centerTitle: true,
                    title: aboveTap(size),
                    leading: Container(
                        margin: EdgeInsets.only(left: size.width * 0.02),
                        alignment: Alignment.center,
                        child: DefaultButtonComp(
                            onPressed: () {
                              _tabController.index = 0;
                            },
                            child: Image.asset(
                                'assets/images/duruduru_logo.png'))),
                    bottom: TabBar(
                        tabs: [
                          Tab(text: 'MENU'),
                          Tab(text: 'BEST'),
                          Tab(text: 'NEW'),
                          Tab(text: 'EVENT')
                        ],
                        labelColor: Colors.black,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        indicatorColor: Color(0xFF9EE1E5),
                        indicatorWeight: 6.0,
                        controller: _tabController,
                        unselectedLabelColor: Colors.grey))
              ];
            },
            body: TabBarView(controller: _tabController, children: [
              _isSearch
                  ? _productLayoutList.length == 0
                      ? Column(
                          children: [
                            SizedBox(height: size.height * 0.01),
                            Text('상품 검색 결과',
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold)),
                            SizedBox(height: size.height * 0.01),
                            _removeSearchResultWidget(size),
                            SizedBox(height: size.height * 0.01),
                            Expanded(
                                child: Center(
                                    child: Text('검색 결과가 없습니다!',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 21))))
                          ],
                        )
                      : Column(children: [
                          SizedBox(height: size.height * 0.01),
                          Text('상품 검색 결과',
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold)),
                          SizedBox(height: size.height * 0.01),
                          _removeSearchResultWidget(size),
                          SizedBox(height: size.height * 0.01),
                          Expanded(
                              child: Container(
                                  child: GridView.builder(
                                      itemCount: _productLayoutList.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing:
                                                  size.height * 0.025,
                                              crossAxisSpacing:
                                                  size.width * 0.01),
                                      itemBuilder: (context, index) {
                                        return _productLayoutList[index];
                                      })))
                        ])
                  : _isLoading
                      ? _loadingWidget(size)
                      : _aboveTapWidget(size, '상품이 없습니다.'),
              /*------------------------ MENU TAB -------------------------*/
              _isLoading
                  ? _loadingWidget(size)
                  : _aboveTapWidget(size, '베스트 상품이 없습니다.'),
              /*------------ BEST TAB ---------------*/
              _isLoading
                  ? _loadingWidget(size)
                  : _aboveTapWidget(size, '신규 상품이 없습니다.'),
              /*------------ NEW TAB ---------------*/
              EventPage()
              /*------------ EVENT TAB ---------------*/
            ])));
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
            await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
                _isBest, _isNew, _selectedCategory);
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
                      children: [Icon(Icons.delete), Text('삭제하기')]),
                  value: 'delete',
                ),
                PopupMenuItem(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.update), Text('수정하기')]),
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
                          title: Icon(Icons.warning_amber_outlined,
                              color: Colors.red, size: 60),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('※이 상품을 삭제하시겠습니까?',
                                  textAlign: TextAlign.center),
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
                                                        color: Colors
                                                            .orange[200]!),
                                                    color: Colors.blue[100]),
                                                child: TextField(
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter()
                                                    ],
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: 'Admin Key'),
                                                    controller:
                                                        _adminKeyController)),
                                            actions: [
                                              DefaultButtonComp(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: Text('취소')),
                                              DefaultButtonComp(
                                                  onPressed: () async {
                                                    var result = await AdminUtil
                                                        .certifyAdminAccess(
                                                            widget.user!.uid!,
                                                            _adminKeyController
                                                                .text); // 어드민 키 인증
                                                    if (result) {
                                                      var res =
                                                          await _deleteProductRequest(
                                                              product
                                                                  .prodID); // DB에서 상품 삭제
                                                      if (res) {
                                                        Navigator.pop(ctx);
                                                        ToastMessage.show(
                                                            '삭제가 완료되었습니다. 목록을 새로고침 바랍니다.');
                                                        await _getProductsWithFilters(
                                                            _sortTitleList[
                                                                _selectRadio],
                                                            _isAsc,
                                                            _isBest,
                                                            _isNew,
                                                            _selectedCategory);
                                                        Navigator.pop(ctx);
                                                        ToastMessage.show(
                                                            '삭제에 실패했습니다.');
                                                      }
                                                    } else {
                                                      ToastMessage.show(
                                                          '인증에 실패했습니다.');
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
                  await _getProductsWithFilters(_sortTitleList[_selectRadio],
                      _isAsc, _isBest, _isNew, _selectedCategory);
                }
                break;
            }
          }
        },
        child: Column(children: [
          Expanded(
              //핵심 : Stack() 의 높이는 정해져있지 않기 때문에 Expanded() 로
              child: Stack(children: [
            ClipRRect(
                child: CachedNetworkImage(
                  // 가로 : 세로 비율 어떻게?
                  // 현재 1:1
                  width: size.width * 0.4,
                  height: size.width * 0.4 * 1.4,
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                      child:
                          CircularProgressIndicator(value: progress.progress)),
                  errorWidget: (context, url, error) {
                    return Container(
                        alignment: Alignment.center,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey),
                            Text('이미지 준비 중입니다.',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ));
                  },
                ),
                borderRadius: BorderRadius.circular(15))
          ])),
          SizedBox(height: size.height * 0.005),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${NumberFormatter.formatPrice(price)}원',
                style: TextStyle(
                    color: product.discount.toString() != '0.0'
                        ? Colors.red
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: product.discount.toString() == '0.0'
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                    fontSize: 12.5),
                textAlign: TextAlign.start),
            product.discount.toString() != '0.0'
                ? Text(
                    '  ${NumberFormatter.formatPrice((product.price * (1 - (product.discount / 100.0))).round())}원',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))
                : Text('')
          ]),
          SizedBox(height: size.height * 0.004),
          Text(prodName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              textAlign: TextAlign.center)
        ]));
  }

  Widget managerAddingProductLayout(Size size) {
    return GestureDetector(
        onTap: () async {
          var res = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddingProductPage()));
          if (res) {
            await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
                _isBest, _isNew, _selectedCategory);
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
                color: Colors.grey[100]),
            child: Text('상품 추가하기 [관리자 모드]',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))));
  }

  Widget addProductForAdmin(Size size) {
    return widget.user!.isAdmin ? managerAddingProductLayout(size) : SizedBox();
  }

  Widget aboveTap(Size size) {
    return Container(
        margin: EdgeInsets.all(size.width * 0.01),
        width: size.width * 0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Color(0xFF9EE1E5)),
        child: TextField(
            style: TextStyle(fontSize: 13),
            onSubmitted: (text) async {
              if (text.isNotEmpty) {
                setState(() {
                  _isSearch = true;
                });
                await _getProductsWithFilters(null, _isAsc, null, null, null,
                    keyword: text);
              }
            },
            decoration: InputDecoration(
              hintText: '상품 검색',
              hintStyle: TextStyle(fontSize: 13),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
            ),
            controller: _searchController));
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
            onPressed: () async {
              setState(() {
                _isSearch = false;
                _searchController.text = '';
              });
              await _getProductsWithFilters(_sortTitleList[_selectRadio],
                  _isAsc, _isBest, _isNew, _selectedCategory);
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.remove_circle, color: Colors.red),
                  Text('검색 결과창 지우기')
                ])));
  }

  List<Widget> _categoriesWidget(Size size) {
    List<Widget> list = [];
    for (int i = 0; i < widget.categories.length; ++i) {
      list.add(GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: size.width * 0.01),
            child: Text(widget.categories[i].name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      _selectedCategory == i + 1 ? Colors.amber : Colors.black,
                )),
          ),
          onTap: () async {
            if (_selectedCategory == i + 1) {
              setState(() {
                _selectedCategory = 0;
              });
            } else {
              setState(() {
                _selectedCategory = i + 1;
              });
            }
            await _getProductsWithFilters(_sortTitleList[_selectRadio], _isAsc,
                _isBest, _isNew, _selectedCategory);
          }));
    }
    return list;
  }

  Widget _categorySelectionWidget(Size size) {
    return Card(
        elevation: 2,
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(5),
            height: size.height * 0.085,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: _categoriesWidget(size),
            )));
  }

  Widget _loadingWidget(Size size) {
    return Column(
      children: [
        addProductForAdmin(size),
        _categorySelectionWidget(size),
        Expanded(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('불러오는 중...'), CircularProgressIndicator()])),
        ),
      ],
    );
  }

  Widget _notExistProductsWidget(Size size, String text) {
    return Column(children: [
      addProductForAdmin(size),
      _categorySelectionWidget(size),
      Expanded(
        child: Center(
            child: Text(text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
      ),
      CorporationInfo(isOpenable: true)
    ]);
  }

  Widget _aboveTapWidget(Size size, String emptyProductText) {
    return _productList.length == 0
        ? RefreshIndicator(
            onRefresh: () async {
              await _getProductsWithFilters(_sortTitleList[_selectRadio],
                  _isAsc, _isBest, _isNew, _selectedCategory);
            },
            child: _notExistProductsWidget(size, emptyProductText))
        : RefreshIndicator(
            onRefresh: () async {
              await _getProductsWithFilters(_sortTitleList[_selectRadio],
                  _isAsc, _isBest, _isNew, _selectedCategory);
            },
            child: Column(
              children: [
                addProductForAdmin(size),
                _categorySelectionWidget(size),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () async {
                          _isAsc = !_isAsc;
                          await _getProductsWithFilters(
                              _sortTitleList[_selectRadio],
                              _isAsc,
                              _isBest,
                              _isNew,
                              _selectedCategory);
                        },
                        icon: Icon(_isAsc
                            ? Icons.arrow_circle_up
                            : Icons.arrow_circle_down),
                        iconSize: 27),
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 2)),
                                    title: Center(
                                        child: Text('상품정렬 기준 선택',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold))),
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(3, (index) {
                                            return RadioListTile<int>(
                                              title: Center(
                                                  child: Text(
                                                      _sortTitleList[index])),
                                              value: index,
                                              groupValue: _selectRadio,
                                              onChanged: (value) async {
                                                setState(() {
                                                  _selectRadio = value!;
                                                });
                                                await _getProductsWithFilters(
                                                    _sortTitleList[
                                                        _selectRadio],
                                                    _isAsc,
                                                    _isBest,
                                                    _isNew,
                                                    _selectedCategory);
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
                        iconSize: 27),
                    SizedBox(width: size.width * 0.02)
                  ],
                ),
                Expanded(
                  child: Container(
                    height: size.height,
                    child: GridView.builder(
                        itemCount: _productLayoutList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: size.height * 0.025,
                            crossAxisSpacing: size.width * 0.01),
                        itemBuilder: (context, index) {
                          return _productLayoutList[index];
                        }),
                  ),
                ),
                CorporationInfo(isOpenable: true)
              ],
            ),
          );
  }
}
