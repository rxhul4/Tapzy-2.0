import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  String? labelText;
  double? allBorderRadius;
  double? labelFontSize;
  double? hintFontSize;
  double? inputTextFontSize;
  int? maxLength;
  Color? labelTextColor;
  Color? hintTextColor;
  Color? focusedBorderColor;
  Color? enabledBorderColor;
  Color? cursorColor;
  Color? inputTextColor;
  TextInputType? textInputType;
  String? fontFamily;
  String? labelFontFamily;
  String? hintFontFamily;
  TextEditingController? controller;
  Function(String)? onChanged;
  String? hintText;
  double? letterSpacing;

  CommonTextField(
      {Key? key,
      this.labelText,
      this.allBorderRadius,
      this.focusedBorderColor,
      this.enabledBorderColor,
      this.inputTextFontSize,
      this.labelFontFamily,
      this.textInputType,
      this.controller,
      this.hintText,
      this.cursorColor,
      this.inputTextColor,
      this.maxLength,
      this.fontFamily,
      this.onChanged,
      this.hintFontFamily,
      this.hintFontSize,
      this.letterSpacing,
      this.hintTextColor,
      this.labelFontSize,
      this.labelTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextField(
      maxLength: maxLength,
      onChanged: onChanged,
      controller: controller,
      style: TextStyle(
        letterSpacing: letterSpacing,
        color: inputTextColor ?? Colors.white,
          fontSize: inputTextFontSize ?? 16,
        fontFamily:fontFamily,
      ),
      keyboardType: textInputType ?? TextInputType.phone,
      cursorColor:  cursorColor ?? Color(0xFFC352A2),
      decoration: InputDecoration(
        counterText: "",
        contentPadding: EdgeInsets.only(left: 10,right: 10),
        alignLabelWithHint: true,
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: hintTextColor ?? Colors.white.withOpacity(0.5), fontSize: hintFontSize ?? 14,fontFamily: hintFontFamily),
        labelStyle: TextStyle(color: labelTextColor ?? Colors.white, fontSize: labelFontSize ?? 14,fontFamily: labelFontFamily),
        filled: true,
        fillColor: Colors.transparent,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(allBorderRadius ?? 12)),
          borderSide: BorderSide(width: 1.5, color: focusedBorderColor ?? Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(allBorderRadius  ?? 12)),
          borderSide: BorderSide(width: 01, color: enabledBorderColor ?? Colors.white),
        ),
      ),
    );
  }
}
