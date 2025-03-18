import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectibles/collectible.dart';
import 'dart:convert';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
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
    // ignore: avoid_print
    print('length: ${_items.length}');
    return Scaffold(
        appBar: AppBar(
            titleTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'ChakraPetch',
                fontSize: 30),
            centerTitle: false,
            title: Text("Galerie")),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.red, child: Text('LM')),
                        Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Kloppocar Puzzle Collection',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontFamily: 'ChakraPetch',
                                )))
                      ])),
              Expanded(
                  child: Row(children: [
                Expanded(
                    child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20.0),
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: (5 / 10),
                        children: [
                      for (int i = 0; i < _items.length; i++) ...[
                        Container(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 5, right: 5),
                          child: Material(
                              child: InkWell(
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
                            splashColor:
                                Colors.white10, // Splash color over image
                            child: Ink(
                              height: 80,
                              width: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(_items[i]["imageRef"]),
                                  fit: BoxFit.cover,
                                ),
                              ), // Fixes border issues
                            ),
                          )),
                        )
                      ]
                    ]))
              ]))
            ])));
  }
}
