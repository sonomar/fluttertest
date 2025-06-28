import 'package:flutter/material.dart';

class InteractiveDragScrollSheet extends StatelessWidget {
  const InteractiveDragScrollSheet({
    super.key,
    required this.contents,
    this.onSheetMoved,
    this.initialChildSize = 0.25,
  });

  /// The widget to display inside the sheet.
  final Widget contents;
  final Function(double extent)? onSheetMoved;
  final double initialChildSize;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (onSheetMoved != null) {
          onSheetMoved!(notification.extent);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: 0.25,
        maxChildSize: 0.75,
        snap: true,
        snapSizes: const [.25, .75],
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: <Widget>[
                const Grabber(),
                contents,
              ],
            ),
          );
        },
      ),
    );
  }
}

class Grabber extends StatelessWidget {
  const Grabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: 32.0,
          height: 4.0,
          decoration: BoxDecoration(
            color: const Color(0x80999999),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
