import 'dart:async';

import 'package:asgshighschool/Screens/HomePage.dart';
import 'package:asgshighschool/web_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class WebViewPage extends StatefulWidget {
  String baseUrl;
  String title;
  var books;
  final FirebaseUser user;
  WebViewPage({Key key, this.baseUrl, this.title, this.books, this.user}) : super(key: key);
  static const routeName = '/webpage';

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _web_loading = true;
  Timer _timer;
  int _loading = 1;
  bool _isFinished = false;
  double _opacity = 1.0;
  bool _isExceed = false;
  bool _oneTurn = false;
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)
          => HomePage(books: widget.books,user:  widget.user,)));
        }),
      ),
      body: Stack(children: [
        Opacity(
          opacity: _opacity,
          child: WebView(
            onPageStarted: (start) async {
              print('page start!');
              _isFinished = false;
              if (!_oneTurn) {
                int limit = 2;
                const oneSec = const Duration(seconds: 1);
                _timer = Timer.periodic(oneSec, (timer) async {
                  if (limit == 0 && _isFinished) {
                    print('time safe');
                    setState(() {
                      timer.cancel();
                      _loading = 2;
                      _isExceed = false;
                      _oneTurn = true;
                      return;
                    });
                  } else if (limit == 0 && !_isFinished) {
                    print('time exceed');
                    setState(() {
                      timer.cancel();
                      _loading = 1;
                      _isExceed = true;
                      //_opacity = 0.0;
                      _oneTurn = true;
                      return;
                    });
                  } else {
                    print('counting!');
                    //setState(() {
                    limit--;
                    //});
                  }
                });
              }
              // setState(() {
              //   _web_loading = true;
              //   print('ll');
              //   _loading = 1;
              // });
            },
            onPageFinished: (finish) {
              print('page finish!');
              setState(() {
                _web_loading = false;
                _isFinished = true;
                if (!_isExceed) {
                  _loading = 2;
                }
              });
            },
            initialUrl: widget.baseUrl,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
        getWebState()
        // _web_loading
        //     ? Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : Stack()

        //_loading == 1 ? Center(child: CircularProgressIndicator(),) : _loading == 0 ? Center(child: Text('에러 발생 재시도 바람'),) : Stack()
      ]),
    );
  }

  Widget getWebState() {
    if (_loading == 1 && !_isExceed) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_loading == 2) {
      return Stack();
    } else if (_loading == 1 && _isExceed) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '에러 발생 재시도 바람',
          style: TextStyle(fontSize: 30),
        ),
        Container(
          child: RaisedButton(
              child: Text(
                'retry',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _loading = 1;
                  _isFinished = false;
                  _opacity = 1.0;
                  _isExceed = false;
                  _oneTurn = false;
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WebViewPage(
                                title: widget.title,
                                baseUrl: widget.baseUrl,
                              )));
                });
              }),
        )
      ]));
    }
  }
}
