import 'package:flutter/material.dart';
import '../widgets/object_viewer.dart';
import './collectible_details.dart';

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
                padding: const EdgeInsets.all(20.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Stack(alignment: Alignment.center, children: [
                      objectViewer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CollectibleDetails(
                                      selectedCollectible:
                                          widget.selectedCollectible)));
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Text('i')),
                      ),
                    ])))));
  }
}
