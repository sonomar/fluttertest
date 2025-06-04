import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import '../../../models/collectible_model.dart';
import '../../../models/mission_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/object_viewer.dart';
import '../../../widgets/collectibles/card_info.dart';
import '../../../widgets/drag_scroll_sheet.dart';
import '../../../widgets/missions/latest_active_mission.dart';
import 'collectible.dart';

class CollectibleDetails extends StatefulWidget {
  const CollectibleDetails({
    super.key,
    required this.selectedCollectible,
    this.selectedUserCollectible,
  });
  final Map selectedCollectible;
  final Map? selectedUserCollectible;

  @override
  State<CollectibleDetails> createState() => _CollectibleDetailsState();
}

class _CollectibleDetailsState extends State<CollectibleDetails> {
  @override
  void initState() {
    super.initState();
    // Defer the calls to load data until after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionModel>(context, listen: false).loadMissions();
      Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
    });
  }

  Future<void> _showTradeQrDialog(BuildContext context) async {
    // Use widget.selectedUserCollectibleInstance for trade-specific data
    final dynamic userInstanceForTrade = widget.selectedUserCollectible;

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

    // Ensure the current user is the owner of this specific instance before proceeding
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

    // ignore: use_build_context_synchronously
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
                    // Using QrImage from qr_flutter_new
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
              child: const Text('Cancel Trade'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await collectibleModel.updateUserCollectibleStatus(
                    userCollectibleId, true, null, null);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trade cancelled.")),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'Roboto',
            )),
        Text(value,
            style: TextStyle(
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
                padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Collectible(
                                selectedCollectible:
                                    widget.selectedCollectible)));
                  },
                  child: Image.asset("assets/images/enlarge.png"),
                ),
              )
            ]),
        body: Stack(alignment: Alignment.center, children: [
          Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xffd622ca),
                    Color(0xff333333),
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
              height: double.infinity,
              width: double.infinity,
              child: Align(
                  alignment: Alignment.center,
                  child: Column(children: [
                    Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                        child: SizedBox(
                          height: 500,
                          width: double.infinity,
                          child: widget.selectedCollectible["name"] ==
                                  "3D Wallet"
                              ? ObjectViewer(
                                  asset:
                                      "https://deins.s3.eu-central-1.amazonaws.com/Objects3d/cardSample2/KloppoCar_Raw_Asset.gltf")
                              : ObjectViewer(
                                  asset: widget.selectedCollectible['embedRef']
                                      ['url']),
                        )),
                  ]))),
          SizedBox(
              height: MediaQuery.of(context).size.height,
              child: DragScrollSheet(
                  contents: CardInfo(
                      selectedCollectible: widget.selectedCollectible,
                      missions: missions,
                      missionUsers: missionUsers,
                      onTradeInitiate: () => _showTradeQrDialog(context),
                      recentColl: recentColl))),
        ]));
  }
}
