// lib/widgets/object_viewer.dart

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/asset_cache_service.dart';

class ObjectViewer extends StatefulWidget {
  final String asset;
  final String placeholder;
  final bool isFront;

  const ObjectViewer(
      {super.key,
      required this.asset,
      required this.placeholder,
      this.isFront = false});

  @override
  ObjectViewerState createState() => ObjectViewerState();
}

class ObjectViewerState extends State<ObjectViewer> {
  late final Future<String?> _preparedGltfDataUrlFuture;
  bool _isModelRendered = false;

  @override
  void initState() {
    super.initState();
    _preparedGltfDataUrlFuture =
        AssetCacheService.instance.getPreparedGltfDataUrl(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _preparedGltfDataUrlFuture,
      builder: (context, snapshot) {
        final bool srcIsReady =
            snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null;
        final bool hasError = snapshot.hasError ||
            (snapshot.connectionState == ConnectionState.done && !srcIsReady);

        return Stack(
          alignment: Alignment.center,
          children: [
            if (!_isModelRendered && !hasError)
              CachedNetworkImage(
                imageUrl: widget.placeholder,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            if (srcIsReady)
              ModelViewer(
                src: snapshot.data!,
                relatedCss: '''
                  model-viewer {
                    --progress-bar-color: none !important;
                    --progress-bar-height: 0px !important;
                  }
                ''',
                onWebViewCreated: (WebViewController controller) {
                  // 1. Add the channel immediately so it's ready.
                  controller.addJavaScriptChannel(
                    'ModelViewerChannel',
                    onMessageReceived: (message) {
                      debugPrint('Message from WebView: ${message.message}');
                      if (message.message == 'load' &&
                          mounted &&
                          !_isModelRendered) {
                        setState(() {
                          _isModelRendered = true;
                        });
                      }
                    },
                  );

                  // 2. Set a NavigationDelegate to listen for page events.
                  controller.setNavigationDelegate(
                    NavigationDelegate(
                      // --- THIS IS THE KEY ---
                      // This callback fires when the WebView has finished loading the page.
                      onPageFinished: (String url) {
                        // 3. Now it is safe to run our JavaScript.
                        controller.runJavaScript('''
                          try {
                            const modelViewer = document.querySelector('model-viewer');
                            if (modelViewer) {
                              modelViewer.addEventListener('load', () => {
                                ModelViewerChannel.postMessage('load');
                              }, { once: true });
                            } else {
                              ModelViewerChannel.postMessage('error: element_not_found');
                            }
                          } catch (e) {
                            ModelViewerChannel.postMessage('error: ' + e.toString());
                          }
                        ''');
                      },
                      // Optional: Catch web-related errors.
                      onWebResourceError: (WebResourceError error) {
                        debugPrint(
                            'Page resource error: ${error.errorCode}, ${error.description}');
                      },
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                alt: "A 3D model",
                ar: false,
                disablePan: true,
                disableZoom: true,
                disableTap: true,
                autoRotate: widget.isFront ? true : false,
                cameraControls: widget.isFront ? false : true,
                cameraOrbit: "0deg 75deg 90%",
              ),
            if (hasError)
              const Center(
                child: Icon(Icons.error, color: Colors.red, size: 48),
              ),
          ],
        );
      },
    );
  }
}
