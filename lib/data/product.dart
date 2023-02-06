class Product {
  int _prodID;
  String _prodName;
  String _prodInfo;
  int _category;
  int _price;
  int _stockCount;
  double _discount;
  String _imgUrl1;
  String _imgUrl2;
  String _imgUrl3;
  int _isBest;
  int _isNew;
  int _cumulBuyCount;
  bool _isReservation;

  Product(
      this._prodID,
      this._prodName,
      this._prodInfo,
      this._category,
      this._price,
      this._stockCount,
      this._discount,
      this._imgUrl1,
      this._imgUrl2,
      this._imgUrl3,
      this._isBest,
      this._isNew,
      this._cumulBuyCount,
      this._isReservation);

  Product.fromJson(Map<String, dynamic> json)
      : _prodID = int.parse(json['prodID']),
        _prodName = json['prodName'],
        _prodInfo = json['prodInfo'],
        _category = int.parse(json['category']),
        _price = int.parse(json['price']),
        _stockCount = int.parse(json['stockCount']),
        _discount = double.parse(json['discount']),
        _imgUrl1 = json['imgUrl1'],
        _imgUrl2 = json['imgUrl2'],
        _imgUrl3 = json['imgUrl3'],
        _isBest = int.parse(json['isBest']),
        _isNew = int.parse(json['isNew']),
        _cumulBuyCount = int.parse(json['cumulBuy']),
        _isReservation = int.parse(json['empty']) == 1 ? true : false;

  int get prodID => _prodID;

  set prodID(int value) {
    _prodID = value;
  }

  String get prodName => _prodName;

  int get cumulBuyCount => _cumulBuyCount;

  set cumulBuyCount(int value) {
    _cumulBuyCount = value;
  }

  int get isNew => _isNew;

  set isNew(int value) {
    _isNew = value;
  }

  bool get isReservation => _isReservation;

  set isReservation(bool value) {
    _isReservation = value;
  }

  int get isBest => _isBest;

  set isBest(int value) {
    _isBest = value;
  }

  String get imgUrl3 => _imgUrl3;

  set imgUrl3(String value) {
    _imgUrl3 = value;
  }

  String get imgUrl2 => _imgUrl2;

  set imgUrl2(String value) {
    _imgUrl2 = value;
  }

  String get imgUrl1 => _imgUrl1;

  set imgUrl1(String value) {
    _imgUrl1 = value;
  }

  double get discount => _discount;

  set discount(double value) {
    _discount = value;
  }

  int get stockCount => _stockCount;

  set stockCount(int value) {
    _stockCount = value;
  }

  int get price => _price;

  set price(int value) {
    _price = value;
  }

  int get category => _category;

  set category(int value) {
    _category = value;
  }

  String get prodInfo => _prodInfo;

  set prodInfo(String value) {
    _prodInfo = value;
  }

  set prodName(String value) {
    _prodName = value;
  }
}
