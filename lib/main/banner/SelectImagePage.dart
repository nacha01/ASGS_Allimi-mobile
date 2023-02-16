import 'dart:convert';

import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/main/banner/AddImagePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectImagePage extends StatefulWidget {
  @override
  _SelectImagePageState createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage> {
  List _imageDataList = [];
  List<bool> _originSelectList = [];
  List<bool> _isSelectedList = [];
  String _prefixImgUrl = 'http://nacha01.dothome.co.kr/sin/arlimi_image/';

  Future<bool> _getAllImageData() async {
    String url = '${ApiUtil.API_HOST}main_getAllImage.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      _isSelectedList.clear();
      _originSelectList.clear();
      _imageDataList.clear();

      List map1st = jsonDecode(result);
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = jsonDecode(map1st[i]);
        _isSelectedList
            .add(int.parse(map1st[i]['isSelected']) == 1 ? true : false);
        _originSelectList
            .add(int.parse(map1st[i]['isSelected']) == 1 ? true : false);
      }
      setState(() {
        _imageDataList = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateSelectionState(String? num, int value) async {
    String url = '${ApiUtil.API_HOST}main_updateSelectState.php';
    final response = await http.post(Uri.parse(url),
        body: <String, String?>{'selection': value.toString(), 'num': num});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void _updateSelection() async {
    for (int i = 0; i < _imageDataList.length; ++i) {
      if (_isSelectedList[i] != _originSelectList[i]) {
        await _updateSelectionState(
            _imageDataList[i]['no'], _isSelectedList[i] ? 1 : 0);
      }
    }
  }

  @override
  void initState() {
    _getAllImageData();
    super.initState();
  }

  @override
  void dispose() {
    _updateSelection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(
        barTitle: '알리미 배너 사진 관리페이지',
        actions: [
          IconButton(
              onPressed: () async {
                var res = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddImagePage()));
                if (res) {
                  await _getAllImageData();
                }
              },
              icon: Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.black,
                size: 30,
              ))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '* 체크박스의 의미는 "이미지를 사용할 것인가"의 의미입니다.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 12),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Expanded(
                child: _imageDataList.length == 0
                    ? Center(
                        child: Text(
                        '등록된 사진이 없습니다!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: size.height * 0.025,
                            crossAxisSpacing: size.width * 0.015),
                        itemBuilder: (context, index) {
                          return _eachItemLayout(
                              _imageDataList[index], size, index);
                        },
                        itemCount: _imageDataList.length,
                      ))
          ],
        ),
      ),
    );
  }

  Widget _eachItemLayout(Map data, Size size, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: _prefixImgUrl + data['imgName'],
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Text('error');
                },
              ),
            ],
          ),
        ),
        IconButton(
            onPressed: () {
              setState(() {
                _isSelectedList[index] = !_isSelectedList[index];
              });
            },
            icon: Icon(
              _isSelectedList[index]
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.blue,
            ))
      ],
    );
  }
}
