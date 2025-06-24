import 'package:flutter/material.dart';
import '../../screens/subscreens/missions/award_details.dart';
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
          linearGradient: const LinearGradient(
            colors: [
              Color(0xffd622ca), // Your original start color
              Color.fromARGB(255, 251, 102,
                  241), // A vibrant pink for the end of the gradient
            ],
          ),
        ),
      ));
}

Widget missionWidget(BuildContext pageContext, Map? mission, Map? missionUser) {
  final String getTitle = mission?['title'] ?? 'No Title';
  final String? getLogoUrl = mission?['imgRef']?['url'];
  final int missionGoal = mission?['goal'] ?? 999999;
  final int missionProgress = missionUser?['progress'] ?? 0;
  final bool goalReached = missionGoal > 0 && missionProgress >= missionGoal;
  final bool isCompleted = missionUser?['completed'] ?? false;

  return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: isCompleted
            ? null
            : () {
                Navigator.push(
                  pageContext,
                  MaterialPageRoute(
                    builder: (context) => AwardDetails(
                      selectedAward: mission,
                      selectedAwardUser: missionUser,
                    ),
                  ),
                );
              },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  // Change header color based on state: Completed, Claimable, or In-Progress.
                  color: isCompleted
                      ? Colors.grey[600] // A neutral grey for completed
                      : goalReached
                          ? Color.fromARGB(
                              255, 214, 34, 202) // A bright color for claimable
                          : Colors.black, // Default for in-progress
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  // Update the header text to reflect the mission's state.
                  isCompleted
                      ? 'Completed'
                      : goalReached
                          ? 'Claim Your Reward'
                          : 'Mission',
                  style: const TextStyle(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        getTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'ChakraPetch',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (getLogoUrl != null)
                      Image.network(
                        getLogoUrl,
                        width: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 40),
                      )
                    else
                      const Icon(Icons.image_not_supported, size: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 5, top: 10),
                child: Container(
                  alignment: Alignment.center,
                  child: progressBar(pageContext, mission, missionUser),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, top: 5, right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${missionProgress.toString()} / ${missionGoal.toString()}',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
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
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 40.0, bottom: 10, right: 20),
                  child: getMission['imgRef']['url'] != null
                      ? Image.network(getMission['imgRef']['url'],
                          width: 50, fit: BoxFit.fill)
                      : Image.asset('assets/images/car1.png',
                          width: 120, height: 50, fit: BoxFit.fill)),
            ),
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
            Padding(
                padding:
                    const EdgeInsets.only(left: 40.0, bottom: 10, right: 20),
                child: getMission['imgRef']['url'] != null
                    ? Image.network(getMission['imgRef']['url'],
                        width: 50, fit: BoxFit.fill)
                    : Image.asset('assets/images/car1.png',
                        width: 120, height: 50, fit: BoxFit.fill)),
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
