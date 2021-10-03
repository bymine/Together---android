import 'package:flutter/material.dart';
import 'package:together_android/constant.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final Widget? titleButton;
  final String hint;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? isHidePw;
  final Widget? auth;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  const MyInputField({
    Key? key,
    this.validator,
    required this.title,
    required this.hint,
    this.onChanged,
    this.isHidePw,
    this.controller,
    this.titleButton,
    this.prefixIcon,
    this.suffixIcon,
    this.type,
    this.auth,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: editTitleStyle,
              ),
              titleButton ?? Container()
            ],
          ),
          titleButton == null
              ? SizedBox(
                  height: 10,
                )
              : Container(),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  readOnly: title != "Birth" ? false : true,
                  autofocus: false,
                  obscureText: isHidePw ?? false,
                  keyboardType: type,
                  cursorColor: Colors.grey,
                  style: editSubTitleStyle,
                  validator: validator,
                  onChanged: onChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 14),
                      hintText: hint,
                      hintStyle: editSubTitleStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1)),
                      suffixIcon: suffixIcon,
                      prefixIcon: prefixIcon),
                ),
              ),
            ],
          ),
          auth ?? Container()
        ],
      ),
    );
  }
}
