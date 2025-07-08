import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/localization_helper.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0.0,
            title: Text(translate("community_header", context)),
            backgroundColor: Color(0xff333333),
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontFamily: 'ChakraPetch',
              fontWeight: FontWeight.w500,
            )),
        body: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xffd622ca),
                  Color(0xff333333),
                ],
                center: Alignment.center,
                radius: 0.4,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
            child: SizedBox.shrink()));
  }
}
