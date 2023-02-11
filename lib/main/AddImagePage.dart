import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../component/DefaultButtonComp.dart';

class AddImagePage extends StatefulWidget {
  @override
  _AddImagePageState createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  PickedFile? _selectedImage;

  Future<void> _getImageFromGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  Future<bool> _storeImage(PickedFile img, String fileName) async {
    var request = http.MultipartRequest('POST',
        Uri.parse('http://nacha01.dothome.co.kr/sin/main_storeImage.php'));
    var picture = await http.MultipartFile.fromPath('imgFile', img.path,
        filename: fileName + '.jpg');
    request.files.add(picture);
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      if (responseString.contains('SUCCESS')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> _insertImageInfo(DateTime current, String fileName) async {
    String url = 'http://nacha01.dothome.co.kr/sin/main_addImageInfo.php';
    final response = await http.post(Uri.parse(url), body: <String, String>{
      'purpose': 'banner',
      'date': current.toString(),
      'imgName': '64_main' + fileName + '.jpg'
    });

    if (response.statusCode == 200) {
      if (response.body.contains('INSERTED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 정수 값의 날짜 혹은 시간을 두자리의 문자열로 formatting 하는 작업
  String _formatting(int value) {
    return value > 9 ? value.toString() : '0' + value.toString();
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
          leading: IconButton(
            onPressed: () => Navigator.pop(context, true),
            color: Colors.black,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '사진 추가하기',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Container(
                          width: size.width * 0.4,
                          height: size.height * 0.04,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.lightGreen),
                          child: DefaultButtonComp(
                              onPressed: () async {
                                await _getImageFromGallery();
                              },
                              child: Text(
                                '이미지 불러오기',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12),
                              )),
                        ),
                      ),
                    ],
                  ),
                  _selectedImage == null
                      ? Container(
                          width: size.width,
                          height: 210,
                          child: Text(
                            '이미지를 불러와주세요.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(width: 3, color: Colors.grey)),
                        )
                      : Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          width: size.width,
                          height: 210,
                        ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.03),
                    child: Text(
                      '* 위의 사진이 들어갈 크기는 배너사진에 들어갈 사진 크기 그대로입니다. 크기에 맞게 짤림등 사진을 조정해주시길 바랍니다.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    '※ 이전에 배너에 들어갔던 사진의 크기 : 850x403 ',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            DefaultButtonComp(
              onPressed: () async {
                var now = DateTime.now();
                String identified = _formatting(now.month) +
                    _formatting(now.day) +
                    _formatting(now.hour) +
                    _formatting(now.minute) +
                    _formatting(now.second);
                var img =
                    await _storeImage(_selectedImage!, 'main' + identified);
                if (img) {
                  var res = await _insertImageInfo(now, identified);
                  if (res) {
                    Fluttertoast.showToast(msg: '이미지 등록에 성공하였습니다.');
                    Navigator.pop(context, true);
                  } else {
                    Fluttertoast.showToast(msg: '이미지 등록에 실패하였습니다.');
                  }
                } else {
                  Fluttertoast.showToast(msg: 'image failed');
                }
              },
              child: Container(
                width: size.width,
                height: size.height * 0.04,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '저장하기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
