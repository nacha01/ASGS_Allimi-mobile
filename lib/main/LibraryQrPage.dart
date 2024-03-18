import 'dart:convert';
import 'dart:io';

import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
import 'package:asgshighschool/util/ToastMessage.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../data/user.dart';

class LibraryAttendanceQrPage extends StatefulWidget {
  final User admin;

  const LibraryAttendanceQrPage({required this.admin, Key? key})
      : super(key: key);

  @override
  State<LibraryAttendanceQrPage> createState() =>
      _LibraryAttendanceQrPageState();
}

class _LibraryAttendanceQrPageState extends State<LibraryAttendanceQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  TextEditingController _adminKeyController = TextEditingController();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    }
    _controller!.resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) async {
    this._controller = controller;
    await _controller!.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      await _controller!.pauseCamera();
      List<String> parsed = scanData.code!.split("_");
      if (parsed[0] == "ATTENDANCE")
        await _requestAttendance(parsed);
      else {
        ToastMessage.show("출석용 QR이 아닙니다.");
        await Future.delayed(Duration(milliseconds: 1500));
        await _controller!.resumeCamera();
      }
    });
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.7;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 8,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Future<void> _requestAttendance(List<String> parsedQrData) async {
    String url = "${ApiUtil.API_HOST}arlimi_requestAttendance.php";

    final response = await http.post(Uri.parse(url), body: <String, String>{
      "uid": parsedQrData[1],
      "purpose": parsedQrData[0]
    });

    if (response.statusCode == 200) {
      var json =
          jsonDecode(response.body.substring(response.body.indexOf("{\"n")));
      showDialog(
          context: context,
          builder: (context) {
            // 1.5초 후에 자동으로 종료
            Future.delayed(Duration(milliseconds: 1500), () async {
              Navigator.pop(context);
              await _controller!.resumeCamera();
            });
            return AlertDialog(
              title: Text(
                '도서관 출입 정보',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "학번: ${parsedQrData[2]}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  Text("이름: ${parsedQrData[3]}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.03),
                    child: Text(
                      json["newState"] == "ENTRANCE" ? "입실" : "퇴실",
                      style: TextStyle(
                          color: json["newState"] == "ENTRANCE"
                              ? Colors.green
                              : Colors.red,
                          fontSize: 28),
                    ),
                  ),
                  Text(
                    DateTime.now().toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          });
    } else if (response.statusCode == 403) {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 3), () async {
              Navigator.pop(context);
              await _controller!.resumeCamera();
            });
            return AlertDialog(
              title: Icon(
                Icons.warning,
                color: Colors.red,
                size: 65,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '현재는 도서관 출입 가능 시간이 아닙니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text('출입 가능 시간: \n오전 5시 ~ 9시\n오후 5시 ~ 9시',
                      style: TextStyle(fontSize: 15))
                ],
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AdminUtil.showCertifyDialog(
            context: context,
            keyController: _adminKeyController,
            admin: widget.admin,
            afterProcess: () async {
              Navigator.pop(context);
            });
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(
            barTitle: "도서관 출입 QR 스캐너",
            leadingClick: () {
              AdminUtil.showCertifyDialog(
                  context: context,
                  keyController: _adminKeyController,
                  admin: widget.admin,
                  afterProcess: () async {
                    Navigator.pop(context);
                  });
            }),
        body: _buildQrView(context),
      ),
    );
  }
}
