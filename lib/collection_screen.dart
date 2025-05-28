import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './collectibles/collectible_details.dart';
import './api/collectible.dart';
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
  Map exampleWallet = {
    "collectibleId": 99,
    "label": "item-test77",
    "name": "3D Wallet",
    "category": 1,
    "collection": 1,
    "description":
        "This is a sample 3D Wallet. This Shows off what DEINS 3D objects will look like in the future.",
    "imageRef": "assets/images/car1.png",
    "vidRef": "assets/images/car1.png",
    "QRRef": "assets/images/car1.png",
    "EmbedRef": "assets/images/car1.png",
    "createdDt": "2024-11-18 10:36:22.640",
    "updatedDt": "2024-11-18 10:36:22.640",
    "active": true,
    "collection-name": "Kloppocar-Puzzle-Collection",
    "collection-number": "01-01",
    "community": "Kloppocar Community",
    "sponsor": "Mini-Cooper",
    "sponsor-url": "https://www.mini.com",
    "circulation": "20,000",
    "publication-date": "20.03.2025"
  };

  Future<void> readItemJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String response =
        await rootBundle.loadString('assets/json/example.json');
    final data = await json.decode(response);
    setState(() {
      _items = data['collectibles'];
    });
    for (int i = 0; i < _items.length; i++) {
      var foundItem = _items[i]['label'];
      setState(() {
        _cardStatus[foundItem] = prefs.getBool(foundItem);
      });
    }
  }

  Widget shadowCircle(imageLink, radius) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black, spreadRadius: 0)
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(imageLink),
      ),
    );
  }

  Widget linkedInkwell(collectible) {
    return Material(
        child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CollectibleDetails(
                  selectedCollectible:
                      collectible) //here pass the actual values of these variables, for example false if the payment isn't successfull..etc
              ),
        );
      },
      splashColor: Color.fromARGB(
          80, 214, 34, 202), // Image tapped // Splash color over image
      splashFactory: InkSparkle.splashFactory,
      radius: MediaQuery.of(context).size.width - 450,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
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
          color: Colors.white,
          backgroundBlendMode: BlendMode.saturation,
        ),
        height: 80,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
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
    getAllCollectibles();
    // Make sure to call super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('length: ${_items.length}');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0.0,
            titleTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'ChakraPetch',
                fontSize: 30),
            centerTitle: false,
            title: Text("Galerie",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontFamily: 'ChakraPetch',
                  fontWeight: FontWeight.w500,
                )),
            actions: [
              Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollectibleDetails(
                                selectedCollectible: exampleWallet)));
                  },
                  child: Image.asset("assets/images/wallet1.png"),
                ),
              )
            ]),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        shadowCircle('assets/images/caricon.jpg', 20.0),
                        Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Kloppocar Puzzle Collection',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'ChakraPetch',
                                  fontWeight: FontWeight.w500,
                                )))
                      ])),
              Expanded(
                  child: Row(children: [
                Expanded(
                    child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        crossAxisCount: 4,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: (6 / 10),
                        children: [
                      for (int i = 0; i < _items.length; i++) ...[
                        Container(
                            padding: const EdgeInsets.only(
                                top: 20, left: 5, right: 5, bottom: 20),
                            child: (_cardStatus[_items[i]['label']] == true)
                                ? linkedInkwell(_items[i])
                                : unlinkedInkwell(_items[i]))
                      ]
                    ]))
              ]))
            ])));
  }
}
