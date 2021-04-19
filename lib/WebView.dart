import 'package:asgshighschool/web_loading.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class WebViewPage extends StatefulWidget {
  String baseUrl;
  String title;
  WebViewPage({Key key, this.baseUrl, this.title}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _web_loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: [
        WebView(
          onPageStarted: (start) {
            setState(() {
              _web_loading = true;
            });
          },
          onPageFinished: (finish) {
            setState(() {
              _web_loading = false;
            });
          },
          initialUrl: widget.baseUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
        _web_loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack()
      ]),
    );
  }
}
