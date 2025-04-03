import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

Widget objectViewerPreview() {
  Flutter3DController controller = Flutter3DController();
  controller.onModelLoaded.addListener(() async {
    debugPrint('model is loaded : ${controller.onModelLoaded.value}');
  });
  return IgnorePointer(
      child: SizedBox(
    height: 400,
    child: Flutter3DViewer(
        //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
        //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
        //the default value is true
        activeGestureInterceptor: false,
        //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
        //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
        progressBarColor: Colors.black,
        //You can disable viewer touch response by setting 'enableTouch' to 'false'
        enableTouch: false,
        //This callBack will return the loading progress value between 0 and 1.0
        onProgress: (double progressValue) {
          debugPrint('model loading progress : $progressValue');
        },
        //This callBack will call after model loaded successfully and will return model address
        onLoad: (String modelAddress) {
          debugPrint('model loaded : $modelAddress');
        },
        //this callBack will call when model failed to load and will return failure error
        onError: (String error) {
          debugPrint('model failed to load : $error');
        },
        src: 'assets/3d/deins_card4.glb',
        controller: controller),
  ));
}
