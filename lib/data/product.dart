class Product {
  int prodID;
  String? prodName;
  String? prodInfo;
  int category;
  int price;
  int stockCount;
  double discount;
  String? imgUrl1;
  String? imgUrl2;
  String? imgUrl3;
  int isBest;
  int isNew;
  int cumulBuyCount;
  bool isReservation;

  Product(
      this.prodID,
      this.prodName,
      this.prodInfo,
      this.category,
      this.price,
      this.stockCount,
      this.discount,
      this.imgUrl1,
      this.imgUrl2,
      this.imgUrl3,
      this.isBest,
      this.isNew,
      this.cumulBuyCount,
      this.isReservation);

  Product.fromJson(Map<String, dynamic> json)
      : prodID = int.parse(json['prodID']),
        prodName = json['prodName'],
        prodInfo = json['prodInfo'],
        category = int.parse(json['category']),
        price = int.parse(json['price']),
        stockCount = int.parse(json['stockCount']),
        discount = double.parse(json['discount']),
        imgUrl1 = json['imgUrl1'],
        imgUrl2 = json['imgUrl2'],
        imgUrl3 = json['imgUrl3'],
        isBest = int.parse(json['isBest']),
        isNew = int.parse(json['isNew']),
        cumulBuyCount = int.parse(json['cumulBuy']),
        isReservation = int.parse(json['empty']) == 1 ? true : false;
}
