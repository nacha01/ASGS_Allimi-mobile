import 'dart:convert';
import 'dart:io';
import 'package:asgshighschool/data/user.dart';
import '../../component/DefaultButtonComp.dart';
import 'ScanInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrSearchScannerPage extends StatefulWidget {
  final User? admin;

  QrSearchScannerPage({this.admin});

  @override
  _QrSearchScannerPageState createState() => _QrSearchScannerPageState();
}

class _QrSearchScannerPageState extends State<QrSearchScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode _result;
  QRViewController? _qrViewController;
  bool _isScanned = false;

  Future<User?> _getUserInfo(String? uid) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getOneUser.php';
    final response = await http.get(Uri.parse(url + "?uid=$uid"));
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != 'NOT EXIST ACCOUNT') {
        return User.fromJson(jsonDecode(result));
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> _queryQrInformation(String? scannedValue) async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_queryOrderInfo.php';
    final response =
        await http.post(Uri.parse(url), body: <String, String?>{'oid': scannedValue});

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result.contains('No Exist')) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                    size: 75,
                  ),
                  actionsPadding: EdgeInsets.all(0),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '존재하지 않는 주문입니다!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  actions: [
                    DefaultButtonComp(
                        onPressed: () {
                          _isScanned = false;
                          Navigator.pop(context);
                        },
                        child: Text('확인'))
                  ],
                ));
        return false;
      } else {
        Map order = jsonDecode(result);
        for (int i = 0; i < order['detail'].length; ++i) {
          order['detail'][i] = jsonDecode(order['detail'][i]);
          order['detail'][i]['pInfo'] = jsonDecode(order['detail'][i]['pInfo']);
        }
        print(order);
        User? user = await _getUserInfo(order['uID']);
        if (user == null) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Icon(
                      Icons.error,
                      color: Colors.orange,
                      size: 75,
                    ),
                    actionsPadding: EdgeInsets.all(0),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '주문자 정보를 불러올 수 없습니다!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    actions: [
                      DefaultButtonComp(
                          onPressed: () {
                            _isScanned = false;
                            Navigator.pop(context);
                          },
                          child: Text('확인'))
                    ],
                  ));
        }
        // print(order['detail'][0]['pInfo']['pName']);
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ScanInfoPage(
                      orderData: order,
                      user: user,
                      admin: widget.admin,
                    )));
        _isScanned = false;
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrViewController!.pauseCamera();
    }
    _qrViewController!.resumeCamera();
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
          body: Column(children: [
        Expanded(flex: 2, child: _buildQrView(context)),
        Expanded(
            flex: 1,
            child: Column(children: <Widget>[
              SizedBox(
                height: size.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.14,
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 0.5, color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF9EE1E5)),
                        child: IconButton(
                          iconSize: size.width * 0.08,
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _qrViewController?.toggleFlash();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.flash_on,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.14,
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 0.5, color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF9EE1E5)),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _qrViewController?.flipCamera();
                            setState(() {});
                          },
                          icon: Icon(Icons.flip_camera_android),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.14,
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 0.5, color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF9EE1E5)),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _qrViewController?.pauseCamera();
                          },
                          icon: Icon(Icons.pause),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(3),
                        width: size.width * 0.14,
                        height: size.height * 0.07,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 0.5, color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF9EE1E5)),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await _qrViewController?.resumeCamera();
                          },
                          icon: Icon(Icons.play_arrow),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Divider(),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    'QR 코드를 스캔하세요.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Colors.black26),
                          borderRadius: BorderRadius.circular(10)),
                      child: DefaultButtonComp(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            '뒤로가기',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                  SizedBox(
                    width: size.width * 0.05,
                  ),
                ],
              )),
            ])),
      ])),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._qrViewController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanned) {
        setState(() {
          _isScanned = true;
          _result = scanData;
          // var test = '1652328498519';
          // var test2 = '1655959318117';
          // var test3 = '1656375228115';
          var res = _queryQrInformation(_result.code);
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _qrViewController?.dispose();
    super.dispose();
  }
}
