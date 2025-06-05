// lib/widgets/shadow_circle.dart
import 'package:flutter/material.dart';

// Explicitly type radius as double
Widget shadowCircle(String imageLink, double radius, bool isWeb) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
            blurRadius: 5.0, // MODIFIED: Use double
            color: Colors.black,
            spreadRadius: 0.0 // MODIFIED: Use double
            )
      ],
    ),
    child: isWeb
        ? CircleAvatar(
            radius: radius, // Receives double
            backgroundImage: NetworkImage(imageLink),
            onBackgroundImageError:
                imageLink.startsWith('http') || imageLink.startsWith('https')
                    ? (exception, stackTrace) {
                        print(
                            'Error loading network image in shadowCircle: $imageLink, $exception');
                      }
                    : null,
          )
        : CircleAvatar(
            radius: radius, // Receives double
            backgroundImage: AssetImage(imageLink),
            onBackgroundImageError:
                !(imageLink.startsWith('http') || imageLink.startsWith('https'))
                    ? (exception, stackTrace) {
                        print(
                            'Error loading asset image in shadowCircle: $imageLink, $exception');
                      }
                    : null,
          ),
  );
}
