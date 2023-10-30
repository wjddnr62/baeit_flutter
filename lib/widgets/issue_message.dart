import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/widgets.dart';

issueMessage({required String title}) {
  return Column(
    children: [
      spaceH(4),
      Container(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppImages.iWarningCe,
              width: 12,
              height: 12,
            ),
            spaceW(4),
            customText(
              title,
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T10)),
            )
          ],
        ),
      ),
    ],
  );
}
