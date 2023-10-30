import 'dart:convert';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/main/main_page.dart';
import 'package:baeit/ui/profile/profile_bloc.dart';
import 'package:baeit/ui/set_goal/set_goal_page.dart';
import 'package:baeit/ui/signup/signup_page.dart';
import 'package:baeit/ui/webview/webview_page.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends BlocStatefulWidget {
  final bool? signUp;
  final String? accessId;
  final String? email;
  final AppleInfo? appleInfo;
  final KakaoInfo? kakaoInfo;
  final Device? device;
  final Data? image;
  final String? type;
  final ProfileGet? profile;

  ProfilePage(
      {this.signUp = false,
      this.accessId,
      this.email,
      this.appleInfo,
      this.kakaoInfo,
      this.device,
      this.image,
      this.type,
      this.profile});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ProfileState();
  }
}

class ProfileState extends BlocState<ProfileBloc, ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController introduceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode birthDateFocus = FocusNode();

  String gender = 'FEMALE';
  String? birthDate;

  ScrollController scrollController = ScrollController();

  bool moveIssue = false;

  ImagePicker imagePicker = ImagePicker();

  bool imagePass = true;
  bool namePass = true;
  bool emailPass = true;
  bool emailRegPass = true;
  bool phonePass = true;
  bool phoneLengthPass = true;
  bool birthDatePass = true;

  bool agePass = true;
  bool ageCheck = false;

  RegExp emailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  int initGender = 0;
  String initName = '';
  String initEmail = '';
  String initIntroduce = '';
  String initBirthDate = '';
  String initPhone = '';

  imageView() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 110,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: GestureDetector(
                            onTap: () async {
                              await imagePicker
                                  .pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 20)
                                  .then((value) async {
                                if (value != null) {
                                  bloc.imageFile = value;
                                  await ImageCropper.cropImage(
                                      sourcePath: value.path,
                                      aspectRatio: CropAspectRatio(
                                          ratioX: 80, ratioY: 80),
                                      cropStyle: CropStyle.circle,
                                      maxWidth: 80,
                                      androidUiSettings: AndroidUiSettings(
                                        toolbarTitle: '이미지 자르기',
                                        toolbarColor: AppColors.primary,
                                        toolbarWidgetColor: AppColors.white,
                                        activeControlsWidgetColor:
                                            AppColors.primary,
                                        initAspectRatio:
                                            CropAspectRatioPreset.ratio3x2,
                                        hideBottomControls: true,
                                        lockAspectRatio: true,
                                      ),
                                      iosUiSettings: IOSUiSettings(
                                        minimumAspectRatio: 1.0,
                                        aspectRatioLockEnabled: true,
                                        aspectRatioPickerButtonHidden: true,
                                        rotateButtonsHidden: true,
                                        resetButtonHidden: true,
                                        rectHeight: 80,
                                      )).then((value) {
                                    if (value != null) {
                                      bloc.cropImageFile = value;
                                      bloc.imageDefault = false;
                                      bloc.imageChange = true;
                                    } else {
                                      bloc.imageFile = null;
                                    }
                                  });
                                }
                              });
                              systemColorSetting();
                              bloc.add(GetFileEvent());
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              child: bloc.signUp
                                  ? bloc.imageDefault == true
                                      ? Image.asset(AppImages.dfProfile)
                                      : bloc.cropImageFile == null
                                          ? widget.image == null
                                              ? Image.asset(AppImages.dfProfile)
                                              : Container(
                                width: 80,
                                                height: 80,
                                                child: CacheImage(
                                                    width: MediaQuery.of(context).size.width,
                                                    imageUrl:
                                                        '${widget.image!.toView(context: context, w: MediaQuery.of(context).size.width ~/ 2)}',
                                                    fit: BoxFit.cover,
                                                  ),
                                              )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              child: Image.file(
                                                File(bloc.cropImageFile!.path),
                                                fit: BoxFit.contain,
                                              ))
                                  : bloc.imageDefault == true
                                      ? Image.asset(AppImages.dfProfile)
                                      : bloc.cropImageFile == null
                                          ? bloc.profileGet != null &&
                                                  bloc.profileGet!.profile !=
                                                      null
                                              ? Container(
                                width: 80,
                                                height: 80,
                                                child: CacheImage(
                                                    width: MediaQuery.of(context).size.width,
                                                    imageUrl:
                                                        bloc.profileGet!.profile!,
                                                    fit: BoxFit.cover,
                                                  ),
                                              )
                                              : Image.asset(AppImages.dfProfile)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              child: Image.file(
                                                File(bloc.cropImageFile!.path),
                                                fit: BoxFit.cover,
                                              )),
                            ),
                          ),
                        ),
                      ),
                      bloc.imageDefault
                          ? Container()
                          : Positioned(
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                child: ElevatedButton(
                                  onPressed: () {
                                    bloc.cropImageFile = null;
                                    bloc.imageDefault = true;
                                    bloc.imageChange = true;
                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      primary: AppColors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                              color: AppColors.transparent))),
                                  child: Image.asset(
                                    AppImages.iInputClear,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              spaceH(10),
              Container(
                width: 62,
                height: 32,
                child: ElevatedButton(
                  onPressed: () async {
                    if (Platform.isAndroid
                        ? await Permission.storage.isGranted
                        : await Permission.photos.isGranted ||
                            await Permission.photos.isLimited) {
                      await imagePicker
                          .pickImage(
                              source: ImageSource.gallery, imageQuality: 20)
                          .then((value) async {
                        if (value != null) {
                          bloc.imageFile = value;
                          await ImageCropper.cropImage(
                              sourcePath: value.path,
                              aspectRatio:
                                  CropAspectRatio(ratioX: 80, ratioY: 80),
                              cropStyle: CropStyle.circle,
                              maxWidth: 80,
                              androidUiSettings: AndroidUiSettings(
                                toolbarTitle: '이미지 자르기',
                                toolbarColor: AppColors.primary,
                                toolbarWidgetColor: AppColors.white,
                                activeControlsWidgetColor: AppColors.primary,
                                initAspectRatio: CropAspectRatioPreset.ratio3x2,
                                hideBottomControls: true,
                                lockAspectRatio: true,
                              ),
                              iosUiSettings: IOSUiSettings(
                                minimumAspectRatio: 1.0,
                                aspectRatioLockEnabled: true,
                                aspectRatioPickerButtonHidden: true,
                                rotateButtonsHidden: true,
                                resetButtonHidden: true,
                                rectHeight: 80,
                              )).then((value) {
                            if (value != null) {
                              bloc.cropImageFile = value;
                              bloc.imageDefault = false;
                              bloc.imageChange = true;
                            } else {
                              bloc.imageFile = null;
                            }
                          });
                        }
                      });
                      systemColorSetting();
                      bloc.add(GetFileEvent());
                    } else if (Platform.isAndroid
                        ? await Permission.storage.isDenied ||
                            await Permission.storage.isPermanentlyDenied
                        : await Permission.photos.isDenied ||
                            await Permission.photos.isPermanentlyDenied) {
                      decisionDialog(
                          context: context,
                          barrier: false,
                          text: Platform.isAndroid
                              ? AppStrings.of(StringKey.storageCheckText)
                              : AppStrings.of(StringKey.photoCheckText),
                          allowText: AppStrings.of(StringKey.check),
                          disallowText: AppStrings.of(StringKey.cancel),
                          allowCallback: () async {
                            popDialog(context);
                            await openAppSettings();
                          },
                          disallowCallback: () {
                            popDialog(context);
                          });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.accentLight20,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.iCameraW,
                        width: 16,
                        height: 16,
                      ),
                      spaceW(4),
                      customText(
                        AppStrings.of(StringKey.album),
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        imagePass == false
            ? issueMessage(title: AppStrings.of(StringKey.profileImageIssue))
            : Container()
      ],
    );
  }

  nameView() {
    return Column(
      children: [
        Row(
          children: [
            customText(
              AppStrings.of(StringKey.name),
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            ),
            Expanded(child: Container()),
            customText(
              nameController.text.characters.length.toString(),
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            ),
            customText(
              ' / 1 ~ 8',
              style: TextStyle(
                  color: AppColors.gray400,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            )
          ],
        ),
        spaceH(14),
        Container(
          height: 48,
          child: TextFormField(
              onChanged: (text) {
                namePass = true;
                blankCheck(text: text, controller: nameController);
                setState(() {});
              },
              maxLength: 8,
              maxLines: 1,
              controller: nameController,
              focusNode: nameFocus,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(emailFocus);
              },
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              decoration: InputDecoration(
                hintText: AppStrings.of(StringKey.namePlaceHolder),
                hintStyle: TextStyle(
                    color: AppColors.primaryDark10.withOpacity(0.4),
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                suffixIcon: nameController.text.length > 0
                    ? Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 14),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              nameController.text = '';
                            });
                          },
                          child: Image.asset(AppImages.iInputClear,
                              width: 20, height: 20),
                        ),
                      )
                    : null,
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                fillColor: AppColors.primaryLight60,
                filled: true,
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 1, color: AppColors.gray200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 1, color: AppColors.primaryLight40)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 2, color: AppColors.primaryLight30)),
              )),
        ),
        namePass == false
            ? issueMessage(title: AppStrings.of(StringKey.nameIssue))
            : Container()
      ],
    );
  }

  emailView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            AppStrings.of(StringKey.email),
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
          ),
          spaceH(14),
          Container(
            height: 48,
            child: TextFormField(
                onChanged: (text) {
                  emailPass = true;
                  emailRegPass = true;
                  blankCheck(text: text, controller: emailController);
                  setState(() {});
                },
                maxLines: 1,
                controller: emailController,
                focusNode: emailFocus,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(phoneFocus);
                },
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
                decoration: InputDecoration(
                    hintText: 'baeit@example.com',
                    hintStyle: TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                    suffixIcon: emailController.text.length > 0
                        ? Padding(
                            padding: EdgeInsets.only(top: 14, bottom: 14),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  emailController.text = '';
                                });
                              },
                              child: Image.asset(AppImages.iInputClear,
                                  width: 20, height: 20),
                            ),
                          )
                        : null,
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                    fillColor: AppColors.white,
                    filled: true,
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 2, color: AppColors.primary)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)))),
          ),
          emailPass == false
              ? issueMessage(title: AppStrings.of(StringKey.emailIssue))
              : emailRegPass == false
                  ? issueMessage(title: AppStrings.of(StringKey.emailRegIssue))
                  : Container()
        ],
      ),
    );
  }

  introduceView() {
    return Column(
      children: [
        Row(
          children: [
            customText(
              AppStrings.of(StringKey.introduce),
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            ),
            customText(
              ' (${AppStrings.of(StringKey.choice)})',
              style: TextStyle(
                  color: AppColors.gray400,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            ),
            Expanded(child: Container()),
            customText(
              introduceController.text.characters.length.toString(),
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.BOLD),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            ),
            customText(
              ' / 100',
              style: TextStyle(
                  color: AppColors.gray400,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T12)),
            )
          ],
        ),
        spaceH(14),
        Container(
          height: 182,
          child: TextFormField(
              onChanged: (text) {
                blankCheck(
                    text: text,
                    controller: introduceController,
                    multiline: true);
                setState(() {});
              },
              maxLength: 100,
              maxLines: null,
              controller: introduceController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onFieldSubmitted: (value) {},
              expands: true,
              style: TextStyle(
                  color: AppColors.primaryDark10,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                hintText: AppStrings.of(StringKey.introducePlaceHolder),
                hintMaxLines: 3,
                hintStyle: TextStyle(
                    color: AppColors.primaryDark10.withOpacity(0.4),
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                contentPadding:
                    EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 1),
                fillColor: AppColors.primaryLight60,
                filled: true,
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 1, color: AppColors.gray200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 1, color: AppColors.primaryLight40)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(width: 2, color: AppColors.primaryLight30)),
              )),
        ),
      ],
    );
  }

  phoneView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            AppStrings.of(StringKey.phone),
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
          ),
          spaceH(14),
          Container(
            height: 48,
            child: TextFormField(
                onChanged: (text) {
                  phonePass = true;
                  phoneLengthPass = true;
                  setState(() {});
                },
                maxLines: 1,
                maxLength: 11,
                controller: phoneController,
                focusNode: phoneFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) {},
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    hintText: AppStrings.of(StringKey.phonePlaceHolder),
                    hintStyle: TextStyle(
                        color: AppColors.primaryDark10.withOpacity(0.4),
                        fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                    suffixIcon: phoneController.text.length > 0
                        ? Padding(
                            padding: EdgeInsets.only(top: 14, bottom: 14),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  phoneController.text = '';
                                });
                              },
                              child: Image.asset(AppImages.iInputClear,
                                  width: 20, height: 20),
                            ),
                          )
                        : null,
                    contentPadding: EdgeInsets.only(left: 10, right: 10),
                    fillColor: AppColors.white,
                    filled: true,
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 2, color: AppColors.primary)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(width: 1, color: AppColors.gray200)))),
          ),
          phonePass == false || phoneLengthPass == false
              ? issueMessage(title: AppStrings.of(StringKey.phoneIssue))
              : Container()
        ],
      ),
    );
  }

  genderText(int idx, {bool save = false}) {
    switch (idx) {
      case 0:
        return save ? 'FEMALE' : AppStrings.of(StringKey.female);
      case 1:
        return save ? 'MALE' : AppStrings.of(StringKey.male);
      case 2:
        return save ? 'OTHER' : AppStrings.of(StringKey.other);
    }
  }

  genderItem(int idx) {
    return Expanded(
        child: Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          bloc.add(GenderSelectEvent(select: idx));
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            primary:
                bloc.genderSelect == idx ? AppColors.primary : AppColors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: idx == 0
                  ? BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8))
                  : idx == 1
                      ? BorderRadius.zero
                      : BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
            )),
        child: Center(
          child: customText(
            genderText(idx),
            style: TextStyle(
                color: bloc.genderSelect == idx
                    ? AppColors.white
                    : AppColors.gray400,
                fontSize: fontSizeSet(textSize: TextSize.T13),
                fontWeight: weightSet(
                    textWeight: bloc.genderSelect == idx
                        ? TextWeight.BOLD
                        : TextWeight.MEDIUM)),
          ),
        ),
      ),
    ));
  }

  genderView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          AppStrings.of(StringKey.gender),
          style: TextStyle(
              color: AppColors.gray900,
              fontWeight: weightSet(textWeight: TextWeight.BOLD),
              fontSize: fontSizeSet(textSize: TextSize.T14)),
        ),
        spaceH(14),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              genderItem(0),
              widthOneLine(48, color: AppColors.gray200),
              genderItem(1),
              widthOneLine(48, color: AppColors.gray200),
              genderItem(2),
            ],
          ),
        ),
      ],
    );
  }

  birthDayView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            AppStrings.of(StringKey.birthDate),
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
          ),
          spaceH(14),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                DatePicker.showDatePicker(context,
                    minTime: DateTime(1940, 1, 1),
                    maxTime: DateTime.now(), onConfirm: (date) {
                  birthDate = date.yearMonthDay;
                  birthDatePass = true;
                  setState(() {});
                },
                    currentTime: DateTime.now(),
                    theme: DatePickerTheme(
                        titleHeight: 60,
                        doneStyle: TextStyle(
                          color: AppColors.primary,
                        )),
                    locale: LocaleType.ko);
              },
              style: ElevatedButton.styleFrom(
                  primary: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.gray200))),
              child: Row(
                children: [
                  customText(
                    birthDate == null
                        ? AppStrings.of(StringKey.birthDatePlaceHolder)
                        : '$birthDate',
                    style: TextStyle(
                        color: birthDate == null
                            ? AppColors.gray400
                            : AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                    textAlign: TextAlign.start,
                  ),
                  Expanded(child: Container()),
                  Image.asset(
                    AppImages.iSelectACDown,
                    width: 16,
                    height: 16,
                  ),
                  spaceW(10)
                ],
              ),
            ),
          ),
          birthDatePass == false
              ? issueMessage(title: AppStrings.of(StringKey.birthDateIssue))
              : Container()
        ],
      ),
    );
  }

  kakaoView() {
    return Column(
      children: [
        widget.kakaoInfo!.gender == '' ? genderView() : Container(),
        widget.kakaoInfo!.gender == '' ? spaceH(34) : Container(),
        (widget.kakaoInfo!.birthYear == '' || widget.kakaoInfo!.birthDay == '')
            ? birthDayView()
            : Container(),
        widget.kakaoInfo!.gender == '' && widget.kakaoInfo!.birthYear == ''
            ? spaceH(40)
            : spaceH(0)
      ],
    );
  }

  iosView() {
    return Column(
      children: [
        phoneView(),
        spaceH(34),
        genderView(),
        spaceH(34),
        birthDayView()
      ],
    );
  }

  ageRange(int year) {
    int age = (DateTime.now().year - year) + 1;
    String ageRange = '';
    if (age >= 10 && age < 20) {
      ageRange = '10세~19세';
    } else if (age >= 20 && age < 30) {
      ageRange = '20세~29세';
    } else if (age >= 30 && age < 40) {
      ageRange = '30세~39세';
    } else if (age >= 40 && age < 50) {
      ageRange = '40세~49세';
    } else if (age >= 50 && age < 60) {
      ageRange = '50세~59세';
    } else if (age >= 60 && age < 70) {
      ageRange = '60세~69세';
    } else if (age >= 70 && age < 80) {
      ageRange = '70세~79세';
    } else if (age >= 80 && age < 90) {
      ageRange = '80세~89세';
    }
    return ageRange;
  }

  backCheck() {
    bool changeData = false;
    bloc.editProfileEmail = false;
    bloc.editProfileImage = false;
    bloc.editProfileContent = false;
    bloc.editProfileNickName = false;
    bloc.editProfileGender = false;
    bloc.editProfilePhone = false;
    if (widget.signUp!) {
      if (bloc.imageChange) {
        changeData = true;
      }

      if (initName != nameController.text) {
        changeData = true;
      }

      if (initEmail != emailController.text) {
        changeData = true;
      }
      if (widget.type == 'KAKAO') {
        if (widget.kakaoInfo != null &&
            (widget.kakaoInfo!.birthYear == '' ||
                widget.kakaoInfo!.birthDay == '')) {
          if (initBirthDate != birthDate) {
            changeData = true;
          }
        }

        if (widget.kakaoInfo!.gender == "UNKNOWN") {
          if (initGender != bloc.genderSelect) {
            changeData = true;
          }
        }
      } else {
        if (initPhone != phoneController.text) {
          changeData = true;
        }

        if (initGender != bloc.genderSelect) {
          changeData = true;
        }
      }
    } else {
      if (bloc.imageChange) {
        changeData = true;
        bloc.editProfileImage = true;
      }

      if (initName != nameController.text) {
        changeData = true;
        bloc.editProfileNickName = true;
      }

      if (initEmail != emailController.text) {
        changeData = true;
        bloc.editProfileEmail = true;
      }

      if (initIntroduce != introduceController.text) {
        changeData = true;
        bloc.editProfileContent = true;
      }
      if (widget.type == 'APPLE') {
        if (initPhone != phoneController.text) {
          changeData = true;
          bloc.editProfilePhone = true;
        }

        if (initGender != bloc.genderSelect) {
          changeData = true;
          bloc.editProfileGender = true;
        }
      }
    }

    return changeData;
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
              if (backCheck()) {
                decisionDialog(
                    context: context,
                    barrier: false,
                    text: AppStrings.of(StringKey.dataChange),
                    allowText: AppStrings.of(StringKey.check),
                    disallowText: AppStrings.of(StringKey.cancel),
                    allowCallback: () {
                      popDialog(context);
                      if (widget.signUp!) {
                        pushAndRemoveUntil(context, SignupPage());
                      } else {
                        pop(context);
                      }
                    },
                    disallowCallback: () {
                      popDialog(context);
                    });
              } else {
                if (widget.signUp!) {
                  pushAndRemoveUntil(context, SignupPage());
                } else {
                  pop(context);
                }
              }
              return Future.value(false);
            },
            child: Container(
              color: AppColors.white,
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: AppColors.white,
                    appBar: baseAppBar(
                        title: AppStrings.of(widget.signUp!
                            ? StringKey.profileSetting
                            : StringKey.profileEdit),
                        context: context,
                        onPressed: () {
                          if (backCheck()) {
                            decisionDialog(
                                context: context,
                                barrier: false,
                                text: AppStrings.of(StringKey.dataChange),
                                allowText: AppStrings.of(StringKey.check),
                                disallowText: AppStrings.of(StringKey.cancel),
                                allowCallback: () {
                                  popDialog(context);
                                  if (widget.signUp!) {
                                    pushAndRemoveUntil(context, SignupPage());
                                  } else {
                                    pop(context);
                                  }
                                },
                                disallowCallback: () {
                                  popDialog(context);
                                });
                          } else {
                            if (widget.signUp!) {
                              pushAndRemoveUntil(context, SignupPage());
                            } else {
                              pop(context);
                            }
                          }
                        }),
                    body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height -
                            (60 +
                                MediaQuery.of(context).padding.top +
                                MediaQuery.of(context).padding.bottom),
                        child: Stack(
                          children: [
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: bloc.signUp ? 94 : 74,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      bloc.signUp ? Container() : spaceH(20),
                                      bloc.signUp
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 48,
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  top: 16,
                                                  bottom: 16),
                                              color: AppColors.secondaryLight40,
                                              child: customText(
                                                AppStrings.of(StringKey
                                                    .profileSignupText),
                                                style: TextStyle(
                                                    fontSize: fontSizeSet(
                                                        textSize: TextSize.T12),
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    color: AppColors
                                                        .secondaryDark30),
                                              ),
                                            )
                                          : Container(),
                                      bloc.signUp ? spaceH(34) : Container(),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: imageView(),
                                      ),
                                      spaceH(34),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: nameView(),
                                      ),
                                      spaceH(34),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: emailView(),
                                      ),
                                      spaceH(widget.type == 'APPLE' ? 34 : 40),
                                      widget.kakaoInfo != null
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: kakaoView(),
                                            )
                                          : Container(),
                                      widget.type == 'APPLE'
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: iosView(),
                                            )
                                          : Container(),
                                      widget.type == 'APPLE'
                                          ? spaceH(40)
                                          : Container(),
                                      bloc.signUp
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: introduceView(),
                                            ),
                                      bloc.signUp ? Container() : spaceH(20),
                                      bloc.signUp
                                          ? Column(
                                              children: [
                                                customText(
                                                  '\'${AppStrings.of(StringKey.baeitStart)}\' 버튼을 누름으로써',
                                                  style: TextStyle(
                                                      color: AppColors.gray400,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T12)),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        pushTransition(
                                                            context,
                                                            WebviewPage(
                                                              url:
                                                                  'https://terms.baeit.co.kr/59f4716b-01ab-48e1-ba81-43be6bcf8382',
                                                              title: '서비스 이용약관',
                                                            ));
                                                      },
                                                      child: customText(
                                                        '이용약관',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: AppColors
                                                                .primaryDark10,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .MEDIUM),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T12)),
                                                      ),
                                                    ),
                                                    customText(
                                                      ', ',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryDark10,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T12)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        pushTransition(
                                                            context,
                                                            WebviewPage(
                                                              url:
                                                                  'https://terms.baeit.co.kr/617e8c24-1108-4c10-8a06-459ceb46b756',
                                                              title:
                                                                  '개인정보 처리방침',
                                                            ));
                                                      },
                                                      child: customText(
                                                        '개인정보 처리방침',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: AppColors
                                                                .primaryDark10,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .MEDIUM),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T12)),
                                                      ),
                                                    ),
                                                    customText(
                                                      ', ',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .primaryDark10,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T12)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        pushTransition(
                                                            context,
                                                            WebviewPage(
                                                              url:
                                                                  'https://terms.baeit.co.kr/7dcf6715-2544-4cf8-a34f-9ea7e04a5d7b',
                                                              title:
                                                                  '위치기반 서비스 이용약관',
                                                            ));
                                                      },
                                                      child: customText(
                                                        '위치기반 서비스 이용약관',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: AppColors
                                                                .primaryDark10,
                                                            fontWeight: weightSet(
                                                                textWeight:
                                                                    TextWeight
                                                                        .MEDIUM),
                                                            fontSize: fontSizeSet(
                                                                textSize:
                                                                    TextSize
                                                                        .T12)),
                                                      ),
                                                    ),
                                                    customText(
                                                      '에',
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.gray400,
                                                          fontWeight: weightSet(
                                                              textWeight:
                                                                  TextWeight
                                                                      .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T12)),
                                                    )
                                                  ],
                                                ),
                                                customText(
                                                  '동의하는 것으로 간주합니다',
                                                  style: TextStyle(
                                                      color: AppColors.gray400,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T12)),
                                                )
                                              ],
                                            )
                                          : Container(),
                                      agePass
                                          ? Container()
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20),
                                              child: issueMessage(
                                                  title: AppStrings.of(
                                                      StringKey.ageIssue)),
                                            ),
                                      bloc.signUp ? spaceH(40) : Container()
                                    ],
                                  ),
                                )),
                            Positioned(
                                bottom: bloc.signUp ? 94 : 74,
                                child: bottomGradient(
                                    context: context,
                                    height: 20,
                                    color: AppColors.white)),
                            Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Column(
                                  children: [
                                    bloc.signUp
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: Checkbox(
                                                  value: ageCheck,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      4,
                                                    ),
                                                  ),
                                                  side: BorderSide(
                                                      width: 1,
                                                      color: AppColors.gray200),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      ageCheck = value!;
                                                      agePass = true;
                                                    });
                                                  },
                                                  activeColor:
                                                      AppColors.primary,
                                                ),
                                              ),
                                              spaceW(6),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    ageCheck = !ageCheck;
                                                    agePass = true;
                                                  });
                                                },
                                                child: customText(
                                                  AppStrings.of(
                                                      StringKey.ageCheck),
                                                  style: TextStyle(
                                                      color: AppColors.gray900,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T13)),
                                                ),
                                              )
                                            ],
                                          )
                                        : Container(),
                                    spaceH(10),
                                    bottomButton(
                                        context: context,
                                        onPress: () {
                                          moveIssue = false;

                                          if (nameController.text.length == 0) {
                                            namePass = false;
                                            if (!moveIssue) {
                                              moveIssue = true;
                                              FocusScope.of(context)
                                                  .requestFocus(nameFocus);
                                            }
                                          } else if (nameController
                                                  .text.length !=
                                              0) {
                                            namePass = true;
                                          }

                                          if (emailController.text.length ==
                                              0) {
                                            emailPass = false;
                                            if (!moveIssue) {
                                              moveIssue = true;
                                              FocusScope.of(context)
                                                  .requestFocus(emailFocus);
                                            }
                                          } else {
                                            emailPass = true;
                                          }

                                          if (!emailRegExp
                                              .hasMatch(emailController.text)) {
                                            emailRegPass = false;
                                            if (!moveIssue) {
                                              moveIssue = true;
                                              FocusScope.of(context)
                                                  .requestFocus(emailFocus);
                                            }
                                          } else {
                                            emailRegPass = true;
                                          }

                                          if (widget.kakaoInfo != null &&
                                              (widget.kakaoInfo!.birthYear ==
                                                      '' ||
                                                  widget.kakaoInfo!.birthDay ==
                                                      '')) {
                                            if (birthDate == null) {
                                              birthDatePass = false;
                                              if (!moveIssue) {
                                                moveIssue = true;
                                                scrollController.animateTo(
                                                    scrollController.position
                                                        .maxScrollExtent,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut);
                                              }
                                            } else {
                                              birthDatePass = true;
                                            }
                                          }

                                          if (widget.type == 'APPLE') {
                                            if (phoneController.text.length ==
                                                0) {
                                              phonePass = false;
                                              if (!moveIssue) {
                                                moveIssue = true;
                                                FocusScope.of(context)
                                                    .requestFocus(phoneFocus);
                                              }
                                            } else {
                                              phonePass = true;
                                            }

                                            if (phoneController.text.length !=
                                                11) {
                                              phoneLengthPass = false;
                                              if (!moveIssue) {
                                                moveIssue = true;
                                                FocusScope.of(context)
                                                    .requestFocus(phoneFocus);
                                              }
                                            } else {
                                              phoneLengthPass = true;
                                            }

                                            if (birthDate == null) {
                                              birthDatePass = false;
                                              if (!moveIssue) {
                                                moveIssue = true;
                                                scrollController.animateTo(
                                                    scrollController.position
                                                        .maxScrollExtent,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut);
                                              }
                                            } else {
                                              birthDatePass = true;
                                            }
                                          }

                                          if (bloc.signUp) {
                                            if (!ageCheck) {
                                              agePass = false;
                                              if (!moveIssue) {
                                                moveIssue = true;
                                                scrollController.animateTo(
                                                    scrollController.position
                                                        .maxScrollExtent,
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut);
                                              }
                                            } else {
                                              agePass = true;
                                            }

                                            if (namePass &&
                                                emailPass &&
                                                emailRegPass &&
                                                phonePass &&
                                                phoneLengthPass &&
                                                birthDatePass &&
                                                agePass) {
                                              if (widget.kakaoInfo != null &&
                                                  (widget.kakaoInfo!
                                                              .birthYear ==
                                                          '' ||
                                                      widget.kakaoInfo!
                                                              .birthDay ==
                                                          '')) {
                                                widget.kakaoInfo!.birthYear =
                                                    birthDate!.split('-')[0];
                                                widget.kakaoInfo!.birthDay =
                                                    '${birthDate!.split('-')[1]}${birthDate!.split('-')[2]}';
                                                widget.kakaoInfo!.ageRange =
                                                    ageRange(int.parse(
                                                        birthDate!
                                                            .split('-')[0]));
                                              }
                                              amplitudeEvent(
                                                  'account_create_completed',
                                                  {
                                                    'login_type': widget.type!
                                                        .toLowerCase()
                                                  },
                                                  init: false);
                                              bloc.add(ProfileSaveEvent(
                                                  birthDate: widget.type ==
                                                          'KAKAO'
                                                      ? (widget.kakaoInfo!
                                                                      .birthYear ==
                                                                  '' ||
                                                              widget.kakaoInfo!
                                                                      .birthDay ==
                                                                  '')
                                                          ? '${birthDate!.split('-')[0]}${birthDate!.split('-')[1]}${birthDate!.split('-')[2]}'
                                                          : '${widget.kakaoInfo!.birthYear}${widget.kakaoInfo!.birthDay}'
                                                      : '${birthDate!.split('-')[0]}${birthDate!.split('-')[1]}${birthDate!.split('-')[2]}',
                                                  phone: widget.type == 'KAKAO'
                                                      ? widget.kakaoInfo!
                                                          .phoneNumber
                                                      : phoneController.text ==
                                                              ''
                                                          ? null
                                                          : phoneController
                                                              .text,
                                                  gender: widget.type == 'KAKAO'
                                                      ? widget.kakaoInfo!
                                                                  .gender ==
                                                              ''
                                                          ? gender
                                                          : widget.kakaoInfo!
                                                                      .gender ==
                                                                  "UNKNOWN"
                                                              ? 'OTHER'
                                                              : widget
                                                                  .kakaoInfo!
                                                                  .gender
                                                      : gender,
                                                  email: emailController.text,
                                                  nickName: nameController.text,
                                                  type: widget.type,
                                                  kakaoInfo: widget.kakaoInfo,
                                                  appleInfo: widget.appleInfo,
                                                  accessId: widget.accessId,
                                                  image: widget.image,
                                                  device: widget.device));
                                            } else {
                                              setState(() {});
                                            }
                                          } else {
                                            if (namePass &&
                                                emailPass &&
                                                emailRegPass &&
                                                phonePass &&
                                                phoneLengthPass &&
                                                birthDatePass) {
                                              backCheck();
                                              amplitudeEvent(
                                                  'profile_set_completed', {
                                                'profile_image':
                                                    bloc.editProfileImage,
                                                'profile_email':
                                                    bloc.editProfileEmail,
                                                'profile_nickName':
                                                    bloc.editProfileNickName,
                                                'profile_introText':
                                                    bloc.editProfileContent,
                                                'profile_gender':
                                                    bloc.editProfileGender,
                                                'profile_phone':
                                                    bloc.editProfilePhone
                                              });
                                              if (widget.type == 'APPLE') {
                                                bloc.add(ProfileSaveEvent(
                                                    birthDate: birthDate!
                                                        .replaceAll('-', ''),
                                                    phone: phoneController.text,
                                                    gender: widget.type == 'APPLE'
                                                        ? genderText(bloc.genderSelect,
                                                            save: true)
                                                        : UserData.fromJson(
                                                                jsonDecode(prefs!
                                                                    .getString(
                                                                        'userData')
                                                                    .toString()))
                                                            .gender,
                                                    email: emailController.text,
                                                    nickName:
                                                        nameController.text,
                                                    introText: introduceController.text.length == 0
                                                        ? null
                                                        : introduceController.text));
                                              } else {
                                                bloc.add(ProfileSaveEvent(
                                                    email: emailController.text,
                                                    nickName:
                                                        nameController.text,
                                                    introText:
                                                        introduceController.text
                                                                    .length ==
                                                                0
                                                            ? null
                                                            : introduceController
                                                                .text));
                                              }
                                            } else {
                                              setState(() {});
                                            }
                                          }
                                        },
                                        text: AppStrings.of(widget.signUp!
                                            ? StringKey.baeitStart
                                            : StringKey.save))
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  loadingView(bloc.loading)
                ],
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SignUpFinishState) {
      pushAndRemoveUntil(context, SetGoalPage());
    }

    if (state is GenderSelectState) {
      if (state.select == 0) {
        gender = 'FEMALE';
      } else if (state.select == 1) {
        gender = 'MALE';
      } else if (state.select == 2) {
        gender = 'OTHER';
      }
    }

    if (state is ProfileInitState) {
      if (!widget.signUp!) {
        if (bloc.profileGet != null) {
          nameController.text = bloc.profileGet!.nickName;
          emailController.text = bloc.profileGet!.email;
          introduceController.text = bloc.profileGet!.introText ?? '';
          initName = bloc.profileGet!.nickName;
          initEmail = bloc.profileGet!.email;
          initIntroduce = bloc.profileGet!.introText ?? '';
          if (widget.type == 'APPLE') {
            phoneController.text = bloc.profileGet!.phone;
            if (bloc.profileGet!.gender == 'FEMALE') {
              bloc.genderSelect = 0;
            } else if (bloc.profileGet!.gender == "MALE") {
              bloc.genderSelect = 1;
            } else {
              bloc.genderSelect = 2;
            }
            gender = bloc.profileGet!.gender;
            birthDate = bloc.profileGet!.birthDate;
            initPhone = bloc.profileGet!.phone;
            initGender = bloc.genderSelect;
            initBirthDate = bloc.profileGet!.birthDate;
          }
        }
      } else {
        if (widget.type == "KAKAO") {
          nameController.text = widget.kakaoInfo!.nickName;
          emailController.text = widget.kakaoInfo!.email;
          if (widget.kakaoInfo!.gender == "UNKNOWN") {
            bloc.genderSelect = 2;
          }
          initName = widget.kakaoInfo!.nickName;
          initEmail = widget.kakaoInfo!.email;
          initGender = bloc.genderSelect;
        } else if (widget.type == "APPLE") {
          nameController.text = widget.appleInfo!.nickName ?? '';
          emailController.text = widget.appleInfo!.email;
          initName = widget.appleInfo!.nickName ?? '';
          initEmail = widget.appleInfo!.email;
        }
      }
    }

    if (state is ProfileSaveState) {
      if (widget.signUp!) {
        pushAndRemoveUntil(context, MainPage());
      } else {
        popWithResult(context, true);
      }
    }

    if (state is GetFileState) {
      imagePass = true;
      setState(() {});
    }
  }

  @override
  ProfileBloc initBloc() {
    return ProfileBloc(context)
      ..add(ProfileInitEvent(
          signUp: widget.signUp!,
          profile: widget.profile,
          image: widget.image));
  }
}
