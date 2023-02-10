package asgs.high.arlimi;

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "asgs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAppUrlForAndroid") {
                try {
                    val url = call.argument<String>("url")
                    val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                    result.success(intent.dataString)
                } catch (e: Exception) {
                    result.notImplemented()
                }
            } else if (call.method == "getMarketUrlForAndroid") {
                try {
                    val url = call.argument<String>("url");
                    val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)

                    var packageName = intent.`package`
                    if (packageName != null) {
                        result.success("market://details?id=" + packageName)
                    }
                    result.notImplemented()
                } catch (e: Exception) {
                    result.notImplemented()
                }
            }
        }
    }
}
