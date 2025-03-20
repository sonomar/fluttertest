import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({super.key, required this.selectedCollectible});
  final Map selectedCollectible;

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
    return SingleChildScrollView(
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                      width: 400,
                      child: Text(selectedCollectible["name"],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontFamily: 'ChakraPetch',
                            fontWeight: FontWeight.bold,
                          )))),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: SizedBox(
                      width: 400,
                      child: Text(selectedCollectible["description"],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          )))),
              Stack(alignment: Alignment.topCenter, children: [
                Column(children: [
                  SizedBox(height: 2),
                  Container(
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 20.0, right: 20.0),
                          child: Column(children: [
                            lineItem("Kartennummer",
                                selectedCollectible["collection-number"]),
                            lineItem("Collectionsname",
                                selectedCollectible["collection-name"]),
                            lineItem(
                                "Community", selectedCollectible["community"]),
                            lineItem("Sponsor", selectedCollectible["sponsor"]),
                            lineItem(
                                "Auflage", selectedCollectible["circulation"]),
                            lineItem("Erscheinungsdatum",
                                selectedCollectible["publication-date"])
                          ]))),
                ]),
                Text("DATEN",
                    style: TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 20,
                      fontFamily: 'ChakraPetch',
                    ))
              ])
            ])));
  }
}
