import 'package:flutter/material.dart';
import '../widgets/object_viewer.dart';
import '../widgets/card_info.dart';

class CollectibleDetails extends StatefulWidget {
  const CollectibleDetails({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  State<CollectibleDetails> createState() => _CollectibleDetailsState();
}

class _CollectibleDetailsState extends State<CollectibleDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.selectedCollectible["name"])),
        body: Container(
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
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            height: 500,
                            width: double.infinity,
                            child: widget.selectedCollectible["label"] ==
                                    "item-test77"
                                ? ObjectViewer(
                                    asset: "assets/3d/deins_card4.glb")
                                : ObjectViewer(
                                    asset: "assets/3d/deins_card2.glb"),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffd622ca),
                              ),
                              onPressed: () {},
                              child: Text('Transfer Asset',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontFamily: 'ChakraPetch',
                                  ))),
                          SizedBox(height: 30),
                          Stack(alignment: Alignment.topCenter, children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0, bottom: 10),
                                child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                    ),
                                    child: GestureDetector(
                                      onVerticalDragEnd:
                                          (DragEndDetails details) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40, // here increase or decrease in width
                                          ),
                                          builder: (context) => CardInfo(
                                              selectedCollectible:
                                                  widget.selectedCollectible),
                                        );
                                      },
                                    ))),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: 40,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Colors.grey,
                              ),
                              child: GestureDetector(
                                onVerticalDragEnd: (DragEndDetails details) {
                                  showModalBottomSheet(
                                    context: context,
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context)
                                              .size
                                              .width -
                                          40, // here increase or decrease in width
                                    ),
                                    builder: (context) => CardInfo(
                                        selectedCollectible:
                                            widget.selectedCollectible),
                                  );
                                },
                              ),
                            ),
                          ]),
                        ])))));
  }
}
