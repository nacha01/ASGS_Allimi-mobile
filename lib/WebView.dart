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
  @override
  Widget build(BuildContext context) {
    var cur_loading = Provider.of<LoadingData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebView(
        onPageFinished: (finish) {
          cur_loading.toggle();
        },
        initialUrl: widget.baseUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
