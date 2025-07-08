import 'package:flutter/material.dart';
import '../widgets/item_button.dart';
import './subscreens/missions/missions.dart';
import '../../helpers/localization_helper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.userData});
  final dynamic userData;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

Widget getUserPic(userPic, defaultImg, radius) {
  final subStrings = <String>["png", "jpg", "jpeg", "gif"];
  var result = subStrings.any(userPic.contains);
  if (result == true) {
    return shadowCircle(userPic, radius, true);
  }
  return shadowCircle(defaultImg, radius, false);
}

Widget shadowCircle(imageLink, radius, isWeb) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(blurRadius: 5, color: Colors.black, spreadRadius: 0)
      ],
    ),
    child: isWeb
        ? CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(imageLink),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: AssetImage(imageLink),
          ),
  );
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final userPic = user['profileImg'];
    final userRank = user['userRank']["title"];
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            title: Text(translate("game_screen_build_title", context)),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontFamily: 'ChakraPetch',
              fontWeight: FontWeight.w500,
            )),
        body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(children: [
              Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Text(
                          "${userRank ?? translate("game_screen_build_default_rank", context)}",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2.56,
                              color: Colors.black,
                              fontFamily: 'ChakraPetch',
                              fontWeight: FontWeight.w700),
                        )),
                    Positioned(
                        top: -20,
                        child: userPic != null
                            ? getUserPic(
                                userPic, 'assets/images/profile.jpg', 18.0)
                            : shadowCircle(
                                'assets/images/profile.jpg', 18.0, false)),
                  ]),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: <Widget>[
                          ItemButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Missions(userData: widget.userData)),
                                );
                              },
                              title: translate("missions_header", context),
                              active: true),
                        ],
                      )))
            ])));
  }
}
