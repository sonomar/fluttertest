import 'package:flutter/material.dart';
import '../../../helpers/localization_helper.dart';
import '../missions/latest_active_mission.dart';
import '../../helpers/date_formatter.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({
    super.key,
    required this.selectedCollectible,
    required this.missions,
    required this.missionUsers,
    required this.recentColl,
    required this.selectedUserCollectible,
    this.onTradeInitiate,
  });
  final Map selectedCollectible;
  final Map selectedUserCollectible;
  final List<dynamic> missions;
  final List<dynamic> missionUsers;
  final dynamic recentColl;
  final Function()? onTradeInitiate;

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
                        if (onTradeInitiate != null) {
                          onTradeInitiate!();
                        }
                      },
                      child: Text(
                          translate(
                              "collection_details_transfer_button", context),
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
          child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: SizedBox(
                  width: 400,
                  child: Text(selectedCollectible["name"],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontFamily: 'ChakraPetch',
                        fontWeight: FontWeight.bold,
                      ))))),
      Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 20.0, bottom: 10.0),
          child: getLatestActiveMission(
              context, missions, missionUsers, recentColl,
              isViewer: true)),
      Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 10.0),
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
                        lineItem(
                            "Mint",
                            selectedUserCollectible['mint']?.toString() ??
                                'N/A'),
                        lineItem("Auflage",
                            selectedCollectible["circulation"].toString()),
                        lineItem(
                            "Erscheinungsdatum",
                            formatDate(
                                context,
                                selectedCollectible["publicationDate"]
                                    .toString(),
                                format: "d MMMM, yyyy"))
                      ]))),
            ]),
            Text(translate("collection_details_info_section", context),
                style: TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 20,
                  fontFamily: 'ChakraPetch',
                ))
          ]))
    ]);
  }
}
