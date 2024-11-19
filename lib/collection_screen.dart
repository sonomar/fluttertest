import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectibles/collection.dart';
import 'dart:convert';

// Fetch content from the json file
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List _collections = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/example_collection.json');
    final data = await json.decode(response);
    setState(() {
      _collections = data["collections"];
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
        for (int i = 0; i < _collections.length; i++) ...[
          Row(children: [
            Text(_collections[i]["name"],
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
          ]),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Collection(
                        selectedCollection: _collections[
                            i]) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                    ),
              );
            }, // Image tapped
            splashColor: Colors.white10, // Splash color over image
            child: Ink.image(
              fit: BoxFit.cover, // Fixes border issues
              width: 100,
              height: 100,
              image: AssetImage(_collections[i]["imageRef"]),
            ),
          ),
          Text(_collections[i]["description"],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
        ]
      ])
    ]);
  }
}
