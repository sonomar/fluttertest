import 'package:flutter/material.dart';
import '../widgets/object_viewer.dart';
import '../widgets/card_info.dart';
import '../widgets/drag_scroll_sheet.dart';
import './collectible.dart';

class CollectibleDetails extends StatefulWidget {
  const CollectibleDetails({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  State<CollectibleDetails> createState() => _CollectibleDetailsState();
}

class _CollectibleDetailsState extends State<CollectibleDetails> {
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
                      selectedCollectible: widget.selectedCollectible))),
        ]));
  }
}
