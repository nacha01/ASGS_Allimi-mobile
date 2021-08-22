import 'package:asgshighschool/data/product_data.dart';
import 'package:flutter/material.dart';

class DetailProductPage extends StatefulWidget {
  DetailProductPage({this.product});
  final Product product;
  @override
  _DetailProductPageState createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.clear,color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text('PRODUCT ID : ${widget.product.prodID}'),
      ),
    );
  }
}
