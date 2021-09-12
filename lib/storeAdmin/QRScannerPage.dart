import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:asgshighschool/storeAdmin/CheckOrderPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.black26),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.black26),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.black26),
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
                              border:
                                  Border.all(width: 0.5, color: Colors.black26),
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
                if (result != null)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'QR 코드 인식 완료 / 주문 번호 [${result.code}]',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        //Barcode Type: ${describeEnum(result.format)}
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.black26),
                                borderRadius: BorderRadius.circular(10)),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckOrderPage(
                                                orderID: result.code,
                                              )));
                                },
                                child: Text(
                                  '주문 조회하러 가기',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                      child: Text(
                    'QR 코드를 스캔하세요.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )),
              ],
            ),
          )
        ],
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
}
