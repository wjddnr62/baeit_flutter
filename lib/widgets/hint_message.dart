import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/widgets.dart';

hintMessage({required String text}) {
  return Container(
    width: double.infinity,
    height: 32,
    padding: EdgeInsets.only(left: 10, right: 10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.secondaryLight40),
    child: Row(
      children: [
        Image.asset(
          AppImages.iHintCs,
          width: 12,
          height: 12,
        ),
        spaceW(4),
        customText(
          text,
          style: TextStyle(
              color: AppColors.secondaryDark30,
              fontWeight: weightSet(
                textWeight: TextWeight.MEDIUM,
              ),
              fontSize: fontSizeSet(textSize: TextSize.T10)),
        )
      ],
    ),
  );
}
