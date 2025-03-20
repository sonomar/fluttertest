import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:async';
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
  int unreadNotifications = 2; // Hardcoded for now

  @override
  void initState() {
    super.initState();
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
              'Tür L',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/selten.jpg'),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: CircleAvatar(backgroundColor: Colors.white, child: Text('LM')),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('USERNAME',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            Text('USERNAME',
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
              objectViewer(),
              Text(widget.qrcode,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('[card_title]',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text('[card_type_svg]',
                          style: TextStyle(fontSize: 12, color: Colors.black))
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
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
              turLWidget(),
              kloppocarWidget(),
              communityChallengeWidget(_formatTime(_remainingTime)),
              sectionHeader('CHALLENGES'),
              challengeBox(),
              challengeBox(),
              sectionHeader('Nachrichten'),
              const Text('list of news items here'),
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
      padding: const EdgeInsets.all(10.0),
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
