import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
            width: double.infinity, child: Text(selectedCollectible["name"])));
  }
}
