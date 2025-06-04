import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          Padding(
              padding: EdgeInsets.only(left: 30, bottom: 10),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/paint.jpg'),
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 350,
                    child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Text(
                          'Community-Ziel läuft bald ab!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: 'ChakraPetch',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ))),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffd622ca),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 40),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'ChakraPetch',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]),
          const SizedBox(height: 10),
          Padding(
              padding: EdgeInsets.only(left: 30, right: 155),
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
