import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';

baseAppBar(
    {required String title,
    required BuildContext context,
    required VoidCallback? onPressed,
    bool close = false,
    bool centerTitle = true,
    Widget? action,
    VoidCallback? titleSelect}) {
  return AppBar(
    toolbarHeight: 60,
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: centerTitle,
    title: GestureDetector(
      onTap: () {
        if (titleSelect != null) {
          titleSelect();
        }
      },
      child: customText(title,
          style: TextStyle(
              color: AppColors.gray900,
              fontWeight: weightSet(textWeight: TextWeight.BOLD),
              fontSize: fontSizeSet(textSize: TextSize.T15)),
          overflow: TextOverflow.ellipsis),
    ),
    actions: [
      action == null
          ? close
              ? Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: onPressed,
                    child: Image.asset(
                      AppImages.iX,
                      width: 24,
                      height: 24,
                    ),
                  ),
                )
              : Container()
          : Container(),
      action != null ? action : Container()
    ],
    leading: close
        ? Container()
        : Row(
            children: [
              spaceW(20),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onPressed,
                  icon: Image.asset(
                    AppImages.iChevronPrev,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
  );
}
