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
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02,),
                  Container(
                      width: size.width * 0.95,
                      height: size.height * 0.35,
                      child: Image.network(
                        widget.product.imgUrl1,
                        fit: BoxFit.fill,
                      )),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),
                  Text('${widget.product.prodName}',textScaleFactor: 3,),
                  Text('${widget.product.prodInfo}',textScaleFactor: 3),

                ],
              ),
            ),
          ),
          Container(color: Colors.blue, width: size.width, height: size.height * 0.15,)

        ],
      ),
    );
  }
}
