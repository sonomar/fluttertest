import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Row(children: [
              Text('Hi Guest and',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
            ]),
            const Row(children: [
              Text('welcome to Deins',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
            ]),
            Row(children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                color: Colors.grey[300],
                width: 300.0,
                height: 350.0,
              )
            ]),
            const Row(children: [
              Text('Kloppocar Asset',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
            ]),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(children: [
                Text('Information about the asset',
                    style: TextStyle(fontSize: 12, color: Colors.grey))
              ]),
            )
          ],
        ));
  }
}
