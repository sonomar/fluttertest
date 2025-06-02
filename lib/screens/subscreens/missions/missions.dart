import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/missions_model.dart';
import '../../../widgets/missions/mission_view.dart';

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

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null && errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $errorMessage\n\nNo missions could be loaded.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
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
                        padding: const EdgeInsets.only(
                            bottom: 5, left: 20, right: 20),
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
                                    context, correspondingMission, missionUser),
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
