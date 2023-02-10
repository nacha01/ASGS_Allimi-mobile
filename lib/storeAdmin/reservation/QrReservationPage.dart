import 'dart:convert';
import 'dart:io';
import 'package:asgshighschool/data/user.dart';
import 'FinalReservationPage.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrReservationPage extends StatefulWidget {
  final User? user;

  QrReservationPage({this.user});

  @override
  _QrReservationPageState createState() => _QrReservationPageState();
}

class _QrReservationPageState extends State<QrReservationPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  QRViewController? controller;
  List _readyStateResvList = [];
  bool _isUsed = false;

  /// QR 코드로 예약 처리를 하기 위한 해당 예약 정보들을 요청하는 작업
  /// orderState == 2 && resvState == 2 인 데이터만 포함
  Future<bool> _getReservationQRState() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getQrForResv.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      _readyStateResvList.clear();
      List map1st = json.decode(result);
      for (int i = 0; i < map1st.length; ++i) {
        _readyStateResvList.add(json.decode(map1st[i]));
        for (int j = 0; j < _readyStateResvList[i]['detail'].length; ++j) {
          _readyStateResvList[i]['detail'][j] =
              json.decode(_readyStateResvList[i]['detail'][j]);
          _readyStateResvList[i]['detail'][j]['pInfo'] =
              json.decode(_readyStateResvList[i]['detail'][j]['pInfo']);
        }
      }
      print(_readyStateResvList);
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
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getReservationQRState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '예약 QR Reader',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        body: Column(
          children: [
            Expanded(flex: 2, child: _buildQrView(context)),
            Expanded(
                flex: 1,
                child: Column(
                  children: [
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
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: Text(
                        '예약 QR 코드를 찍으십시오',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    )
                  ],
                ))
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
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      if (!_isUsed) {
        _isUsed = true;
        for (int i = 0; i < _readyStateResvList.length; ++i) {
          if (_readyStateResvList[i]['oID'] == result.code) {
            print('find');
            var res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FinalReservationPage(
                          user: widget.user,
                          data: _readyStateResvList[i],
                        )));
            if (res) {
              _getReservationQRState();
              _isUsed = false;
            }
            return;
          }
        }
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('예약 인증 실패'),
                  content: Text(
                    'QR 코드에 해당하는 예약 정보를 찾지 못했습니다!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          _isUsed = false;
                          Navigator.pop(context);
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                ));
      }
    });
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
