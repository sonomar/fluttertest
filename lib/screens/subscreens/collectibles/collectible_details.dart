import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../main.dart';
import '../../../models/collectible_model.dart';
import '../../../models/distribution_model.dart'; // Import DistributionModel
import '../../../models/mission_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/object_viewer.dart';
import '../../../widgets/collectibles/card_info.dart';
import '../../../widgets/missions/latest_active_mission.dart';
import '../../../widgets/interactive_drag_scroll_sheet.dart';

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

  /// Initiates a collectible transfer using the DistributionModel.
  Future<void> _initiateTransfer(
      BuildContext context, Map<String, dynamic> mintToTrade) async {
    const String transferDistributionId = "your_transfer_distribution_id_here";

    final distributionModel =
        Provider.of<DistributionModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    final userCollectibleId = mintToTrade['userCollectibleId']?.toString();
    final ownerId = mintToTrade['ownerId']?.toString();
    final currentUserId = userModel.currentUser?['userId']?.toString();

    if (userCollectibleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("This collectible instance cannot be traded.")),
      );
      return;
    }
    if (ownerId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You are not the owner of this collectible.")),
      );
      return;
    }

    final transferData = await distributionModel.initiateTransfer(
        userCollectibleId, transferDistributionId);

    if (transferData != null && transferData['code'] != null) {
      final String qrData = transferData['code'];
      if (!mounted) return;

      // --- START: MODIFIED LOGIC ---
      // Show the dialog and wait for it to be closed by the user.
      await showDialog<void>(
        context: context,
        barrierDismissible: false, // User must explicitly close it
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Scan to Transfer'),
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      "Ask the other user to scan this QR code with their app to receive the collectible."),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );

      // After the dialog is closed, force a data refresh and navigate home.
      if (!mounted) return;

      // Force a refresh of the user's collectibles to reflect the change.
      await Provider.of<CollectibleModel>(context, listen: false)
          .loadCollectibles(forceClear: true);

      if (!mounted) return;

      final userData =
          Provider.of<UserModel>(context, listen: false).currentUser;

      // Navigate to the home page, removing all previous routes so the user can't go "back" to the stale details screen.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: "Kloppocar Home",
            userData: userData,
            qrcode: 'none',
          ),
        ),
        (Route<dynamic> route) => false,
      );
      // --- END: MODIFIED LOGIC ---
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(distributionModel.errorMessage ??
                "Failed to initiate transfer.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionModel = context.watch<MissionModel>();
    final missions = missionModel.missions;
    final missionUsers = missionModel.missionUsers;
    final Map<String, dynamic> currentMint =
        _sortedInstances.isNotEmpty ? _sortedInstances[_currentMintIndex] : {};
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
              if (!_isEnlarged && _sortedInstances.isNotEmpty)
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
                      // Call the new transfer initiation function with the currently selected mint
                      _initiateTransfer(context, currentMint);
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
