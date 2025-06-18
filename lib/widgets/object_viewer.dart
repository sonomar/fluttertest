import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/asset_cache_service.dart';

// The static ID constant is no longer needed.

class ObjectViewer extends StatefulWidget {
  final String asset;
  final String placeholder;

  const ObjectViewer(
      {super.key, required this.asset, required this.placeholder});

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
            // --- Layer 1 (Bottom): The Placeholder ---
            if (!_isModelRendered && !hasError)
              CachedNetworkImage(
                imageUrl: widget.placeholder,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),

            // --- Layer 2 (Top): The 3D Model Viewer ---
            if (srcIsReady)
              ModelViewer(
                // The `id` property is no longer needed.
                src: snapshot.data!,
                onWebViewCreated: (WebViewController controller) {
                  controller.addJavaScriptChannel(
                    'ModelViewerChannel',
                    onMessageReceived: (message) {
                      if (message.message == 'load' &&
                          mounted &&
                          !_isModelRendered) {
                        setState(() {
                          _isModelRendered = true;
                        });
                      } else {
                        // Add a print statement to see any other messages for debugging.
                        debugPrint('Message from WebView: ${message.message}');
                      }
                    },
                  );
                  // --- CORRECTED: Using a more robust tag name selector ---
                  controller.runJavaScript('''
                    document.addEventListener('DOMContentLoaded', () => {
                      // Select the model-viewer element by its tag name.
                      const modelViewer = document.querySelector('model-viewer');
                      
                      if (modelViewer) {
                          modelViewer.addEventListener('load', () => {
                            ModelViewerChannel.postMessage('load');
                          }, { once: true });
                      } else {
                          // Send an error back if the element is not found.
                          ModelViewerChannel.postMessage('error: model-viewer element not found');
                      }
                    });
                  ''');
                },
                backgroundColor: Colors.transparent,
                alt: "A 3D model",
                ar: false,
                disablePan: true,
                disableZoom: true,
                disableTap: true,
                autoRotate: false,
                cameraControls: true,
                cameraOrbit: "0deg 75deg 90%",
              ),

            // --- The Error Icon ---
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
