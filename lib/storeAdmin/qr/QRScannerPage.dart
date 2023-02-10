import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QRScannerPage extends StatefulWidget {
  QRScannerPage({this.oID});

  final String? oID;

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _isForValidate = false;
  bool _completed = false;
  bool _isUsed = false;
  bool _isChecked = false;

  Future<bool> _orderCompleteRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_completeOrder.php';
    final response = await http.get(Uri.parse(url + '?oid=${widget.oID}'));

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      return false;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    _isForValidate = widget.oID == null ? false : true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_isChecked) {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, false);
        }
        return false;
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(flex: 2, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
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
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF9EE1E5)),
                            child: IconButton(
                              iconSize: size.width * 0.08,
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                await controller?.toggleFlash();
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
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF9EE1E5)),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                await controller?.flipCamera();
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
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF9EE1E5)),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                await controller?.pauseCamera();
                              },
                              icon: Icon(Icons.pause),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(3),
                            width: size.width * 0.14,
                            height: size.height * 0.07,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(12),
                                color: Color(0xFF9EE1E5)),
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                await controller?.resumeCamera();
                              },
                              icon: Icon(Icons.play_arrow),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.015,
                  ),
                  Divider(),
                  if (result != null)
                    Expanded(
                      child: Column(
                        children: [
                          _completed
                              ? Column(
                                  children: [
                                    Text(
                                      'QR 코드 인증 완료\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      '올바른 주문임이 인증되었습니다. [${result!.code}]',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      'QR 코드 인증 실패\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                    Text(
                                      '올바른 주문 번호가 아닙니다. [${result!.code}]',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: size.height * 0.015,
                          ),
                          //Barcode Type: ${describeEnum(result.format)}
                          _completed
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: () {
                                              if (_isChecked)
                                                Navigator.pop(context, true);
                                              else
                                                Navigator.pop(context, false);
                                            },
                                            child: Text(
                                              '뒤로가기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: _isChecked
                                                ? null
                                                : () async {
                                                    await showDialog(
                                                        context: context,
                                                        builder:
                                                            (ctx) =>
                                                                AlertDialog(
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          var res =
                                                                              await _orderCompleteRequest();
                                                                          if (res) {
                                                                            Fluttertoast.showToast(
                                                                                msg: '성공적으로 주문 완료 처리 되었습니다.',
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                toastLength: Toast.LENGTH_SHORT);
                                                                            setState(() {
                                                                              _isChecked = !_isChecked;
                                                                            });
                                                                          } else {
                                                                            Fluttertoast.showToast(
                                                                                msg: '주문 완료 처리에 실패하였습니다.',
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                toastLength: Toast.LENGTH_SHORT);
                                                                          }
                                                                          Navigator.pop(
                                                                              ctx);
                                                                        },
                                                                        child: Text(
                                                                            '예')),
                                                                    TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.pop(
                                                                                ctx),
                                                                        child: Text(
                                                                            '아니오'))
                                                                  ],
                                                                  title: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    size: 40,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  content: Text(
                                                                    '※ 정말 상품 수령이 완료되었고, 주문 완료 처리될 상태가 맞습니까?',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ));
                                                  },
                                            child: Text(
                                              '주문완료 처리 하기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _isChecked
                                                      ? Colors.grey
                                                      : Colors.blue),
                                            ))),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(
                                              '뒤로가기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                _completed = false;
                                                _isUsed = false;
                                                result = null;
                                              });
                                              await controller?.resumeCamera();
                                            },
                                            child: Text(
                                              '다시 스캔하기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                  ],
                                ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                        child: Column(
                      children: [
                        Text(
                          'QR 코드를 스캔하세요.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: size.height * 0.03,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  '뒤로가기',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                      ],
                    )),
                ],
              ),
            )
          ],
        ),
      ),
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
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        _completed = result!.code == widget.oID ? true : false;
        if (!_isUsed) _showValidDialog(result!.code);
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }

  void _showValidDialog(String? result) {
    _isUsed = true;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
              actionsPadding: EdgeInsets.all(2),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '확인',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
              title: _completed
                  ? Icon(
                      Icons.check_sharp,
                      size: 45,
                      color: Colors.greenAccent,
                    )
                  : Icon(
                      Icons.warning_amber_outlined,
                      size: 45,
                      color: Colors.red,
                    ),
              content: _completed
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '주문 번호 인증 완료되었습니다!\n [QR 코드 인식 결과]',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('옳지 않은 주문 번호입니다!\n [QR 코드 인식 결과]',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
            ));
  }
}
