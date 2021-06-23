import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ParsingTest extends StatefulWidget {
  @override
  _ParsingTestState createState() => _ParsingTestState();
}

class _ParsingTestState extends State<ParsingTest> {
  List<dynamic> contentList = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    connectHttp();
  }

  connectHttp() async {
    String url =
        "http://test.amisian.com/test.php?menugrp=?menugrp=030100&searchMasterSid=3";
    var response = await http.get(url);
    var statusCode = response.statusCode;
    var responseHeaders = response.headers;
    String responseBody = utf8.decode(response.bodyBytes);

    print(statusCode);
    print(responseHeaders);
    print(responseBody);
    Map<dynamic, dynamic> list = jsonDecode(responseBody);
    print(list['info']['list'][0]['name']);
    contentList = list['info']['list'];
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          return _loading
              ? Container()
              : ListTile(
                  onTap: () {
                    print(contentList[index]['content']);
                    // print(contentList[index]['fileList'][0]['fileLink']);
                    // launch(contentList[index]['fileList'][0]['fileLink']);
                  },
                  title: Text(contentList[index]['title']),
                  subtitle: Text(
                      '작성자 :${contentList[index]['name']}, 조회수 : ${contentList[index]['viewCount']} \n${contentList[index]['regdate']}'),
                isThreeLine: true,);
        },
        itemCount: contentList.length,
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
