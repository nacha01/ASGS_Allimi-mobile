import 'dart:io';

import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
  Barcode? _result;
  QRViewController? _controller;
  bool _isScanned = false;
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

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanned) {
        setState(() {
          _isScanned = true;
          _result = scanData;
          // var res = _queryQrInformation(_result.code);
        });
      }
    });
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.6;
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
