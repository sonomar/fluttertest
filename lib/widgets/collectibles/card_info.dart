import 'package:flutter/material.dart';
import '../missions/latest_active_mission.dart';

class CardInfo extends StatelessWidget {
  const CardInfo(
      {super.key,
      required this.selectedCollectible,
      required this.missions,
      required this.missionUsers,
      required this.recentColl});
  final Map selectedCollectible;
  final List<dynamic> missions;
  final List<dynamic> missionUsers;
  final dynamic recentColl;

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

  Future<void> _qrDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(0),
              content: GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child: Container(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/qrcodesample.png')),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      IntrinsicHeight(
          child: Stack(children: [
        Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x80999999),
                  spreadRadius: .5,
                  blurRadius: 10,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ],
            )),
        Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  //                   <--- left side
                  color: Color(0x80999999),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffd622ca),
                      ),
                      onPressed: () {
                        _qrDialog(context);
                      },
                      child: Text('Transfer Asset',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'ChakraPetch',
                          ))),
                )
              ],
            )),
      ])),
      Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  '4  |',
                  style: TextStyle(
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 153, 153, 153),
                      fontSize: 26),
                )),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                    width: 400,
                    child: Text(selectedCollectible["name"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'ChakraPetch',
                          fontWeight: FontWeight.bold,
                        ))))
          ])),
      Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 20.0, bottom: 10.0),
          child: getLatestActiveMission(
              context, missions, missionUsers, recentColl,
              isViewer: true)),
      Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 20.0, bottom: 10.0),
          child: SizedBox(
              width: 400,
              child: Text(selectedCollectible["description"],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  )))),
      Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(alignment: Alignment.topCenter, children: [
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
                            selectedCollectible["collectibleId"].toString()),
                        lineItem("Auflage",
                            selectedCollectible["circulation"].toString()),
                        lineItem("Erscheinungsdatum",
                            selectedCollectible["publicationDate"].toString())
                      ]))),
            ]),
            Text("DATEN",
                style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 20,
                  fontFamily: 'ChakraPetch',
                ))
          ]))
    ]);
  }
}
