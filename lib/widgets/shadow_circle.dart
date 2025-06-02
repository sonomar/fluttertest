import 'package:flutter/material.dart';

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
