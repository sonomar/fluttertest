import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Missions extends StatefulWidget {
  const Missions({super.key, this.userData});
  final dynamic userData;

  @override
  State<Missions> createState() => _MissionsState();
}

class _MissionsState extends State<Missions> {
  @override
  Widget build(BuildContext context) {
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

    Widget missionWidget() {
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
                      'Tür L',
                      style: TextStyle(
                        fontSize: 20,
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
            Container(alignment: Alignment.center, child: progressBar(0.33)),
            const Padding(
              padding: EdgeInsets.only(left: 15, top: 5, right: 20, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('2/6',
                      style: TextStyle(fontSize: 12, color: Colors.black))
                ],
              ),
            ),
          ]));
    }

    return Text('test');
  }
}
