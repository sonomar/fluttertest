import 'package:flutter/material.dart';

class Collectible extends StatefulWidget {
  const Collectible({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  State<Collectible> createState() => _CollectibleState();
}

class _CollectibleState extends State<Collectible> {
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.selectedCollectible["name"])),
        body: ListView(padding: const EdgeInsets.all(8), children: [
          Column(children: [
            Row(children: [
              Text(widget.selectedCollectible["name"],
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w700))
            ]),
            Material(
                child: InkWell(
              onTap: () {}, // Image tapped
              splashColor: Colors.white10, // Splash color over image
              child: Ink.image(
                fit: BoxFit.cover, // Fixes border issues
                width: 100,
                height: 100,
                image: const AssetImage("assets/images/car2.jpg"),
              ),
            )),
            Text(widget.selectedCollectible["description"],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
          ])
        ]));
  }
}
