import 'package:flutter/material.dart';
import '../../../widgets/object_viewer.dart';
import '../../../widgets/missions/award_info.dart';
import '../../../helpers/localization_helper.dart';
import '../../../widgets/interactive_drag_scroll_sheet.dart';

class AwardDetails extends StatefulWidget {
  const AwardDetails(
      {super.key,
      required this.selectedAward,
      required this.selectedAwardUser});
  final dynamic selectedAward;
  final dynamic selectedAwardUser;

  @override
  State<AwardDetails> createState() => _AwardDetailsState();
}

class _AwardDetailsState extends State<AwardDetails> {
  // bool _isEnlarged = false;
  double _sheetPosition = 0.75;

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
    final bool isCompleted = widget.selectedAwardUser['completed'];
    final String missionImage = widget.selectedAward['imgRef']['load'];

    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              getTranslatedString(context, widget.selectedAward["title"]),
            ),
            actions: [
              // if (isCompleted)
              //   Padding(
              //     padding: const EdgeInsets.all(15),
              //     child: GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           _isEnlarged = !_isEnlarged;
              //           if (!_isEnlarged) {
              //             _sheetPosition = 0.75;
              //           }
              //         });
              //       },
              //       child: AnimatedSwitcher(
              //         duration: const Duration(milliseconds: 300),
              //         child: _isEnlarged
              //             ? const Icon(Icons.fullscreen_exit,
              //                 key: ValueKey('shrink'), color: Colors.black)
              //             : Image.asset("assets/images/enlarge.png",
              //                 key: const ValueKey('enlarge')),
              //       ),
              //     ),
              //   )
            ]),
        body: LayoutBuilder(builder: (context, constraints) {
          final double objectViewerHeight =
              constraints.maxHeight * (1 - _sheetPosition);

          return Stack(alignment: Alignment.center, children: [
            Container(
              decoration: const BoxDecoration(
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
            ),
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: SizedBox(
                height: objectViewerHeight,
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 100),
                //   curve: Curves.linear,
                //   height: _isEnlarged
                //       ? constraints.maxHeight * 0.85
                //       : objectViewerHeight,
                //   child: isCompleted
                //       ? ObjectViewer(
                //           asset: widget.selectedAward['embedRef']['url'],
                //           placeholder: widget.selectedAward['imgRef']['load'])
                //       :
                child: Center(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      // Greyscale matrix
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image.network(
                      missionImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // if (!_isEnlarged)
            InteractiveDragScrollSheet(
                initialChildSize: 0.75,
                onSheetMoved: (position) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _sheetPosition != position) {
                      setState(() {
                        _sheetPosition = position;
                      });
                    }
                  });
                },
                contents: AwardInfo(
                    selectedAward: widget.selectedAward,
                    selectedAwardUser: widget.selectedAwardUser)),
          ]);
        }));
  }
}
