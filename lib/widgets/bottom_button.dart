import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:flutter/material.dart';

bottomButton(
    {required BuildContext context,
    String? text,
    double? elevation = 0,
    VoidCallback? onPress}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 48,
    child: ElevatedButton(
        onPressed: onPress ?? null,
        style: ElevatedButton.styleFrom(
            primary: AppColors.primary,
            padding: EdgeInsets.zero,
            elevation: elevation,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Center(
          child: customText(
            text!,
            style: TextStyle(
                fontSize: fontSizeSet(textSize: TextSize.T14),
                color: AppColors.white,
                fontWeight: weightSet(textWeight: TextWeight.BOLD)),
          ),
        )),
  );
}
