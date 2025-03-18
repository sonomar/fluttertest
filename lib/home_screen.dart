import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.qrcode});
  final String qrcode;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Widget sectionHeader(String header) {
  return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Stack(alignment: Alignment.center, children: [
        const Divider(height: 20, thickness: 1, color: Colors.grey),
        Text(header,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              backgroundColor: Colors.white,
            )),
      ]));
}

Widget objectViewer() {
  Flutter3DController controller = Flutter3DController();
  controller.onModelLoaded.addListener(() {
    debugPrint('model is loaded : ${controller.onModelLoaded.value}');
  });
  return SizedBox(
    height: 600,
    width: 300,
    child: Flutter3DViewer(
        //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
        //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
        //the default value is true
        activeGestureInterceptor: true,
        //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
        //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
        progressBarColor: Colors.orange,
        //You can disable viewer touch response by setting 'enableTouch' to 'false'
        enableTouch: true,
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
        src: 'assets/3d/deins_card2.glb',
        controller: controller),
  );
}

Widget challengeBox() {
  return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
          padding: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
              )),
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    border: Border.all(
                      color: Colors.black,
                    )),
                child: const Text('Challenge',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontStyle: FontStyle.italic))),
            Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 10.0, right: 10.0, bottom: 10.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                            backgroundColor: Colors.red, child: Text('LM')),
                        Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Expanded(
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 300,
                                    child: Flexible(
                                        child: Text(
                                            'Vervollständige die Kloppocar-Puzzle-Collection',
                                            maxLines: 3,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black))))))
                      ]),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 2000,
                lineHeight: 10.0,
                percent: 0.5,
                backgroundColor: Colors.grey,
                // ignore: deprecated_member_use
                barRadius: const Radius.circular(90),
                progressColor: Colors.purple,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('[collection_name]',
                        style: TextStyle(fontSize: 12, color: Colors.black)),
                    Text('[x/y]',
                        style: TextStyle(fontSize: 12, color: Colors.black))
                  ]),
            ),
          ])));
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            leading: const Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: CircleAvatar(
                  backgroundColor: Colors.white, child: Text('LM')),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USERNAME',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                Text('USERNAME',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
              ],
            )),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Stack(alignment: Alignment.center, children: [
                      Divider(height: 20, thickness: 1, color: Colors.grey),
                      CircleAvatar(
                          backgroundColor: Colors.white, child: Text('LM')),
                    ]),
                    objectViewer(),
                    Text(widget.qrcode,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('[card_title]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Text('[card_type_svg]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: LinearPercentIndicator(
                        animation: true,
                        animationDuration: 2000,
                        lineHeight: 14.0,
                        percent: 0.5,
                        backgroundColor: Colors.grey,
                        // ignore: deprecated_member_use
                        barRadius: const Radius.circular(90),
                        progressColor: Colors.purple,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('[collection_name]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Text('[x/y]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ]),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Divider(
                            height: 20, thickness: 1, color: Colors.grey)),
                    const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('COMMUNITY',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black)),
                            ])),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('[collection_title]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Text('[award_logo_svg]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: LinearPercentIndicator(
                        animation: true,
                        animationDuration: 2000,
                        lineHeight: 14.0,
                        percent: 0.5,
                        backgroundColor: Colors.grey,
                        // ignore: deprecated_member_use
                        barRadius: const Radius.circular(90),
                        progressColor: Colors.purple,
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('[community_challenge_name]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black)),
                            Text('[x/y]',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ],
                        )),
                    sectionHeader('CHALLENGE'),
                    challengeBox(),
                    challengeBox(),
                    sectionHeader('Nachrichten'),
                    const Text('list of news items here'),
                  ],
                ))));
  }
}
