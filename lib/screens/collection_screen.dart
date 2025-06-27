import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subscreens/collectibles/collectible_details.dart';
import '../models/collectible_model.dart';
import '../helpers/localization_helper.dart';
import '../widgets/shadow_circle.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, PageStorageKey<String>? pageKey});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with AutomaticKeepAliveClientMixin<CollectionScreen> {
  @override
  bool get wantKeepAlive => true;

  int countOwnedMints(Map collectible, List userCollectibles) {
    int count = 0;
    for (int i = 0; i < userCollectibles.length; i++) {
      if (userCollectibles[i]['collectibleId'] ==
          collectible['collectibleId']) {
        count++;
      }
    }
    return count;
  }

  bool isUserOwned(collectible, userCollectibles) {
    for (int i = 0; i < userCollectibles.length; i++) {
      if (userCollectibles[i]['collectibleId'] ==
          collectible['collectibleId']) {
        return true;
      }
    }
    return false;
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

  Widget linkedInkwell(Map collectibleTemplate,
      List<Map<String, dynamic>> userCollectibleInstances, int mintCount) {
    final String colImage = collectibleTemplate['imageRef']?['url'] ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // When tapped, pass the first instance to the details page.
          // The details page could be expanded later to show all mints.
          if (userCollectibleInstances.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CollectibleDetails(
                        selectedCollectible: collectibleTemplate,
                        userCollectibleInstances: userCollectibleInstances,
                      )),
            );
          }
        },
        splashColor: const Color.fromARGB(80, 214, 34, 202),
        child: Material(
          elevation: 4.0,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              colImage.isNotEmpty
                  ? _buildImageWidget(colImage)
                  : const Icon(Icons.image_not_supported),
              if (mintCount > 1)
                Positioned(
                  top: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(163, 255, 255, 255),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    child: Center(
                      child: Text(
                        'x$mintCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget unlinkedInkwell(Map collectible) {
    final colImage = collectible['imageRef']?['url'] ?? '';
    return Material(
        child: Material(
            elevation: 4.0,
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                backgroundBlendMode: BlendMode.saturation,
              ),
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: colImage.isNotEmpty
                  ? _buildImageWidget(colImage)
                  : const Icon(Icons.image_not_supported),
            )));
  }

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
                            context
                                .read<CollectibleModel>()
                                .toggleSortPreference();
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
                shadowCircle('assets/images/caricon.jpg', 20.0, false),
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
                      final int ownedMints = countOwnedMints(
                          collectibleTemplate, userCollectibles);
                      bool isOwned = ownedMints > 0;
                      if (isOwned) {
                        // Get all instances of this collectible owned by the user.
                        final instances = userCollectibles
                            .where((uc) =>
                                uc['collectibleId'] ==
                                collectibleTemplate['collectibleId'])
                            .map((e) => e as Map<String, dynamic>)
                            .toList();

                        return linkedInkwell(
                            collectibleTemplate, instances, ownedMints);
                      } else {
                        return unlinkedInkwell(collectibleTemplate);
                      }
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
