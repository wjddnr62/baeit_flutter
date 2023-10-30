import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/permission/permission_check_bloc.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCheckPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return PermissionCheckState();
  }
}

class PermissionCheckState
    extends BlocState<PermissionCheckBloc, PermissionCheckPage> {
  bool gpsCheck = false;
  bool gpsDenied = false;
  bool gpsSkip = false;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: SafeArea(
              child: Stack(
                children: [
                  Scaffold(
                    appBar: baseAppBar(
                        title: AppStrings.of(StringKey.permissionAnnouncement),
                        context: context,
                        onPressed: () {},
                        close: true,
                        action: Container()),
                    body: SingleChildScrollView(
                      child: Container(
                        color: AppColors.white,
                        height: MediaQuery.of(context).size.height -
                            (120 +
                                MediaQuery.of(context).padding.top +
                                MediaQuery.of(context).padding.bottom),
                        child: ListView(
                          children: [
                            spaceH(MediaQuery.of(context).size.height * 0.13),
                            Container(
                              height: 180,
                              padding: EdgeInsets.only(left: 60, right: 60),
                              child: Image.asset(
                                AppImages.imgApproach,
                                width: 240,
                                height: 180,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 60, right: 60),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppColors.gray50,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        customText(
                                          AppStrings.of(StringKey.location),
                                          style: TextStyle(
                                              color: AppColors.primaryDark10,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14)),
                                        ),
                                        spaceW(2),
                                        customText(
                                          AppStrings.of(StringKey.required),
                                          style: TextStyle(
                                              color: AppColors.primaryLight10,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T10)),
                                        )
                                      ],
                                    ),
                                    spaceH(4),
                                    customText(
                                      AppStrings.of(
                                          StringKey.locationPermission),
                                      style: TextStyle(
                                          color: AppColors.gray500,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.REGULAR),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12)),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        spaceH(20),
                                        Row(
                                          children: [
                                            customText(
                                              AppStrings.of(StringKey.album),
                                              style: TextStyle(
                                                  color: AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T14)),
                                            ),
                                            spaceW(2),
                                            customText(
                                              AppStrings.of(StringKey.select),
                                              style: TextStyle(
                                                  color: AppColors.gray400,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            )
                                          ],
                                        ),
                                        spaceH(4),
                                        customText(
                                          AppStrings.of(
                                              StringKey.albumPermission),
                                          style: TextStyle(
                                              color: AppColors.gray500,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.REGULAR),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12)),
                                        ),
                                      ],
                                    ),
                                    Platform.isIOS
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              spaceH(20),
                                              Row(
                                                children: [
                                                  customText(
                                                    AppStrings.of(
                                                        StringKey.notification),
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray900,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .BOLD),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T14)),
                                                  ),
                                                  spaceW(2),
                                                  customText(
                                                    AppStrings.of(
                                                        StringKey.select),
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.gray400,
                                                        fontWeight: weightSet(
                                                            textWeight:
                                                                TextWeight
                                                                    .MEDIUM),
                                                        fontSize: fontSizeSet(
                                                            textSize:
                                                                TextSize.T10)),
                                                  )
                                                ],
                                              ),
                                              spaceH(4),
                                              customText(
                                                AppStrings.of(StringKey
                                                    .notificationPermission),
                                                style: TextStyle(
                                                    color: AppColors.gray500,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.REGULAR),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T12)),
                                              )
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            spaceH(MediaQuery.of(context).size.height * 0.13),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                      child: bottomButton(
                          context: context,
                          text: AppStrings.of(StringKey.check),
                          onPress: () async {
                            gpsDenied = false;
                            await prefs!.setBool("permission", true);
                            amplitudeEvent('check_permission', {});
                            permissionCheck();
                          }),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  gpsEnableRequest() {
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12),
      child: ListView(
        shrinkWrap: true,
        children: [
          spaceH(40),
          customText('위치 권한 허용을 위해\n위치 서비스를 켜주세요',
              style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                  fontSize: fontSizeSet(textSize: TextSize.T13),), textAlign: TextAlign.center),
          spaceH(40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      gpsSkip = true;
                      popDialog(context);
                      permissionCheck();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                width: 1, color: AppColors.primary))),
                    child: customText('취소',
                        style: TextStyle(
                            color: AppColors.primaryDark10,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))),
              ),
              spaceW(12),
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      popDialog(context);
                      await Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    child: customText('설정',
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))),
              )
            ],
          ),
          spaceH(12)
        ],
      ),
    );
  }

  permissionCheck() async {
    final bool? result;
    if (Platform.isIOS) {
      await AppTrackingTransparency.requestTrackingAuthorization();

      result = await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      await prefs!.setBool("iosNotification", result ?? false);

      PushConfig().initializeLocalNotification();
    }

    if (!gpsDenied || gpsSkip) {
      if (!gpsSkip) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          gpsCheck = true;
          // 토스트로 해당 권한을 받기 위해 gps 를 켜달라고 해야함.
          return customDialog(
              context: context, barrier: true, widget: gpsEnableRequest());
        }
      }

      if (Platform.isAndroid) {
        var result = await [Permission.location, Permission.storage].request();

        if ((result[Permission.location] == PermissionStatus.granted ||
                result[Permission.location] == PermissionStatus.denied ||
                result[Permission.location] == PermissionStatus.limited ||
                result[Permission.location] ==
                    PermissionStatus.permanentlyDenied) &&
            (result[Permission.storage] == PermissionStatus.granted ||
                result[Permission.storage] == PermissionStatus.denied ||
                result[Permission.storage] == PermissionStatus.limited ||
                result[Permission.storage] ==
                    PermissionStatus.permanentlyDenied)) {
          amplitudeEvent('finish_permission', {});
          pushAndRemoveUntil(context, SignupPage());
        }
      } else {
        Map<Permission, PermissionStatus> check = {};
        await [Permission.photos].request().then((value) {
          check.addAll(value);
        });
        await [Permission.location].request().then((value) {
          check.addAll(value);
        });

        if ((check[Permission.location] == PermissionStatus.granted ||
                    check[Permission.location] == PermissionStatus.denied ||
                    check[Permission.location] == PermissionStatus.limited ||
                    check[Permission.location] ==
                        PermissionStatus.permanentlyDenied) &&
                (check[Permission.photos] == PermissionStatus.granted ||
                    check[Permission.photos] == PermissionStatus.denied) ||
            check[Permission.photos] == PermissionStatus.limited ||
            check[Permission.photos] == PermissionStatus.permanentlyDenied) {
          amplitudeEvent('finish_permission', {});
          pushAndRemoveUntil(context, SignupPage());
        }
      }
    }
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  PermissionCheckBloc initBloc() {
    // TODO: implement initBloc
    return PermissionCheckBloc(context)..add(PermissionCheckInitEvent());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString() && gpsCheck) {
        gpsCheck = false;
        gpsDenied = !await Geolocator.isLocationServiceEnabled();
        permissionCheck();
      }
      return;
    });
  }
}
