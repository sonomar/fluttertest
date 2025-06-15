import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ObjectViewer extends StatefulWidget {
  const ObjectViewer({
    super.key,
    required this.asset,
    required this.placeholder,
  });
  final String asset;
  final String placeholder;

  @override
  State<ObjectViewer> createState() => _ObjectViewerState();
}

class _ObjectViewerState extends State<ObjectViewer> {
  final Flutter3DController _controller = Flutter3DController();
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // --- 3D Viewer ---
        Flutter3DViewer(
          activeGestureInterceptor: true,
          progressBarColor: Colors.transparent,
          enableTouch: true,
          onProgress: (double progressValue) {
            // This is great for debugging to see that loading is happening.
            debugPrint('model loading progress : $progressValue');
          },
          onLoad: (String modelAddress) {
            print('testtesttest');
            debugPrint(
                'onLoad callback triggered: model loaded at $modelAddress');
            // Check if the widget is still mounted before calling setState
            if (mounted) {
              setState(() {
                _isModelLoaded = true;
              });
            }
          },
          onError: (String error) {
            debugPrint('model failed to load : $error');
            // Optionally, handle the error state in the UI
          },
          src: widget.asset,
          controller: _controller,
        ),

        // --- Placeholder ---
        IgnorePointer(
          ignoring:
              _isModelLoaded, // Also disable pointer events when not visible
          child: AnimatedOpacity(
              opacity: _isModelLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Image.network(
                    widget.placeholder,
                  ))),
        ),

        // --- Loading Indicator ---
        // if (!_isModelLoaded)
        //   const Center(
        //     child: CircularProgressIndicator(),
        //   ),
      ],
    );
  }
}
