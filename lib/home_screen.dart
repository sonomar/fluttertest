import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Row(children: [
              Text('Hi Guest and',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
            ]),
            Row(children: [
              Text('welcome to Deins',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))
            ]),
            Row(children: [
              Image(
                image: AssetImage("assets/images/car2.jpg"),
                width: 300.0,
                height: 350.0,
              )
            ]),
            Row(children: [
              Text('Kloppocar Asset',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
            ]),
            Padding(
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
