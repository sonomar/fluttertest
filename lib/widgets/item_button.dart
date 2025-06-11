import 'package:flutter/material.dart';

class ItemButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final bool active;
  const ItemButton(
      {super.key,
      required this.onTap,
      required this.title,
      required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 50,
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                splashColor: Colors.white10, // Splash color over image
                child: Ink(
                    decoration: BoxDecoration(
                      color: active == true
                          ? Color.fromARGB(202, 214, 34, 202)
                          : Color(0x80999999),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: active == true
                              ? Colors.black
                              : Color.fromARGB(158, 22, 21, 21),
                          fontFamily: 'ChakraPetch',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))),
          )),
    );
  }
}
