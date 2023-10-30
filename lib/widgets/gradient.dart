import 'package:baeit/resource/app_colors.dart';
import 'package:flutter/widgets.dart';

bottomGradient(
    {required BuildContext context,
    required double height,
    required Color color}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: height,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [color.withOpacity(0), color],
            stops: [0.0, 1.0])),
  );
}

topGradient(
    {required BuildContext context,
    required double height,
    Color? downColor,
    Color? upColor,
    BorderRadius? borderRadius}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: height,
    decoration: BoxDecoration(
        borderRadius: borderRadius != null ? borderRadius : null,
        gradient: LinearGradient(
            begin: FractionalOffset.bottomCenter,
            end: FractionalOffset.topCenter,
            colors: (downColor == null && upColor == null)
                ? [
                    AppColors.black.withOpacity(0),
                    AppColors.black.withOpacity(0.12)
                  ]
                : [
                    AppColors.black.withOpacity(0),
                    AppColors.black.withOpacity(0.3)
                  ],
            stops: [0.0, 1.0])),
  );
}
