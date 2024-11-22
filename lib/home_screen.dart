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
                Row(children: [
                  Builder(builder: (context) {
                    if (widget.qrcode != 'Scan a Collectible!') {
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
