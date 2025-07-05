import 'package:flutter/material.dart';
import '../../../helpers/localization_helper.dart';
import '../../../widgets/object_viewer.dart';

class Award extends StatefulWidget {
  const Award({super.key, required this.selectedAward});
  final dynamic selectedAward;

  @override
  State<Award> createState() => _AwardState();
}

class _AwardState extends State<Award> {
  List Award = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              getTranslatedString(context, widget.selectedAward["title"]),
            )),
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
                  child: ObjectViewer(
                      asset: widget.selectedAward['embedRef']['url'],
                      placeholder: widget.selectedAward['imgRef']['load'])),
            )));
  }
}
