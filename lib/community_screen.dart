import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectibles/collection.dart';
import 'dart:convert';

// Fetch content from the json file
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List _commCollections = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/example_collection.json');
    final data = await json.decode(response);
    setState(() {
      _commCollections = data["collections"];
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
          title: const Text("Community"),
        ),
        body: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              for (int i = 0; i < _commCollections.length; i++) ...[
                Column(children: [
                  Material(
                      borderRadius: BorderRadius.circular(25.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Collection(
                                    selectedCollection: _commCollections[
                                        i]) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                                ),
                          );
                        }, // Image tapped
                        splashColor: Colors.white10, // Splash color over image
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image:
                                  AssetImage(_commCollections[i]["imageRef"]),
                              fit: BoxFit.cover,
                            ),
                          ), // Fixes border issues
                          height: 150,
                        ),
                      )),
                  Text(_commCollections[i]["name"],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(_commCollections[i]["description"],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700))
                ])
              ]
            ]));
  }
}
