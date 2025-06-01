import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../models/missions_model.dart';
import './award_details.dart';

class Missions extends StatefulWidget {
  const Missions({super.key, this.userData});
  final dynamic userData;

  @override
  State<Missions> createState() => _MissionsState();
}

class _MissionsState extends State<Missions> {
  @override
  void initState() {
    super.initState();
    Provider.of<MissionModel>(context, listen: false).loadMissions();
  }

  @override
  Widget build(BuildContext context) {
    final missionModel = context.watch<MissionModel>();
    final missions = missionModel.missions;
    final missionUsers = missionModel.missionUsers;
    final numAssets = missionUsers.length;
    final isLoading = missionModel.isLoading;
    final errorMessage = missionModel.errorMessage;

    Widget progressBar(mission, missionUser) {
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
          width: MediaQuery.of(context).size.width - 50,
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

    Widget missionWidget(mission, missionUser) {
      final getMission = mission;
      final getMissionUser = missionUser;
      final String getTitle =
          (getMission != null && getMission['title'] != null)
              ? getMission['title']
              : 'No Title'; // Default value
      final String getLogo =
          (getMission != null && getMission['imgRef'][0] != null)
              ? getMission['imgRef'][0]
              : 'assets/images/deins_logo.png'; // Default value
      final String missionGoal =
          (getMission != null && getMission['goal'] != null)
              ? getMission['goal'].toString()
              : '0'; // Default value
      final String missionProgress =
          (getMissionUser != null && getMissionUser['progress'] != null)
              ? getMissionUser['progress'].toString()
              : '0'; // Default value
      return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40, top: 7, bottom: 7),
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
                        context,
                        MaterialPageRoute(
                          builder: (context) => AwardDetails(
                            selectedAward: mission,
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
                child: progressBar(mission, missionUser)),
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

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Missions'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null && errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Error: $errorMessage\n\nNo missions could be loaded.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : missions.isEmpty
                  ? const Center(
                      child: Text(
                        'No missions available.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      // <-- Wrapped the content here
                      child: Container(
                        // <-- Wrapped the content in a Container
                        padding: const EdgeInsets.all(
                            20), // This padding is already applied
                        child: Column(children: [
                          ...missionUsers.map((missionUser) {
                            // It's often cleaner to iterate over `missions` if that's what you're displaying
                            // Find the corresponding missionUser for this mission
                            final correspondingMission = missions.firstWhere(
                              (user) =>
                                  user['missionId'].toString() ==
                                  missionUser['missionId'].toString(),
                              orElse: () =>
                                  null, // Return null if no matching mission is found
                            );

                            if (correspondingMission != null) {
                              return Container(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  left: 5,
                                  right: 5,
                                  bottom: 20,
                                ),
                                child: missionWidget(
                                    correspondingMission, missionUser),
                              );
                            } else {
                              return const SizedBox
                                  .shrink(); // Handle cases where a mission has no associated user
                            }
                          }).toList(),
                        ]),
                      ),
                    ),
    );
  }
}
