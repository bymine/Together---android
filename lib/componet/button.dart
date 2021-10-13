import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final double? width;
  final double? height;

  const MyButton(
      {Key? key,
      required this.label,
      this.width,
      this.height,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: width == null && height == null
            ? EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: titleColor,
        ),
        child: Center(
            child: Text(
          label,
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
