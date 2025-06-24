import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/mission_model.dart';
import '../../../helpers/localization_helper.dart';
import '../../../widgets/missions/mission_view.dart';
import './award_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MissionModel>().loadMissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(translate("missions_header", context)),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontWeight: FontWeight.w500,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.emoji_events, color: Color(0xffd622ca)),
              label: Text(translate("missions_awards", context),
                  style: const TextStyle(color: Color(0xffd622ca))),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AwardScreen()),
                );
              },
            ),
          )
        ],
      ),
      body: Consumer<MissionModel>(
        builder: (context, missionModel, child) {
          if (missionModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (missionModel.missions.isEmpty) {
            return Center(child: Text(translate("missions_none", context)));
          }

          final List<Map<String, dynamic>> missionWithUserData = missionModel
              .missions
              .map((mission) {
                final missionUser = missionModel.missionUsers.firstWhere(
                  (mu) => mu['missionId'] == mission['missionId'],
                  orElse: () => <String, dynamic>{},
                );
                return {'mission': mission, 'missionUser': missionUser};
              })
              .where((item) =>
                  item['missionUser'] != null &&
                  (item['missionUser'] as Map).isNotEmpty)
              .toList();

          missionWithUserData.sort((a, b) {
            final int progressA = a['missionUser']?['progress'] ?? 0;
            final int goalA = a['mission']?['goal'] ?? 1;
            final bool isAGoalReached = goalA > 0 && progressA >= goalA;
            final bool isACompleted = a['missionUser']?['completed'] ?? false;

            final int progressB = b['missionUser']?['progress'] ?? 0;
            final int goalB = b['mission']?['goal'] ?? 1;
            final bool isBGoalReached = goalB > 0 && progressB >= goalB;
            final bool isBCompleted = b['missionUser']?['completed'] ?? false;

            int getStateValue(bool goalReached, bool completed) {
              if (completed) {
                return 3; // Completed missions go to the bottom.
              }
              if (goalReached) {
                return 1; // Claimable (goal reached) missions go to the top.
              }
              return 2; // In-progress missions are in the middle.
            }

            final stateA = getStateValue(isAGoalReached, isACompleted);
            final stateB = getStateValue(isBGoalReached, isBCompleted);

            // Compare the states to sort the list.
            return stateA.compareTo(stateB);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                  itemCount: missionWithUserData.length,
                  itemBuilder: (context, index) {
                    final missionData = missionWithUserData[index];
                    return missionWidget(
                      context,
                      missionData['mission'],
                      missionData['missionUser'],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
