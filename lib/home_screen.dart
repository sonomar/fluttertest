import 'package:flutter/material.dart';
import 'package:kloppocar_app/collectibles/collectible.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'notifications_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.qrcode});
  final String qrcode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 6, minutes: 59, seconds: 43);
  int unreadNotifications = 0; // Hardcoded for now
  List _newsItems = [];
  Map exampleCollectible = {
    "collectibleId": 1,
    "label": "item-test1",
    "name": "Party Door",
    "category": 1,
    "collection": 1,
    "description":
        "This is item test 1. This is great because this test item is really cool. It's part of the Kloppocar prep app and everything about it is going to be fun to collect and fun to trade! DEINS cards are the digital trading platform of the future!",
    "imageRef": "assets/images/car1.png",
    "vidRef": "assets/images/car1.png",
    "QRRef": "assets/images/car1.png",
    "EmbedRef": "assets/images/car1.png",
    "createdDt": "2024-11-18 10:36:22.640",
    "updatedDt": "2024-11-18 10:36:22.640",
    "active": true,
    "collection-name": "Kloppocar-Puzzle-Collection",
    "collection-number": "01-01",
    "community": "Kloppocar Community",
    "sponsor": "Mini-Cooper",
    "sponsor-url": "https://www.mini.com",
    "circulation": "20,000",
    "publication-date": "20.03.2025"
  };

  Future<void> readItemJson() async {
    final String response =
        await rootBundle.loadString('assets/json/news.json');
    final data = await json.decode(response);
    setState(() {
      _newsItems = data['news'];
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    readItemJson();
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

  Widget communityChallengeWidget(String time) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child:
                  Image.asset('assets/images/carheader.jpg', fit: BoxFit.cover),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/paint.jpg'),
                  )),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffd622ca),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ]),
            Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                child: Text(
                  'Community-Ziel läuft bald ab!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                )),
            const SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Text(
                  'Es fehlen noch 212 Assets bis zum Ziel. Trage jetzt dazu bei und hole dir noch Assets. Zum Beispiel beim Formel 1-Rennen in Spielberg oder erfülle Challenges. Die Community zählt auf dich. Viel Glück!',
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  )),
                )),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget turLWidget() {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Tür L',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  )),
              Stack(alignment: Alignment.center, children: [
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
              ])
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: progressBar(0.33)),
          const Padding(
            padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kloppocar-Puzzle-Collection',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                Text('2/6', style: TextStyle(fontSize: 12, color: Colors.black))
              ],
            ),
          ),
        ]));
  }

  Widget kloppocarWidget() {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Text("COMMUNITY",
                style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.56,
                    color: Colors.white,
                    fontFamily: 'ChakraPetch',
                    fontWeight: FontWeight.w700)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Kloppocar',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(0xffd622ca),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Text("+25% Heute",
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ))),
                  )),
              Padding(
                  padding: EdgeInsets.only(bottom: 10, right: 10),
                  child: Container(
                    alignment: Alignment.center,
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/icon-trophy.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
            ],
          ),
          Container(alignment: Alignment.center, child: progressBar(0.8)),
          const Padding(
            padding: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kloppocar-Community-Challenge',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                Text('988/1200',
                    style: TextStyle(fontSize: 12, color: Colors.black))
              ],
            ),
          ),
        ]));
  }

  Widget newsItem(category, postdate, content) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Text(category,
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
                  postdate,
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
                content,
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

  Widget shadowCircle(imageLink, radius) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black, spreadRadius: 0)
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(imageLink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: shadowCircle('assets/images/profile.jpg', 18.0)),
                const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEINS-Tester',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                        Text('Titel: Master Collector',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w200)),
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
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  shadowCircle('assets/images/car.jpg', 20.0),
                ]),
                Align(
                    alignment: Alignment.center,
                    child: Stack(alignment: Alignment.center, children: [
                      IgnorePointer(
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                  height: 400,
                                  child: Image.asset(
                                      'assets/images/covercard.png',
                                      fit: BoxFit.cover)))),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Collectible(
                                      selectedCollectible:
                                          exampleCollectible)));
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Text('i')),
                      ),
                    ])),
                turLWidget(),
                kloppocarWidget(),
              ])),
          communityChallengeWidget(_formatTime(_remainingTime)),
          Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 10),
              child: Column(children: [
                sectionHeader('CHALLENGES'),
                challengeBox(),
                sectionHeader('Nachrichten'),
                if (_newsItems.length >= 2) ...[
                  newsItem(
                    _newsItems[0]["category"],
                    _newsItems[0]["post-date"],
                    _newsItems[0]["content"],
                    ),
                    newsItem(
                      _newsItems[1]["category"],
                      _newsItems[1]["post-date"],
                      _newsItems[1]["content"],
                    ),
                  ] else if (_newsItems.length == 1) ...[
                      newsItem(
                        _newsItems[0]["category"],
                        _newsItems[0]["post-date"],
                        _newsItems[0]["content"],
                      ),
                    ] else ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text('No news items available.',
                              style: TextStyle(fontSize: 16, color: Colors.black)),
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
              child: const Text(
                'Community-Challenge',
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
                  shadowCircle('assets/images/car.jpg', 20.0),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Vervollständige die Kloppocar-Puzzle-Collection.',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5),
                child: progressBar(.35)),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kloppocar-Puzzle-Collection',
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    )),
                  ),
                  Text(
                    '4/7',
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    )),
                  )
                ],
              ),
            ),
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
            lineHeight: 3.0,
            percent: progressPercent,
            backgroundColor: Colors.transparent,
            barRadius: const Radius.circular(90),
            progressColor: Color(0xffd622ca),
          ),
        ));
  }
}
