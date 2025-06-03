import 'package:flutter/material.dart';
import '../../screens/subscreens/missions/award_details.dart';
import '../shadow_circle.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

Widget progressBar(pageContext, mission, missionUser) {
  final getMission = mission;
  final getMissionUser = missionUser;
  double progressPercent = 0.0;
  final int missionGoal = (getMission != null && getMission['goal'] != null)
      ? getMission['goal']
      : 0; // Default value for int
  final int missionProgress =
      (getMissionUser != null && getMissionUser['progress'] != null)
          ? getMissionUser['progress']
          : 0; // Default value for int

  if (missionGoal > 0) {
    // Avoid division by zero
    progressPercent = missionProgress / missionGoal;
  }
  return Container(
      width: MediaQuery.of(pageContext).size.width - 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0x80999999)),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 0, right: 0),
        child: LinearPercentIndicator(
          animation: true,
          animationDuration: 2000,
          lineHeight: 5.0,
          percent: progressPercent,
          backgroundColor: Colors.transparent,
          barRadius: const Radius.circular(90),
          progressColor: Color(0xffd622ca),
        ),
      ));
}

Widget missionWidget(pageContext, mission, missionUser) {
  final getMission = mission;
  final getMissionUser = missionUser;
  final String getTitle = (getMission != null && getMission['title'] != null)
      ? getMission['title']
      : 'No Title'; // Default value
  final String getLogo =
      (getMission != null && getMission['imgRef']["url"] != null)
          ? getMission['imgRef']['url']
          : 'assets/images/deins_logo.png'; // Default value
  final String missionGoal = (getMission != null && getMission['goal'] != null)
      ? getMission['goal'].toString()
      : '0'; // Default value
  final String missionProgress =
      (getMissionUser != null && getMissionUser['progress'] != null)
          ? getMissionUser['progress'].toString()
          : '0'; // Default value
  return GestureDetector(
      onTap: () {
        Navigator.push(
          pageContext,
          MaterialPageRoute(
            builder: (context) => AwardDetails(
              selectedAward: getMission,
              selectedAwardUser: getMissionUser,
            ),
          ),
        );
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              child: const Text(
                'Mission',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'ChakraPetch',
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 20, right: 15, bottom: 10),
              child: Row(
                children: [
                  shadowCircle('assets/images/car.jpg', 20.0, false),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10),
                child: Container(
                    alignment: Alignment.center,
                    child: progressBar(pageContext, mission, missionUser))),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 5, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$missionProgress / $missionGoal',
                      style: TextStyle(fontSize: 12, color: Colors.black))
                ],
              ),
            ),
          ])));
}

Widget homeMissionWidget(pageContext, mission, missionUser) {
  final getMission = mission;
  final getMissionUser = missionUser;
  final String getTitle = (getMission != null && getMission['title'] != null)
      ? getMission['title']
      : 'No Title'; // Default value
  final String getLogo =
      (getMission != null && getMission['imgRef']['url'] != null)
          ? getMission['imgRef']['url']
          : 'assets/images/deins_logo.png'; // Default value
  final String missionGoal = (getMission != null && getMission['goal'] != null)
      ? getMission['goal'].toString()
      : '0'; // Default value
  final String missionProgress =
      (getMissionUser != null && getMissionUser['progress'] != null)
          ? getMissionUser['progress'].toString()
          : '0'; // Default value
  return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Container(
              padding:
                  const EdgeInsets.only(left: 40, right: 40, top: 7, bottom: 7),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Text("MISSION",
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.56,
                      color: Colors.white,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w700)),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  getTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                )),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    pageContext,
                    MaterialPageRoute(
                      builder: (context) => AwardDetails(
                        selectedAward: getMission,
                        selectedAwardUser: getMissionUser,
                      ),
                    ),
                  );
                },
                child: Stack(alignment: Alignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Image.asset('assets/images/silvertab.png',
                          width: 120, height: 50, fit: BoxFit.fill)),
                  Text("Selten",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ))
                ])),
          ],
        ),
        Container(
            alignment: Alignment.center,
            child: progressBar(pageContext, mission, missionUser)),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 5, right: 20, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$missionProgress / $missionGoal',
                  style: TextStyle(fontSize: 12, color: Colors.black))
            ],
          ),
        ),
      ]));
}

Widget viewMissionWidget(pageContext, mission, missionUser) {
  final getMission = mission;
  final getMissionUser = missionUser;
  final String getTitle = (getMission != null && getMission['title'] != null)
      ? getMission['title']
      : 'No Title'; // Default value
  final String getLogo =
      (getMission != null && getMission['imgRef']['url'] != null)
          ? getMission['imgRef']['url']
          : 'assets/images/deins_logo.png'; // Default value
  final String missionGoal = (getMission != null && getMission['goal'] != null)
      ? getMission['goal'].toString()
      : '0'; // Default value
  final String missionProgress =
      (getMissionUser != null && getMissionUser['progress'] != null)
          ? getMissionUser['progress'].toString()
          : '0'; // Default value
  return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  getTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                )),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    pageContext,
                    MaterialPageRoute(
                      builder: (context) => AwardDetails(
                        selectedAward: getMission,
                        selectedAwardUser: getMissionUser,
                      ),
                    ),
                  );
                },
                child: Stack(alignment: Alignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Image.asset('assets/images/silvertab.png',
                          width: 120, height: 50, fit: BoxFit.fill)),
                  Text("Selten",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ))
                ])),
          ],
        ),
        Container(
            alignment: Alignment.center,
            child: progressBar(pageContext, mission, missionUser)),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 5, right: 20, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$missionProgress / $missionGoal',
                  style: TextStyle(fontSize: 12, color: Colors.black))
            ],
          ),
        ),
      ]));
}
