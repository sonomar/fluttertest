import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../helpers/localization_helper.dart';

Widget communityProgressBar(pageContext, int communityGoal, progress) {
  double progressPercent = 0.0;
  if (communityGoal > 0) {
    progressPercent = progress / communityGoal;
  }
  return Container(
      width: MediaQuery.of(pageContext).size.width - 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(90),
      ),
      child: Padding(
          padding:
              const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 0, right: 0),
          child: Stack(alignment: Alignment.centerRight, children: [
            LinearPercentIndicator(
              animation: true,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              animationDuration: 2000,
              lineHeight: 40.0,
              percent: progressPercent,
              backgroundColor: Colors.white,
              barRadius: const Radius.circular(90),
              progressColor: Color(0xffd622ca),
            ),
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(360),
                        border: Border.all(color: Colors.black)),
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SvgPicture.asset('assets/images/trophy.svg')))),
          ])));
}

Widget communityChallengeWidget(
    String time, pageContext, communityChallenge, progress, context) {
  final int communityGoal =
      (communityChallenge != null && communityChallenge['goal'] != null)
          ? communityChallenge['goal']
          : 0;
  final String ChallengeTitle =
      (communityChallenge != null && communityChallenge['title'] != null)
          ? communityChallenge['title']
          : '';
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
            child: Image.asset('assets/images/kloppofront2.png',
                fit: BoxFit.cover),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 30, bottom: 10),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          AssetImage('assets/images/kloppocarIcon.png'),
                    )),
                // Container(
                //   decoration: BoxDecoration(
                //     color: Color(0xffd622ca),
                //     borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(8),
                //         bottomLeft: Radius.circular(8)),
                //   ),
                //   padding: const EdgeInsets.only(left: 12, right: 40),
                //   child: Text(
                //     time,
                //     style: const TextStyle(
                //       fontSize: 20,
                //       color: Colors.white,
                //       fontFamily: 'ChakraPetch',
                //       fontWeight: FontWeight.w500,
                //       fontStyle: FontStyle.italic,
                //     ),
                //   ),
                // ),
              ]),
          SizedBox(
              child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    translate("banner_welcome_header", context),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ))),
          const SizedBox(height: 10),
          Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: Text(
                translate("banner_welcome_body", context),
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                )),
              )),
          const SizedBox(height: 15),
          // Container(
          //     alignment: Alignment.center,
          //     child:
          //         communityProgressBar(pageContext, communityGoal, progress)),
          // Padding(
          //   padding: EdgeInsets.only(left: 35, top: 5, right: 35, bottom: 40),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         ChallengeTitle,
          //         style: GoogleFonts.roboto(
          //             textStyle: TextStyle(
          //           fontSize: 12,
          //           color: Color.fromARGB(255, 181, 181, 181),
          //           fontWeight: FontWeight.w300,
          //         )),
          //       ),
          //       Text(
          //         '$progress / $communityGoal',
          //         style: GoogleFonts.roboto(
          //             textStyle: TextStyle(
          //           fontSize: 12,
          //           color: Color.fromARGB(255, 181, 181, 181),
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
