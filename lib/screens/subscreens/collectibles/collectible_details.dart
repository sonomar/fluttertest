import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../models/collectible_model.dart';
import '../../../models/mission_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/object_viewer.dart';
import '../../../widgets/collectibles/card_info.dart';
import '../../../widgets/interactive_drag_scroll_sheet.dart';
import '../../../widgets/missions/latest_active_mission.dart';

class CollectibleDetails extends StatefulWidget {
  const CollectibleDetails({
    super.key,
    required this.selectedCollectible,
    required this.userCollectibleInstances,
  });
  final Map selectedCollectible;
  final List<Map<String, dynamic>> userCollectibleInstances;

  @override
  State<CollectibleDetails> createState() => _CollectibleDetailsState();
}

class _CollectibleDetailsState extends State<CollectibleDetails> {
  bool _isEnlarged = false;
  double _sheetPosition = 0.25;
  int _currentMintIndex = 0;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  late List<Map<String, dynamic>> _sortedInstances;

  @override
  void initState() {
    super.initState();
    _sortedInstances = List.from(widget.userCollectibleInstances);
    _sortedInstances.sort((a, b) {
      final int mintA = a['mint'] ?? 0;
      final int mintB = b['mint'] ?? 0;
      return mintA.compareTo(mintB);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionModel>(context, listen: false).loadMissions();
      Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
    });
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex,
      int pageViewIndex, bool isCenterPage) {
    final scale = isCenterPage ? 1.0 : 0.8;
    final String assetUrl = widget.selectedCollectible['embedRef']['url'];
    final String placeholderUrl =
        widget.selectedCollectible['imageRef']['load'];

    return Transform.scale(
      scale: scale,
      child: GestureDetector(
        onTap: () {
          if (!isCenterPage) {
            carouselController.animateToPage(itemIndex);
          }
        },
        // If the item is in the center, show the 3D ObjectViewer.
        // Otherwise, show the placeholder image to improve performance.
        child: isCenterPage
            ? ObjectViewer(asset: assetUrl, placeholder: placeholderUrl)
            : Image.network(
                placeholderUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline),
              ),
      ),
    );
  }

  Future<void> _showTradeQrDialog(
      BuildContext context, Map<String, dynamic> mintToTrade) async {
    final dynamic userInstanceForTrade = mintToTrade;

    if (userInstanceForTrade == null ||
        userInstanceForTrade['userCollectibleId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "This collectible instance cannot be traded or is not owned.")),
      );
      return;
    }

    final collectibleModel =
        Provider.of<CollectibleModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    final String userCollectibleId =
        userInstanceForTrade['userCollectibleId'].toString();
    final String? giverUserId = userModel.currentUser?['userId']?.toString();

    if (giverUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not identify current user for trade.")),
      );
      return;
    }

    if (userInstanceForTrade['ownerId']?.toString() != giverUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "You are not the owner of this specific collectible instance.")),
      );
      return;
    }

    bool success = await collectibleModel.updateUserCollectibleStatus(
        userCollectibleId, false, null, null);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(collectibleModel.errorMessage ??
                "Failed to prepare collectible for trade.")),
      );
      return;
    }

    final String qrData = "deinsQr-trade-$giverUserId-$userCollectibleId";
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Scan to Trade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                    "Ask the other user to scan this QR code with their DEINS app."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await collectibleModel.updateUserCollectibleStatus(
                    userCollectibleId, true, null, null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trade Process Complete.")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget lineItem(key, value) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(key,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Roboto',
            )),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold)),
      ]),
      const Divider(height: 20, thickness: 1, color: Colors.grey),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final missionModel = context.watch<MissionModel>();
    final missions = missionModel.missions;
    final missionUsers = missionModel.missionUsers;
    final Map<String, dynamic> currentMint =
        _sortedInstances[_currentMintIndex];
    final bool showCarousel = widget.userCollectibleInstances.length > 1 &&
        (_sheetPosition > 0.7) &&
        !_isEnlarged;
    final collectibleModel = context.watch<CollectibleModel>();
    final collectibles = collectibleModel.collectionCollectibles;
    final userCollectibles = collectibleModel.userCollectibles;
    final recentColl = getLatestCollectible(collectibles, userCollectibles);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.selectedCollectible["name"]),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEnlarged = !_isEnlarged;
                  if (!_isEnlarged) {
                    _sheetPosition = 0.25;
                  }
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isEnlarged
                    ? const Icon(Icons.fullscreen_exit,
                        key: ValueKey('shrink'), color: Colors.black)
                    : Image.asset("assets/images/enlarge.png",
                        key: const ValueKey('enlarge')),
              ),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double objectViewerHeight =
              constraints.maxHeight * (1 - _sheetPosition);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xffd622ca), Color(0xff333333)],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                  height: _isEnlarged
                      ? constraints.maxHeight * 0.85
                      : objectViewerHeight,
                  child: showCarousel
                      ? CarouselSlider.builder(
                          carouselController: carouselController,
                          itemCount: widget.userCollectibleInstances.length,
                          itemBuilder: (context, itemIndex, pageViewIndex) {
                            final isCenter = _currentMintIndex == itemIndex;
                            return _buildCarouselItem(
                                context, itemIndex, pageViewIndex, isCenter);
                          },
                          options: CarouselOptions(
                            height: _isEnlarged
                                ? constraints.maxHeight * 0.8
                                : objectViewerHeight,
                            viewportFraction: _isEnlarged ? 0.6 : 0.4,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.2,
                            enableInfiniteScroll: false,
                            padEnds: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentMintIndex = index;
                              });
                            },
                          ),
                        )
                      : ObjectViewer(
                          asset: widget.selectedCollectible['embedRef']['url'],
                          placeholder: widget.selectedCollectible['imageRef']
                              ['load'],
                        ),
                ),
              ),
              if (!_isEnlarged)
                InteractiveDragScrollSheet(
                  onSheetMoved: (position) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _sheetPosition != position) {
                        setState(() {
                          _sheetPosition = position;
                        });
                      }
                    });
                  },
                  contents: CardInfo(
                    selectedCollectible: widget.selectedCollectible,
                    selectedUserCollectible: currentMint,
                    missions: missions,
                    missionUsers: missionUsers,
                    recentColl: recentColl,
                    onTradeInitiate: () {
                      // Trading logic might need to be adjusted to select a specific mint
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
