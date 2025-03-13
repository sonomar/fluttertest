import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

class Collectible extends StatefulWidget {
  const Collectible({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  State<Collectible> createState() => _CollectibleState();
}

class _CollectibleState extends State<Collectible> {
  static String htex = '''
<!DOCTYPE html>
<html>
<head>
<title>Navigation Delegate Example</title>
</head>
<body>
<script type="module" src="https://unpkg.com/@splinetool/viewer@1.9.67/build/spline-viewer.js"></script>
<p>
testing the 3d object
</p>
<section>
<spline-viewer url="https://prod.spline.design/eheIcYVufO0F7Oer/scene.splinecode"></spline-viewer>
</section>
</body>
</html>
''';

  final controller = WebViewController()
    // ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadHtmlString(htex);
  // ..setNavigationDelegate(NavigationDelegate(
  //     onNavigationRequest: (change) => NavigationDecision.navigate));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.selectedCollectible["name"])),
      body: WebViewWidget(controller: controller),
    );
  }
}
