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
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.selectedCollectible["name"])),
        body: ListView(padding: const EdgeInsets.all(8), children: [
          Column(children: [
            Text(widget.selectedCollectible["name"],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            Material(
                borderRadius: BorderRadius.circular(25.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25.0),
                  onTap: () {}, // Image tapped
                  splashColor: Colors.white10, // Splash color over image
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/car2.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ), // Fixes border issues
                    height: 400,
                  ),
                )),
            Text(widget.selectedCollectible["description"],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
          ])
        ]));
  }
}
