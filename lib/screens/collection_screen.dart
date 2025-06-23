import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Temporarily unused for debugging
import 'subscreens/collectibles/collectible_details.dart';
import '../models/collectible_model.dart';
import '../helpers/localization_helper.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, PageStorageKey<String>? pageKey});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with AutomaticKeepAliveClientMixin<CollectionScreen> {
  @override
  bool get wantKeepAlive => true;

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

  // --- START OF FIX: Using Image.network for debugging ---
  Widget _buildImageWidget(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      // This builder shows a spinner while the image is loading.
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null)
          return child; // If loaded, return the image
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // This builder shows an error icon if the image fails to load.
      errorBuilder: (context, error, stackTrace) {
        print('Image.network Error: $error'); // Log the specific error
        return const Center(
            child: Icon(Icons.error_outline, color: Colors.red));
      },
    );
  }

  Widget linkedInkwell(Map collectibleTemplate, Map? userCollectibleInstance,
      BuildContext context) {
    final String colImage = collectibleTemplate['imageRef']?['url'] ?? '';

    return Material(
        child: Card(
            elevation: 4.0,
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    if (userCollectibleInstance != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CollectibleDetails(
                                selectedCollectible: collectibleTemplate,
                                selectedUserCollectible:
                                    userCollectibleInstance)),
                      );
                    }
                  },
                  splashColor: const Color.fromARGB(80, 214, 34, 202),
                  child: Ink(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: colImage.isNotEmpty
                        ? _buildImageWidget(colImage)
                        : const Icon(Icons.image_not_supported),
                  ),
                ))));
  }

  Widget unlinkedInkwell(Map collectible) {
    final colImage = collectible['imageRef']?['url'] ?? '';
    return Material(
        child: Card(
            elevation: 4.0,
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  backgroundBlendMode: BlendMode.saturation,
                ),
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: colImage.isNotEmpty
                    ? _buildImageWidget(colImage)
                    : const Icon(Icons.image_not_supported),
              ),
            )));
  }
  // --- END OF FIX ---

  @override
  void initState() {
    super.initState();
    Provider.of<CollectibleModel>(context, listen: false)
        .loadCollectibles(forceClear: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontSize: 30,
        ),
        centerTitle: false,
        title: Text(
          translate("collection_header", context),
          style: const TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontFamily: 'ChakraPetch',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: Color(0x80999999)),
              top: BorderSide(color: Color(0x80999999)),
            )),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      child: Text(
                    "$numAssets ${translate("collection_subheader_assets", context)}",
                    style: const TextStyle(
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
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              translate(
                                  "collection_subheader_sort_name", context),
                              style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.56,
                                  color: Colors.black,
                                  fontFamily: 'ChakraPetch',
                                  fontWeight: FontWeight.w500),
                            )),
                        Switch(
                          value: collectibleModel.sortByName,
                          activeColor: Color.fromARGB(255, 214, 34, 202),
                          activeTrackColor: Colors.white,
                          trackOutlineColor:
                              WidgetStateProperty.all(Colors.black),
                          trackOutlineWidth: WidgetStateProperty.all(1.0),
                          thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                            (Set<WidgetState> states) {
                              return const Icon(Icons.circle,
                                  color: Color.fromARGB(255, 214, 34, 202));
                            },
                          ),
                          inactiveThumbColor: Color.fromARGB(255, 214, 34, 202),
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
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              translate(
                                  "collection_subheader_sort_date", context),
                              style: const TextStyle(
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
            padding: const EdgeInsets.only(left: 12.0, top: 20, bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                shadowCircle('assets/images/caricon.jpg', 20.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    translate("collection_sub_header", context),
                    style: const TextStyle(
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
            child: Builder(
              builder: (context) {
                if (collectibleModel.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          collectibleModel.loadingMessage ?? 'Initializing...',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (collectibleModel.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load collectibles:\n${collectibleModel.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }

                if (collectionCollectibles.isNotEmpty) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: (11 / 16),
                    ),
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: collectionCollectibles.length,
                    itemBuilder: (context, index) {
                      final collectibleTemplate = collectionCollectibles[index];
                      bool isOwned =
                          isUserOwned(collectibleTemplate, userCollectibles);

                      Map userCollectibleInstance = {};
                      if (isOwned) {
                        userCollectibleInstance = userCollectibles.firstWhere(
                          (uc) =>
                              uc['collectibleId'].toString() ==
                              collectibleTemplate['collectibleId'].toString(),
                          orElse: () => {},
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        child: isOwned && userCollectibleInstance.isNotEmpty
                            ? linkedInkwell(collectibleTemplate,
                                userCollectibleInstance, context)
                            : unlinkedInkwell(collectibleTemplate),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      translate("collectibles_none", context),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'ChakraPetch',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
