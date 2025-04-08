import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DragScrollSheet extends StatefulWidget {
  const DragScrollSheet({super.key, required this.contents});
  final Widget contents;

  @override
  State<DragScrollSheet> createState() => _DragScrollSheetState();
}

class _DragScrollSheetState extends State<DragScrollSheet> {
  double _sheetPosition = .25;
  final double _dragSensitivity = 600;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetPosition,
      snap: true,
      snapSizes: [.25, .75],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Column(
            children: <Widget>[
              Grabber(
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _sheetPosition -= details.delta.dy / _dragSensitivity;
                    if (_sheetPosition < 0.25) {
                      _sheetPosition = 0.25;
                    }
                    if (_sheetPosition > 1.0) {
                      _sheetPosition = 1.0;
                    }
                  });
                },
                isOnDesktopAndWeb: _isOnDesktopAndWeb,
              ),
              Flexible(
                child: widget.contents,
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.macOS ||
        TargetPlatform.linux ||
        TargetPlatform.windows =>
          true,
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.fuchsia =>
          false,
      };
}

/// A draggable widget that accepts vertical drag gestures
/// and this is only visible on desktop and web platforms.
class Grabber extends StatelessWidget {
  const Grabber(
      {super.key,
      required this.onVerticalDragUpdate,
      required this.isOnDesktopAndWeb});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: Color(0x80999999),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
