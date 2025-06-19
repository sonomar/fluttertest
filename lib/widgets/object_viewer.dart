import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    _preparedGltfDataUrlFuture =
        AssetCacheService.instance.getPreparedGltfDataUrl(widget.asset);
  }

  // --- NEW AND IMPROVED build METHOD ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _preparedGltfDataUrlFuture,
      builder: (context, snapshot) {
        // Determine the state of the model loading process.
        final bool modelIsLoaded =
            snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null;

        // Determine if an error occurred.
        final bool hasError = snapshot.hasError ||
            (snapshot.connectionState == ConnectionState.done &&
                !modelIsLoaded);

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Show the placeholder image:
            //    This will only be visible while the model is loading and there's no error.
            if (widget.placeholder.isNotEmpty && !modelIsLoaded && !hasError)
              CachedNetworkImage(
                imageUrl: widget.placeholder,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),

            // 2. Show the 3D model:
            //    This is only added to the widget tree when the data is successfully loaded.
            //    When it appears, the placeholder above is removed in the same build frame.
            if (modelIsLoaded)
              ModelViewer(
                src: snapshot.data!,
                alt: "A 3D model",
                ar: false,
                disablePan: true,
                disableZoom: true,
                disableTap: true,
                autoRotate: false,
                cameraControls: true,
                cameraOrbit: "0deg 75deg 90%",
              ),

            // 3. Show an error icon:
            //    This is only added to the widget tree if the future fails.
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
