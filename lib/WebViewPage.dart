import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'data/user.dart';
import 'main/HomePage.dart';


class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, this.user,  this.title,  this.baseUrl,  }) : super(key: key);
  final String? baseUrl;
  final String? title;
  final User? user;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

   final bool isTab = false;
   InAppWebViewController? _inAppWebViewController;
  static const platform = MethodChannel('asgs');
  final GlobalKey webViewKey = GlobalKey();

    late InAppWebViewController webViewController;
    PullToRefreshController? pullToRefreshController;
  double progress = 0;
  @override
  void initState() {
    super.initState();

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(
              urlRequest: URLRequest(url: await webViewController.getUrl()));
        }
      },
    ));
  }
  @override
  Widget build(BuildContext context) {
    Uri? myUrl = Uri.parse(widget.baseUrl!);  //???
    print("왜 넘어온 것ㅇ 없는 거야 $widget.baseUrl");
    print("WebViewPage 초기 화면 ppp");
    print(myUrl);

    return Scaffold(

        appBar: AppBar(
          title: Text(widget.title!),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                HomePageState.tabController!.index = 0;
              }),
        ),
        body: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: myUrl),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                javaScriptCanOpenWindowsAutomatically: true,
                javaScriptEnabled: true,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                verticalScrollBarEnabled: true,
                userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'
            ),
            android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                allowContentAccess: true,
                builtInZoomControls: true,
                thirdPartyCookiesEnabled: true,
                allowFileAccess: true,
                supportMultipleWindows: true
            ),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
              allowsBackForwardNavigationGestures: true,
            ),
          ),
          pullToRefreshController: pullToRefreshController,
          onLoadStart: (InAppWebViewController controller, uri) {
            setState(() {
              myUrl = uri;
            });
          },
          onLoadStop: (InAppWebViewController controller, uri) {
            setState(() {
              myUrl = uri;
            });
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController!.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
            });
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onWebViewCreated: (InAppWebViewController controller) {
            webViewController = controller;
          },
          onCreateWindow: (controller, createWindowRequest) async {
            showDialog(
              context: context, builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 400,
                  child: InAppWebView(
                    // Setting the windowId property is important here!
                    windowId: createWindowRequest.windowId,
                    initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        builtInZoomControls: true,
                        thirdPartyCookiesEnabled: true,
                      ),
                      crossPlatform: InAppWebViewOptions(
                          cacheEnabled: true,
                          javaScriptEnabled: true,
                          userAgent: "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                        allowsBackForwardNavigationGestures: true,
                      ),
                    ),
                    onCloseWindow: (controller) async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),);
            },
            );
            return true;
          },
        )
    );
  }
}
