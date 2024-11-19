import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectible.dart';
import 'dart:convert';

class Collection extends StatefulWidget {
  final Map selectedCollection;
  const Collection({super.key, required this.selectedCollection});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List get selectedCollection => [];
  List _items = [];

  Future<void> readItemJson() async {
    final String response =
        await rootBundle.loadString('assets/json/example.json');
    final data = await json.decode(response);
    setState(() {
      _items = data['collectibles'];
    });
  }

  @override
  void initState() {
    readItemJson();
    // Make sure to call super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("HELLO EVERYONE, THIS IS THE ${_items}");
    return ListView(padding: const EdgeInsets.all(8), children: [
      Column(children: [
        for (int i = 0; i < _items.length; i++) ...[
          Row(children: [
            Text(_items[i]["name"],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
          ]),
          Material(
              child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Collectible(
                        selectedCollectible: _items[
                            i]) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                    ),
              );
            }, // Image tapped
            splashColor: Colors.white10, // Splash color over image
            child: Ink.image(
              fit: BoxFit.cover, // Fixes border issues
              width: 100,
              height: 100,
              image: AssetImage(_items[i]["imageRef"]),
            ),
          )),
          Text(_items[i]["description"],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
        ]
      ])
    ]);
  }
}
