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
                            height: 500,
                            width: double.infinity,
                            child: objectViewer(),
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
                          SizedBox(height: 100),
                          Stack(alignment: Alignment.center, children: [
                            GestureDetector(
                                onTap: () {
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
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        color: Colors.white,
                                      ),
                                    ))),
                            GestureDetector(
                              onTap: () {
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
                              child: Container(
                                width: 20,
                                height: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ]),
                        ])))));
  }
}
