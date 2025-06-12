import 'package:flutter/material.dart';
import '../models/app_localizations.dart';
import 'package:kloppocar_app/screens/subscreens/news_posts/news_post_details.dart';
import 'package:provider/provider.dart';
import 'package:kloppocar_app/screens/subscreens/collectibles/collectible_details.dart';
import 'package:kloppocar_app/screens/profile_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:async';
import 'subscreens/notifications/notifications_page.dart';
import '../models/user_model.dart';
import '../models/mission_model.dart';
import '../models/collectible_model.dart';
import '../models/notification_provider.dart';
import '../models/community_model.dart';
import '../models/news_post_model.dart';
import '../widgets/shadow_circle.dart';
import '../widgets/object_viewer.dart';
import '../widgets/community/community_missions.dart';
import '../widgets/missions/latest_active_mission.dart';
import '../helpers/localization_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key,
      PageStorageKey<String>? pageKey,
      required this.qrcode,
      this.userData});
  final String qrcode;
  final dynamic userData;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 6, minutes: 59, seconds: 43);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('>>> MyHomePage: initState called at ${DateTime.now()} <<<');
    // Defer the calls to load data until after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionModel>(context, listen: false).loadMissions();
      Provider.of<CollectibleModel>(context, listen: false).loadCollectibles();
      Provider.of<NewsPostModel>(context, listen: false).loadNewsPosts();
      Provider.of<CommunityModel>(context, listen: false)
          .loadCommunityChallenge();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget newsItem(type, postedDate, header) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Text(type,
                  style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 2.56,
                      color: Colors.white,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w700)),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  postedDate,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  )),
                ))
          ]),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                header,
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                )),
              )),
          const Divider(height: 20, thickness: 1, color: Color(0x80999999)),
        ]));
  }

  Widget getUserPic(userPic, defaultImg, radius) {
    final subStrings = <String>["png", "jpg", "jpeg", "gif"];
    var result = subStrings.any(userPic.contains);
    if (result == true) {
      return shadowCircle(userPic, radius, true);
    }
    return shadowCircle(defaultImg, radius, false);
  }

  dynamic _getAssetUrlFromCollectible(dynamic collectibleData) {
    dynamic urls = {
      'url': 'https://deins.s3.eu-central-1.amazonaws.com/images/car3.png',
      'placeholder':
          'https://deins.s3.eu-central-1.amazonaws.com/Objects3d/kloppocar/images/k1.png'
    };
    if (collectibleData == null || collectibleData is! Map) {
      return urls;
    }
    final dynamic embedRef = collectibleData['embedRef'];
    final dynamic imageRef = collectibleData['imageRef'];
    if (embedRef == null || imageRef == null) {
      return urls;
    }
    urls['url'] = embedRef['url'];
    urls['placeholder'] = imageRef['load'];
    if (urls.isNotEmpty) {
      return urls;
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userModel = context.watch<UserModel>();
    final currentUser = userModel.currentUser;
    if (userModel.isLoading && currentUser == null) {
      // More specific loading condition
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()));
    }
    if (currentUser == null) {
      return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Text("User data not available.")));
    }
    final userPic = currentUser["profileImg"];
    final communityModel = context.watch<CommunityModel>();
    final communityChallenge = communityModel.communityChallenge;
    final missionModel = context.watch<MissionModel>();
    final missions = missionModel.missions;
    final missionUsers = missionModel.missionUsers;
    final newsPostModel = context.watch<NewsPostModel>();
    final newsPosts = newsPostModel.newsPosts;
    final collectibleModel = context.watch<CollectibleModel>();
    final collectibles = collectibleModel.collectionCollectibles;
    final userCollectibles = collectibleModel.userCollectibles;
    final notificationProvider = context.watch<NotificationProvider>();
    final int unreadNotifications =
        notificationProvider.unreadNotificationCount;

    final recentColl = getLatestCollectible(collectibles, userCollectibles);
    final recentUrls = _getAssetUrlFromCollectible(recentColl);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: userModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child:
                            // child: userPic != null
                            // ? getUserPic(
                            //     userPic, 'assets/images/profile.jpg', 18.0)
                            // : shadowCircle(
                            shadowCircle(
                                'assets/images/kloppocarIcon.png', 18, false)),
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              // Text(currentUser["username"],
                              Text(
                                  translate(
                                      "home_header_username_default", context),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200)),
                              // Padding(
                              //     padding: const EdgeInsets.only(left: 5.0),
                              //     child: SizedBox(
                              //         width: 20,
                              //         child: GestureDetector(
                              //             onTap: () {
                              //               Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                       builder: (context) =>
                              //                           ProfileScreen()));
                              //             },
                              //             child: Image.asset(
                              //                 "assets/images/gear.png")))),
                            ]),
                            Text(
                                currentUser["userRank"] != null
                                    ? currentUser["userRank"]["title"]
                                    : translate(
                                        "home_header_rank_default", context),
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700)),
                          ],
                        ))
                  ])),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xffd622ca),
                          width: 1,
                        ),
                      ),
                      child: SvgPicture.asset('assets/images/bell.svg')),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()),
                    );
                  },
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        // Ensure minimum size
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                          child: Text(
                        unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Stack(alignment: Alignment.center, children: [
                  Divider(height: 20, thickness: 1, color: Color(0x80999999)),
                  shadowCircle('assets/images/car.jpg', 20.0, false),
                ]),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: GestureDetector(
                          onTap: () {
                            if (recentColl != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CollectibleDetails(
                                          selectedCollectible: recentColl)));
                            } else {
                              {}
                            }
                          },
                          child: SizedBox(
                            height: 400,
                            child: ObjectViewer(
                                asset: recentUrls['url'],
                                placeholder: recentUrls[
                                    'placeholder'] // Provide a default or handle null
                                ),
                          ))),
                ),
                getLatestActiveMission(
                    context, missions, missionUsers, recentColl),
              ])),
          communityChallengeWidget(_formatTime(_remainingTime), context,
              communityChallenge, 200, context),
          Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 10),
              child: Column(children: [
                sectionHeader(translate("home_game_section_label", context)),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(15),
                    child: listMissions(context, missions, missionUsers)),
                sectionHeader(translate("home_news_section_label", context)),
                if (newsPosts.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsPostDetails(
                                  selectedNewsPost: newsPosts[0])));
                    },
                    child: newsItem(
                      newsPosts[0]["type"],
                      newsPosts[0]["updatedDt"],
                      newsPosts[0]["header"],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsPostDetails(
                                  selectedNewsPost: newsPosts[1])));
                    },
                    child: newsItem(
                      newsPosts[1]["type"],
                      newsPosts[1]["updatedDt"],
                      newsPosts[1]["header"],
                    ),
                  ),
                ] else ...[
                  // Show a loading indicator while news is being fetched
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                ]
              ]))
        ])));
  }

  /// Section Header Widget
  Widget sectionHeader(String header) {
    return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Stack(alignment: Alignment.center, children: [
          const Divider(height: 20, thickness: 1, color: Color(0x80999999)),
          Text(header,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                backgroundColor: Colors.white,
              )),
        ]));
  }

  /// Challenge Box
  Widget challengeBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              child: Text(
                translate("banner_welcome_header", context),
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
                  left: 15, top: 40, right: 15, bottom: 10),
              child: Row(
                children: [
                  shadowCircle('assets/images/car.jpg', 20.0, false),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate("banner_welcome_body", context),
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //     alignment: Alignment.center,
            //     padding: EdgeInsets.all(5),
            //     child: progressBar(.35)),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Kloppocar-Puzzle-Collection',
            //         style: GoogleFonts.roboto(
            //             textStyle: TextStyle(
            //           fontSize: 12,
            //           letterSpacing: 1,
            //           color: Colors.black,
            //           fontWeight: FontWeight.w300,
            //         )),
            //       ),
            //       Text(
            //         '4/7',
            //         style: GoogleFonts.roboto(
            //             textStyle: TextStyle(
            //           fontSize: 12,
            //           color: Colors.black,
            //           fontWeight: FontWeight.w300,
            //         )),
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget progressBar(progressPercent) {
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
}
