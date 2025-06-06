import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget newsItem(type, postedDate, header, body, {imageRef}) {
  return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Text(type,
              style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2.56,
                  color: Colors.white,
                  fontFamily: 'ChakraPetch',
                  fontWeight: FontWeight.w700)),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              header,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                fontSize: 20,
                letterSpacing: 1,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              )),
            )),
        const Divider(height: 20, thickness: 1, color: Color(0x80999999)),
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              body,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                fontSize: 14,
                letterSpacing: 1,
                color: Colors.black,
                fontWeight: FontWeight.w300,
              )),
            )),
      ]));
}
