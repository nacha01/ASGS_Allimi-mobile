class Product{
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
  String _isBest;
  String _isNew;
  int _cumulBuyCount;

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
      this._cumulBuyCount);

  int get prodID => _prodID;

  set prodID(int value) {
    _prodID = value;
  }

  String get prodName => _prodName;

  int get cumulBuyCount => _cumulBuyCount;

  set cumulBuyCount(int value) {
    _cumulBuyCount = value;
  }

  String get isNew => _isNew;

  set isNew(String value) {
    _isNew = value;
  }

  String get isBest => _isBest;

  set isBest(String value) {
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