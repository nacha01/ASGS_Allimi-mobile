import 'dart:convert';
import 'dart:io';

import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
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
      await _requestAttendance(scanData.code!);
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

  Future<void> _requestAttendance(String qrData) async {
    String url = "${ApiUtil.API_HOST}arlimi_requestAttendance.php";

    List<String> parsed = qrData.split("_");

    final response = await http.post(Uri.parse(url),
        body: <String, String>{"uid": parsed[1], "purpose": parsed[0]});

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 5), () async {
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
                    "학번: ${parsed[2]}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  Text("이름: ${parsed[3]}",
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
