import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/mission_model.dart';
import '../../../helpers/localization_helper.dart';
import './award_details.dart';

class AwardScreen extends StatefulWidget {
  const AwardScreen({super.key});

  @override
  State<AwardScreen> createState() => _AwardScreenState();
}

class _AwardScreenState extends State<AwardScreen> {
  @override
  void initState() {
    super.initState();
    // Load missions when the screen is first built
    // Use addPostFrameCallback to ensure the provider is available.
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
        title: Text(translate("missions_awards", context)),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          color: Colors.black,
          fontFamily: 'ChakraPetch',
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Consumer<MissionModel>(
        builder: (context, missionModel, child) {
          if (missionModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Create a list of completed awards by combining Mission and MissionUser data.
          final completedAwards = missionModel.missionUsers
              .where((mu) => mu['completed'] == true)
              .map((mu) {
                // Find the corresponding mission details for this missionUser
                final mission = missionModel.missions.firstWhere(
                  (m) => m['missionId'] == mu['missionId'],
                  orElse: () =>
                      null, // Return null if no matching mission is found
                );
                if (mission == null) return null;
                // Return a combined object
                return {'missionUser': mu, 'mission': mission};
              })
              .where((item) => item != null) // Filter out any nulls
              .toList();

          if (completedAwards.isEmpty) {
            return const Center(
              child: Text(
                'You have not earned any awards yet.\nComplete missions to see them here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              // --- Sorting Dropdown ---
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       const Text('Sort by: '),
              //       DropdownButton<MissionSortBy>(
              //         value: missionModel.missionSortBy,
              //         onChanged: (MissionSortBy? newValue) {
              //           if (newValue != null) {
              //             missionModel.sortMissions(newValue);
              //           }
              //         },
              //         items: MissionSortBy.values
              //             .map<DropdownMenuItem<MissionSortBy>>(
              //                 (MissionSortBy value) {
              //           return DropdownMenuItem<MissionSortBy>(
              //             value: value,
              //             child: Text(
              //               value == MissionSortBy.title ? 'Title' : 'Date',
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //     ],
              //   ),
              // ),
              // --- Awards Grid ---
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: completedAwards.length,
                    itemBuilder: (context, index) {
                      final awardData = completedAwards[index]!;
                      final mission = awardData['mission'];
                      final missionUser = awardData['missionUser'];
                      final imageUrl = mission['imgRef']?['load'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AwardDetails(
                                selectedAward: mission,
                                selectedAwardUser: missionUser,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4.0,
                          clipBehavior: Clip.antiAlias,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: imageUrl != null
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
