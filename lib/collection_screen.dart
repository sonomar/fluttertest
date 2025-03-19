import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectibles/collectible.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List _items = [];
  final Map _cardStatus = {};

  Future<void> readItemJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String response =
        await rootBundle.loadString('assets/json/example.json');
    final data = await json.decode(response);
    setState(() {
      _items = data['collectibles'];
    });
    for (int i = 0; i < _items.length; i++) {
      var foundItem = _items[i]['name'];
      setState(() {
        _cardStatus[foundItem] = prefs.getBool(foundItem);
      });
    }
  }

  Widget linkedInkwell(collectible) {
    return Material(
        child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Collectible(
                  selectedCollectible:
                      collectible) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
              ),
        );
      }, // Image tapped
      splashColor: Colors.white10, // Splash color over image
      child: Ink(
        height: 80,
        width: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(collectible["imageRef"]),
            fit: BoxFit.cover,
          ),
        ), // Fixes border issues
      ),
    ));
  }

  Widget unlinkedInkwell(collectible) {
    return Material(
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        height: 80,
        width: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(collectible["imageRef"]),
            fit: BoxFit.cover,
          ),
        ), // Fixes border issues
      ),
    );
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
                                  fontSize: 20,
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
                            child: (_cardStatus[_items[i]['name']] == true)
                                ? linkedInkwell(_items[i])
                                : unlinkedInkwell(_items[i]))
                      ]
                    ]))
              ]))
            ])));
  }
}
