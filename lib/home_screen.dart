import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(children: [
                          Builder(builder: (context) {
                            if (widget.qrcode != 'Scan a Collectible!') {
                              return Container(
                                  height: 300,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: const DecorationImage(
                                      image:
                                          AssetImage("assets/images/car2.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ));
                            }
                            return Container(
                                height: 300,
                                width: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: AssetImage("assets/images/car2.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ));
                          })
                        ])),
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
                  ],
                ))));
  }
}
