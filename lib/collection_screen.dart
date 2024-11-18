import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Fetch content from the json file
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List _items = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/example.json');
    final data = await json.decode(response);
    setState(() {
      _items = data["collectibles"];
    });
  }

  // The init state function.
  @override
  void initState() {
    readJson();
    // Make sure to call super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8), children: [
      Column(children: [
        for (int i = 0; i < _items.length; i++) ...[
          Row(children: [
            Text(_items[i]["name"],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
          ]),
          Image(image: AssetImage(_items[i]["imageRef"])),
          Text(_items[i]["description"],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
        ]
      ])
    ]);
  }
}
