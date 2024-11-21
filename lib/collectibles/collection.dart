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
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.selectedCollection["name"])),
        body: ListView(padding: const EdgeInsets.all(8), children: [
          for (int i = 0; i < _items.length; i++) ...[
            Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Material(
                      borderRadius: BorderRadius.circular(25.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Collectible(
                                    selectedCollectible: _items[
                                        i]) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
                                ),
                          );
                        }, // Image tapped
                        splashColor: Colors.white10, // Splash color over image
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(_items[i]["imageRef"]),
                              fit: BoxFit.cover,
                            ),
                          ), // Fixes border issues
                          height: 400,
                        ),
                      )),
                  Text(_items[i]["name"],
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w700))
                ]))
          ]
        ]));
  }
}
