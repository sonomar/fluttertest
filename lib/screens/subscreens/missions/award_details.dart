import 'package:flutter/material.dart';
import '../../../widgets/object_viewer.dart';
import './award_info.dart';
import '../../../widgets/drag_scroll_sheet.dart';
import './award.dart';

class AwardDetails extends StatefulWidget {
  const AwardDetails({super.key, required this.selectedAward});
  final dynamic selectedAward;

  @override
  State<AwardDetails> createState() => _AwardDetailsState();
}

class _AwardDetailsState extends State<AwardDetails> {
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
    final award = widget.selectedAward;
    print('bababab $award');
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.selectedAward["title"]),
            actions: [
              Padding(
                padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Award(selectedAward: widget.selectedAward)));
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
                          child: ObjectViewer(
                              asset: widget.selectedAward['embedRef']['url']),
                        )),
                  ]))),
          SizedBox(
              height: MediaQuery.of(context).size.height,
              child: DragScrollSheet(
                  contents: AwardInfo(selectedAward: widget.selectedAward))),
        ]));
  }
}
