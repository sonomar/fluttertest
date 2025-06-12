import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/mission_model.dart';
import '../../../helpers/localization_helper.dart';
import '../../../widgets/missions/mission_view.dart'; // Import for missionWidget
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
      Provider.of<MissionModel>(context, listen: false).loadMissions();
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
                  style: TextStyle(color: Color(0xffd622ca))),
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

          // Create a combined list of missions with their user-specific data.
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

          // Sort the combined list: completed missions go to the bottom.
          missionWithUserData.sort((a, b) {
            bool isACompleted = a['missionUser']?['completed'] ?? false;
            bool isBCompleted = b['missionUser']?['completed'] ?? false;

            if (isACompleted && !isBCompleted) return 1;
            if (!isACompleted && isBCompleted) return -1;
            return 0;
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- START OF FIX ---
              // The featured mission widget and the divider have been removed.
              // The ListView.builder is now the only widget displaying the missions.
              Expanded(
                child: ListView.builder(
                  // Added top padding to give the list some space from the AppBar.
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
              // --- END OF FIX ---
            ],
          );
        },
      ),
    );
  }
}
