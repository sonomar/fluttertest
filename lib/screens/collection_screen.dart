import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'subscreens/collectibles/collectible_details.dart';
import '../models/collectible_model.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  // dynamic firstCollection;
  // dynamic collectionCollectibles;
  // dynamic userCollectibles;
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

  bool isUserOwned(collectible, userCollectibles) {
    for (int i = 0; i < userCollectibles.length; i++) {
      if (userCollectibles[i]['collectibleId'] ==
          collectible['collectibleId']) {
        return true;
      }
    }
    return false;
  }

  // Future<void> readItemJson() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String response =
  //       await rootBundle.loadString('assets/json/example.json');
  //   final data = await json.decode(response);
  //   setState(() {
  //     _items = data['collectibles'];
  //   });
  //   for (int i = 0; i < _items.length; i++) {
  //     var foundItem = _items[i]['label'];
  //     setState(() {
  //       _cardStatus[foundItem] = prefs.getBool(foundItem);
  //     });
  //   }
  // }

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
    print('here is the collectible: $collectible');
    final colImage = collectible["imageRef"][0];
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
            image: NetworkImage(colImage),
            fit: BoxFit.cover,
          ),
        ), // Fixes border issues
      ),
    ));
  }

  Widget unlinkedInkwell(collectible) {
    final colImage = collectible["imageRef"][0];
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
            image: NetworkImage(colImage),
            fit: BoxFit.cover,
          ),
        ), // Fixes border issues
      ),
    );
  }

  @override
  void initState() {
    // readItemJson();
    // _loadCollectionData();
    // _loadCollectibleData();
    // Make sure to call super.initState();
    super.initState();
    Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
  }

  @override
  Widget build(BuildContext context) {
    final collectibleModel = context.watch<CollectibleModel>();
    final collectionCollectibles = collectibleModel.collectionCollectibles;
    final userCollectibles = collectibleModel.userCollectibles;
    final numAssets = collectionCollectibles.length.toString();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        titleTextStyle: const TextStyle(
          // Added const here
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontSize: 30,
        ),
        centerTitle: false,
        title: const Text(
          "Galerie", // Added const here
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontFamily: 'ChakraPetch',
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(20), // Added const here
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectibleDetails(
                      selectedCollectible: exampleWallet,
                    ),
                  ),
                );
              },
              child: Image.asset("assets/images/wallet1.png"),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(color: const Color(0x80999999)),
              top: BorderSide(color: const Color(0x80999999)),
            )),
            child: Padding(
              padding: const EdgeInsets.all(20), // Added const here
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      child: Text(
                    "$numAssets ASSETS",
                    style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.56,
                        color: Colors.black,
                        fontFamily: 'ChakraPetch',
                        fontWeight: FontWeight.w700),
                  )),
                  SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                right: 10), // Added const here
                            child: Text(
                              "NAME",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.56,
                                  color: Colors.black,
                                  fontFamily: 'ChakraPetch',
                                  fontWeight: FontWeight.w500),
                            )),
                        Switch(
                          value: collectibleModel.sortByName,
                          activeColor: Colors.purple,
                          activeTrackColor: Colors.white,
                          thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                            (Set<WidgetState> states) {
                              return const Icon(Icons.circle,
                                  color: Colors.purple);
                            },
                          ),
                          inactiveThumbColor: Colors.purple,
                          inactiveTrackColor: Colors.white,
                          onChanged: (bool value) {
                            if (collectibleModel.sortByName == true) {
                              Provider.of<CollectibleModel>(context,
                                      listen: false)
                                  .sortCollectiblesByColumn('name');
                            } else {
                              Provider.of<CollectibleModel>(context,
                                      listen: false)
                                  .sortCollectiblesByColumn('label');
                            }
                          },
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10), // Added const here
                            child: Text(
                              "DATE",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.56,
                                  color: Colors.black,
                                  fontFamily: 'ChakraPetch',
                                  fontWeight: FontWeight.w500),
                            )),
                      ])),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                shadowCircle('assets/images/caricon.jpg',
                    20.0), // Ensure shadowCircle is defined
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: const Text(
                    // Added const here
                    'Kloppocar Puzzle Collection',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: collectibleModel.isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator()) // Added const here
                      : (collectionCollectibles != null &&
                              collectionCollectibles.isNotEmpty)
                          ? GridView.count(
                              primary: false,
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              crossAxisCount: 4,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: (6 / 10),
                              children: [
                                for (int i = 0;
                                    i < collectionCollectibles.length;
                                    i++) ...[
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: 20,
                                      left: 5,
                                      right: 5,
                                      bottom: 20,
                                    ),
                                    child: (isUserOwned(
                                              collectionCollectibles[i],
                                              userCollectibles,
                                            ) ==
                                            true)
                                        ? linkedInkwell(collectionCollectibles[
                                            i]) // Ensure linkedInkwell is defined
                                        : unlinkedInkwell(collectionCollectibles[
                                            i]), // Ensure unlinkedInkwell is defined
                                  )
                                ]
                              ],
                            )
                          : const Center(
                              // Display a message if no collectibles
                              child: Text(
                                'No collectibles found.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'ChakraPetch',
                                ),
                              ),
                            ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
