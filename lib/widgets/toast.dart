import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(
    {required BuildContext context,
    required String text,
    ToastGravity? toastGravity}) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    decoration: BoxDecoration(
        color: toastGravity == null
            ? AppColors.gray900.withOpacity(0.6)
            : AppColors.greenGray400.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12)),
    padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: customText(text,
            style: TextStyle(
                color: AppColors.white,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14)),),
        ),
      ],
    ),
  );

  fToast.showToast(
      child: toast,
      gravity: toastGravity ?? ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 12,
                right: 12,
                top: toastGravity == null
                    ? null
                    : MediaQuery.of(context).padding.top + 150,
                child: Center(child: child),
                bottom: toastGravity == null
                    ? 78 + MediaQuery.of(context).padding.bottom
                    : null,
              ),
            ],
          ),
        );
      });
}
