import 'package:flutter/material.dart';
import '../../../helpers/localization_helper.dart';
import './award_processing_screen.dart';
import './mission_view.dart';
import '../../helpers/date_formatter.dart';

class AwardInfo extends StatelessWidget {
  const AwardInfo(
      {super.key,
      required this.selectedAward,
      required this.selectedAwardUser});

  final dynamic selectedAward;
  final dynamic selectedAwardUser;

  void _claimReward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AwardProcessingScreen(
          selectedAward: selectedAward,
          selectedAwardUser: selectedAwardUser,
        ),
      ),
    );
  }

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
    final int missionGoal = selectedAward?['goal'] ?? 99999;
    final int missionProgress = selectedAwardUser?['progress'] ?? 0;
    final bool isCompleted = selectedAwardUser?['completed'] ?? false;
    final bool goalReached = missionProgress >= missionGoal;
    return Column(children: [
      // Conditionally show the 'Claim Reward' button.
      if (goalReached && !isCompleted)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffd622ca),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () => _claimReward(context),
            child: const Text(
              'Claim Reward',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'ChakraPetch',
              ),
            ),
          ),
        ),
      Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                    child: Text(selectedAward["title"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'ChakraPetch',
                          fontWeight: FontWeight.bold,
                        )))),
          ])),
      if (selectedAward != null && selectedAwardUser != null)
        viewMissionWidget(context, selectedAward, selectedAwardUser,
            isMission: true),
      Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 10.0),
          child: SizedBox(
              width: 400,
              child: Text(selectedAward["description"],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  )))),
      Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(alignment: Alignment.topCenter, children: [
            Column(children: [
              const SizedBox(height: 2),
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
                        lineItem("Missionnummer",
                            selectedAward["missionId"].toString()),
                        lineItem("Reward", selectedAward["reward"].toString()),
                        lineItem(
                            "Mission Start",
                            formatDate(
                                context, selectedAward["createdDt"].toString(),
                                format: "d MMMM, yyyy - h:mm"))
                      ]))),
            ]),
            Text(translate("mission_details_info_section", context),
                style: const TextStyle(
                  backgroundColor: Colors.white,
                  fontSize: 20,
                  fontFamily: 'ChakraPetch',
                ))
          ]))
    ]);
  }
}
