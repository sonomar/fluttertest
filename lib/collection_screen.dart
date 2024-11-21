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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Collections"),
        ),
        body: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              for (int i = 0; i < _collections.length; i++) ...[
                Column(children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
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
                      height: 150,
                      image: AssetImage(_collections[i]["imageRef"]),
                    ),
                  ),
                  Text(_collections[i]["name"],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(_collections[i]["description"],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700))
                ])
              ]
            ]));
  }
}
