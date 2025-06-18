import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/asset_cache_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Start the process of preparing the self-contained data URL.
    // This will be instant if the model has already been viewed once.
    _preparedGltfDataUrlFuture =
        AssetCacheService.instance.getPreparedGltfDataUrl(widget.asset);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _preparedGltfDataUrlFuture,
      builder: (context, snapshot) {
        // Case 1: Still preparing the data URL (only happens on first load)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting, we show a simple spinner. The ModelViewer's `poster`
          // property will be responsible for showing the placeholder image.
          return const Center(child: CircularProgressIndicator());
        }

        // Case 2: An error occurred during preparation
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 48),
          );
        }

        // Case 3: Success! We have the prepared data URL.
        // --- START OF FIX ---
        // The ModelViewer now fills its parent container, ensuring the final
        // 3D object is full-size.
        return ModelViewer(
          src: snapshot.data!,
          poster: widget.placeholder,
          loading: Loading.eager,
          reveal: Reveal.auto,
          alt: "A 3D model",
          ar: true,
          autoRotate: false,
          cameraControls: true,
          disableZoom: true,
          disablePan: true,
          backgroundColor: Colors.transparent,
          // This attribute adjusts the initial camera view. The third value is the
          // radius (distance from the object). A smaller value "zooms in".
          // The '100%' value makes the object fit the vertical viewport.
          // You can adjust this to best match your placeholder's scale.
          cameraOrbit: "0deg 75deg 90%",
        );
      },
    );
  }
}
