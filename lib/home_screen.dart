import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'notifications_page.dart';
import 'widgets/object_viewer.dart'; // notification page import

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
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community-Ziel läuft bald ab!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Es fehlen noch 212 Assets bis zum Ziel. Trage jetzt dazu bei und hole dir noch Assets. Zum Beispiel beim Formel 1-Rennen in Spielberg oder erfülle Challenges. Die Community zählt auf dich. Viel Glück!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
              Stack(alignment: Alignment.center, children: [
                Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Image.asset('assets/images/silvertab.png',
                        width: 120, height: 40, fit: BoxFit.fill)),
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
            child: LinearPercentIndicator(
              animation: true,
              animationDuration: 2000,
              lineHeight: 14.0,
              percent: 0.5,
              backgroundColor: Colors.grey,
              barRadius: const Radius.circular(90),
              progressColor: Colors.purple,
            ),
          ),
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
      child: Container(
        padding: const EdgeInsets.all(15.0),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kloppocar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/car.jpg'),
            ),
          ],
        ),
      ),
    );
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
                    fontSize: 10,
                    color: Colors.white,
                    fontFamily: 'ChakraPetch',
                  )),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  postdate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ))
          ]),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ))),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/car1.jpeg'),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('USERNAME',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            Text('DEINS-Tester',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
          ],
        ),
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
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Stack(alignment: Alignment.center, children: [
                Divider(height: 20, thickness: 1, color: Colors.grey),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/car.jpg'),
                ),
              ]),
              objectViewer(),
              turLWidget(),
              communityChallengeWidget(_formatTime(_remainingTime)),
              sectionHeader('CHALLENGES'),
              challengeBox(),
              challengeBox(),
              sectionHeader('Nachrichten'),
              newsItem(
                _newsItems[0]["category"],
                _newsItems[0]["post-date"],
                _newsItems[0]["content"],
              ),
              newsItem(
                _newsItems[1]["category"],
                _newsItems[1]["post-date"],
                _newsItems[1]["content"],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Section Header Widget
Widget sectionHeader(String header) {
  return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Stack(alignment: Alignment.center, children: [
        const Divider(height: 20, thickness: 1, color: Colors.grey),
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
    padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Text(
              'Community-Challenge',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/car.jpg"),
                ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LinearPercentIndicator(
              animation: true,
              animationDuration: 2000,
              lineHeight: 10.0,
              percent: 0.3,
              backgroundColor: Colors.grey,
              barRadius: const Radius.circular(90),
              progressColor: Colors.purple,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kloppocar-Puzzle-Collection',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                Text('4/7', style: TextStyle(fontSize: 12, color: Colors.black))
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
