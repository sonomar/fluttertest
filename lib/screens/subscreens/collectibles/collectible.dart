import 'package:flutter/material.dart';
import '../../../widgets/object_viewer.dart';
import '../../../helpers/localization_helper.dart';

class Collectible extends StatefulWidget {
  const Collectible({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  State<Collectible> createState() => _CollectibleState();
}

class _CollectibleState extends State<Collectible> {
  List collectible = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(getTranslatedString(
                context, widget.selectedCollectible["name"]))),
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
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: widget.selectedCollectible["label"] == "item-test77"
                      ? ObjectViewer(
                          asset:
                              "https://deins.s3.eu-central-1.amazonaws.com/Objects3d/kloppocar/KloppoCar_4.gltf",
                          placeholder:
                              "https://deins.s3.eu-central-1.amazonaws.com/Objects3d/kloppocar/images/k4.png")
                      : ObjectViewer(
                          asset: widget.selectedCollectible['embedRef']['url'],
                          placeholder: widget.selectedCollectible['imageRef']
                              ['load']),
                ))));
  }
}
