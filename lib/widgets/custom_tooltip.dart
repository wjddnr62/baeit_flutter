import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTooltip extends StatelessWidget {
  final String message;

  CustomTooltip({required this.message});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      verticalOffset: 18,
      preferBelow: true,
      textStyle: TextStyle(
          color: AppColors.gray600,
          fontSize: 12,
          letterSpacing: -0.5,
          fontWeight: weightSet(textWeight: TextWeight.MEDIUM)),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: AppColors.accentDark10,
                blurRadius: 4,
                offset: Offset(0, 0))
          ],
          borderRadius: BorderRadius.circular(5.3)),
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: Container(
          width: 45,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.accentLight60),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customText(
                  'TIP',
                  style: TextStyle(
                      color: AppColors.accentDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T10)),
                ),
                spaceW(4),
                Image.asset(
                  AppImages.iTipQuestion,
                  width: 12,
                  height: 12,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    amplitudeEvent('tooltip', {'type': message});
    tooltip?.ensureTooltipVisible();
  }
}
