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
  final int? maxLine;
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
    this.maxLine,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //var readOnly = readOnlyBool(title);
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
                  readOnly: suffixIcon == null ? false : true,
                  autofocus: false,
                  obscureText: isHidePw ?? false,
                  keyboardType: type,
                  maxLines: isHidePw == null ? maxLine : 1,
                  cursorColor: Colors.grey,
                  style: editSubTitleStyle,
                  validator: validator,
                  onChanged: onChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      contentPadding: maxLine == null
                          ? EdgeInsets.only(left: 14)
                          : EdgeInsets.all(14),
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

  bool readOnlyBool(String title) {
    if (title == "Start Date")
      return true;
    else if (title == "End Date")
      return true;
    else if (title == "Birth")
      return true;
    else if (title == "Project Member")
      return true;
    else if (title == "Project Tag")
      return true;
    else if (title == "Select Category")
      return true;
    else if (title == "Select Tag")
      return true;
    else
      return false;
  }
}
