import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.qrcode});
  final String qrcode;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Kloppocar Home"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Row(children: [
                  Text('Hi Guest and',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
                ]),
                const Row(children: [
                  Text('welcome to Deins',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
                ]),
                const Row(children: [
                  Image(
                    image: AssetImage("assets/images/car2.jpg"),
                    width: 300.0,
                    height: 350.0,
                  )
                ]),
                Row(children: [
                  Text(widget.qrcode,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700))
                ]),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(children: [
                    Text('Information about the asset',
                        style: TextStyle(fontSize: 12, color: Colors.grey))
                  ]),
                )
              ],
            )));
  }
}
