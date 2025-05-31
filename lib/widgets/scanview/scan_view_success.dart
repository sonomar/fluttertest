import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import './scan_view_receive.dart';
import './scan_view_error.dart';
import '../../models/collectible_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanViewSuccess extends StatefulWidget {
  const ScanViewSuccess(
      {super.key, required this.qrcode, required this.collectibles});
  final String qrcode;
  final List collectibles;

  @override
  State<ScanViewSuccess> createState() => _ScanViewSuccessState();
}

class _ScanViewSuccessState extends State<ScanViewSuccess>
    with SingleTickerProviderStateMixin {
  bool _clicked = false;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  final Tween<double> _opacityTween = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  String getCollectibleMint(List collectibles, String id) {
    for (int i = 0; i < collectibles.length; i++) {
      if (collectibles[i]["collectibleId"].toString() == id) {
        var circulation = collectibles[i]["circulation'"];
        return (circulation + 1).toString();
      }
    }
    return 'No Mint Found';
  }

  bool isCodeValid(code) {
    if (code is String) {
      var splitCode = code.split("-");
      if (splitCode[0] == 'deinsqr') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _clicked = false;
    Future<void> initializeData() async {
      if (!mounted) {
        return; // Exit if the widget is no longer in the tree
      }
      final String qrcode = widget.qrcode;
      final SharedPreferences prefValue = await SharedPreferences.getInstance();
      if (isCodeValid(widget.qrcode)) {
        prefValue.setBool(qrcode, true);
        final String? userId = prefValue.getString("userId");
        final String collectibleId = widget.qrcode.split('-').last;
        final String mint =
            getCollectibleMint(widget.collectibles, collectibleId);
        // ignore: use_build_context_synchronously
        Provider.of<CollectibleModel>(context, listen: false)
            .addUserCollectible(userId, collectibleId, mint);
        // ignore: use_build_context_synchronously
        Provider.of<CollectibleModel>(context, listen: false).updateCollectible(
            {"collectibleId": collectibleId, "circulation": mint});
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) {
          return; // Check again after the first delay
        }
        _controller.forward();
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) {
          return; // Check again after the second delay
        }
        if (!_clicked) {
          // Get navigator here to ensure it's from a mounted context
          final navigator = Navigator.of(context);
          navigator.pushReplacement(MaterialPageRoute(
              builder: (context) => ScanViewReceive(qrcode: qrcode)));
        }
      } else {
        if (!mounted) {
          // Check before navigating in the error case
          return;
        }
        final navigator = Navigator.of(context);
        navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const ScanViewError()));
      }
    }

    initializeData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
            onTap: () {
              setState(() {
                _clicked = true;
              });
              final qrcode = widget.qrcode;
              final navigator = Navigator.of(context);
              navigator.pushReplacement(MaterialPageRoute(
                  builder: (context) => ScanViewReceive(qrcode: qrcode)));
            },
            child: Center(
                child: Container(
                    alignment: Alignment.center,
                    width: 300,
                    child: AnimatedOpacity(
                        opacity: _opacityTween.evaluate(_controller),
                        duration: Duration(seconds: 2),
                        child: Lottie.asset('assets/lottie/success2.json'))))));
  }
}
