import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An enhanced DraggableScrollableSheet that reports its current
/// size via the [onSheetMoved] callback.
class InteractiveDragScrollSheet extends StatelessWidget {
  const InteractiveDragScrollSheet({
    super.key,
    required this.contents,
    this.onSheetMoved,
  });

  /// The widget to display inside the sheet.
  final Widget contents;

  /// A callback that is triggered when the sheet is dragged.
  /// It provides the current extent (size) of the sheet,
  /// ranging from the minChildSize to the maxChildSize.
  final Function(double extent)? onSheetMoved;

  @override
  Widget build(BuildContext context) {
    // We use a NotificationListener to listen for changes from the
    // DraggableScrollableSheet without needing to manage a controller.
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // When a notification is received, trigger the callback
        // with the new sheet extent (size).
        if (onSheetMoved != null) {
          onSheetMoved!(notification.extent);
        }
        // Return false to allow the notification to continue bubbling up.
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.25,
        minChildSize: 0.25,
        // Limit the cabinet from rising higher than 75% of the screen.
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
                // The grabber handle at the top of the sheet.
                const Grabber(),
                // The main content of the sheet.
                // BUG FIX: 'contents' is directly accessible here without 'widget.'
                contents,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A grabber handle widget.
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
