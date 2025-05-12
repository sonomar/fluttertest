import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0.0,
            title: const Text("Game Center"),
            backgroundColor: Color(0xff333333),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontFamily: 'ChakraPetch',
              fontWeight: FontWeight.w500,
            )),
        body: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xffd622ca),
                  Color(0xff333333),
                ],
                center: Alignment.center,
                radius: 0.4,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(children: [
                  Text("NEW FEATURE COMING SOON!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text("Join the DEINS Game and participate in awesome Games!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]))));
  }
}
