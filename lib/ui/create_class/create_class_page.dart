import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/class/variations_class.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/create_class/create_class_bloc.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/neighborhood_add/neighborhood_add_page.dart';
import 'package:baeit/ui/neighborhood_class/neighborhood_class_bloc.dart';
import 'package:baeit/utils/category.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/custom_tooltip.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateClassPage extends BlocStatefulWidget {
  final NeighborHoodClassBloc? classBloc;
  final ProfileGet profileGet;
  final bool edit;
  String? classUuid;
  final bool floating;
  final bool temp;
  final bool ing;
  final String previousPage;
  final bool stop;

  CreateClassPage(
      {this.classBloc,
      required this.profileGet,
      this.edit = false,
      this.classUuid,
      this.floating = false,
      this.temp = false,
      this.ing = false,
      this.previousPage = '',
      this.stop = false});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return CreateClassState();
  }
}

class CreateClassState extends BlocState<CreateClassBloc, CreateClassPage>
    with TickerProviderStateMixin {
  TextEditingController classTitleController = TextEditingController();
  TextEditingController classContentController = TextEditingController();
  TextEditingController lowCostController = TextEditingController();
  TextEditingController teacherController = TextEditingController();
  TextEditingController groupCostController = TextEditingController();

  FocusNode classTitleFocus = FocusNode();
  FocusNode classContentFocus = FocusNode();
  FocusNode lowCostFocus = FocusNode();
  FocusNode teacherFocus = FocusNode();
  FocusNode groupCostFocus = FocusNode();

  bool categoryPass = true;
  bool titlePass = true;
  bool contentPass = true;
  bool lowCostPass = true;
  bool costPass = true;
  bool keywordPass = true;
  bool mainImagePass = true;
  bool teacherPass = true;
  bool groupCostPass = true;
  bool contentCheckListPass = true;
  bool introduceCheckListPass = true;

  bool move = false;

  ImagePicker imagePicker = ImagePicker();

  AnimationController? controller;

  ScrollController scrollController = ScrollController();
  ScrollController categoryController = ScrollController();

  List<bool> tempCheck = [false, false, false];

  List<FocusNode> keywordFocus = List.generate(5, (index) => FocusNode());
  List<bool> keywordTextCheck = List.generate(5, (index) => false);
  List<bool> keywordFocusCheckMade = List.generate(5, (index) => false);
  List<bool> keywordTextingCheckMade = List.generate(5, (index) => false);

  List<bool> contentCheckList = List.generate(4, (index) => false);
  List<bool> introduceCheckList = List.generate(2, (index) => false);

  stepItem(int index) {
    return Column(
      children: [
        ClipOval(
          child: Container(
            width: 24,
            height: 24,
            color: bloc.step == index
                ? AppColors.primary
                : bloc.step > index
                    ? AppColors.primaryLight50
                    : AppColors.gray100,
            child: Center(
              child: customText(
                '${index + 1}',
                style: TextStyle(
                    color: bloc.step == index
                        ? AppColors.white
                        : bloc.step > index
                            ? AppColors.primaryDark10
                            : AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T9)),
              ),
            ),
          ),
        ),
        spaceH(4),
        bloc.step == index
            ? Container(
                child: customText(
                  'STEP',
                  style: TextStyle(
                      color: AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T9)),
                ),
              )
            : spaceH(9)
      ],
    );
  }

  stepCount() {
    return Padding(
      padding: EdgeInsets.only(left: 60, right: 60),
      child: Row(
        children: [
          stepItem(0),
          Expanded(
              child: Column(
            children: [
              heightLine(
                  color: bloc.step == 0
                      ? AppColors.gray100
                      : AppColors.primaryLight50,
                  height: 1),
              spaceH(12)
            ],
          )),
          stepItem(1),
          Expanded(
              child: Column(
            children: [
              heightLine(
                  color: bloc.step < 2
                      ? AppColors.gray100
                      : AppColors.primaryLight50,
                  height: 1),
              spaceH(12)
            ],
          )),
          stepItem(2),
        ],
      ),
    );
  }

  mainView() {
    return PageTransitionSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SharedAxisTransition(
            child: Container(
                height: bloc.isNextStep
                    ? MediaQuery.of(context).size.height -
                        (MediaQuery.of(context).padding.top +
                            MediaQuery.of(context).padding.bottom +
                            120)
                    : null,
                child: child),
            fillColor: AppColors.white,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal);
      },
      duration: Duration(milliseconds: 300),
      child: stepView(),
    );
  }

  neighborHoodListItem(int idx) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 74,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200)),
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                bloc.neighborHoodList[idx].hangName ?? '',
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              spaceH(6),
              customText(
                bloc.neighborHoodList[idx].roadAddress != null
                    ? bloc.neighborHoodList[idx].roadAddress!
                    : bloc.neighborHoodList[idx].zipAddress!,
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              )
            ],
          ),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () {
              if (bloc.neighborHoodList.length == 1) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.removeNeighborHoodToast));
              } else {
                bloc.add(CreateClassNeighborHoodRemoveEvent(idx: idx));
              }
            },
            child: Image.asset(
              AppImages.iTrashG,
              width: 20,
              height: 20,
            ),
          )
        ],
      ),
    );
  }

  neighborHoodListItemAdd() {
    return GestureDetector(
      onTap: () {
        pushTransition(
            context,
            NeighborHoodAddPage(
              signUpEnd: true,
              create: true,
            )).then((value) {
          if (value != null) {
            if (value is NeighborHood) {
              bloc.neighborHoodList.add(value);
              setState(() {});
            }
          }
        });
      },
      child: Container(
        height: 74,
        child: DottedBorder(
          strokeWidth: 1,
          dashPattern: [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          color: AppColors.primary,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.iPlusC,
                  width: 16,
                  height: 16,
                ),
                spaceW(4),
                customText(
                  AppStrings.of(StringKey.neighborhoodAdd),
                  style: TextStyle(
                      color: AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  neighborHoodList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Column(
          children: [
            neighborHoodListItem(idx),
            spaceH(12),
            (idx < 2 && idx == bloc.neighborHoodList.length - 1)
                ? neighborHoodListItemAdd()
                : Container()
          ],
        );
      },
      shrinkWrap: true,
      itemCount: bloc.neighborHoodList.length,
    );
  }

  oneStep() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText(
                  AppStrings.of(StringKey.activityNeighborhood),
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                ),
                Expanded(child: Container()),
                customText(
                  AppStrings.of(StringKey.maxThree),
                  style: TextStyle(
                      color: AppColors.secondaryDark30,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                )
              ],
            ),
          ),
          neighborHoodList(),
          spaceH(34),
          customText(
            AppStrings.of(StringKey.category),
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.BOLD),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
          ),
          spaceH(14),
          Stack(
            children: [
              AnimatedContainer(
                onEnd: () {
                  scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                  bloc.categoryAnimationEnd = true;
                  setState(() {});
                },
                duration: Duration(milliseconds: 300),
                height: bloc.categorySelect ? 262 : 48,
                decoration: bloc.categorySelect
                    ? BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary, width: 2))
                    : null,
                child: bloc.categorySelect && bloc.categoryAnimationEnd
                    ? Column(
                        children: [
                          spaceH(15),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                customText(
                                  bloc.category == null
                                      ? '선택해주세요'
                                      : bloc.category!,
                                  style: TextStyle(
                                      color: bloc.category == null
                                          ? AppColors.gray400
                                          : AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: bloc.category == null
                                              ? TextWeight.REGULAR
                                              : TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                ),
                                Expanded(child: Container()),
                                Transform.rotate(
                                  angle: 180 * math.pi / 180,
                                  child: Image.asset(
                                    AppImages.iSelectACDown,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          spaceH(15),
                          heightLine(
                              color: AppColors.primaryLight40, height: 1),
                          spaceH(9),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: Scrollbar(
                              isAlwaysShown: true,
                              controller: categoryController,
                              child: ListView.builder(
                                controller: categoryController,
                                itemBuilder: (context, idx) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        bloc.categorySelect = false;
                                        bloc.categoryAnimationEnd = false;
                                        bloc.category = bloc.categoryItems[idx];
                                        categoryPass = true;
                                        setState(() {});
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 48,
                                        decoration: BoxDecoration(
                                            color: bloc.category ==
                                                    bloc.categoryItems[idx]
                                                ? AppColors.primaryLight60
                                                : AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: EdgeInsets.only(
                                            top: 15, bottom: 15, left: 10),
                                        child: customText(
                                          bloc.categoryItems[idx],
                                          style: TextStyle(
                                              color: bloc.category ==
                                                      bloc.categoryItems[idx]
                                                  ? AppColors.primaryDark10
                                                  : AppColors.gray900,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                      TextWeight.MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T13)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                shrinkWrap: true,
                                itemCount: bloc.categoryItems.length,
                              ),
                            ),
                          )
                        ],
                      )
                    : Align(
                        alignment: Alignment.topLeft,
                        child: bloc.categorySelect
                            ? Container()
                            : ElevatedButton(
                                onPressed: () {
                                  bloc.categorySelect = true;
                                  bloc.categoryAnimationEnd = false;
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: AppColors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                        left: 10,
                                        right: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: AppColors.gray200))),
                                child: Row(
                                  children: [
                                    customText(
                                      bloc.category == null
                                          ? '선택해주세요'
                                          : bloc.category!,
                                      style: TextStyle(
                                          color: bloc.category == null
                                              ? AppColors.gray400
                                              : AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: bloc.category == null
                                                  ? TextWeight.REGULAR
                                                  : TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T13)),
                                    ),
                                    Expanded(child: Container()),
                                    Image.asset(
                                      AppImages.iSelectACDown,
                                      width: 16,
                                      height: 16,
                                    )
                                  ],
                                ),
                              ),
                      ),
              )
            ],
          ),
          categoryPass
              ? Container()
              : issueMessage(title: AppStrings.of(StringKey.categoryIssue)),
          spaceH(40)
        ],
      ),
    );
  }

  classTitle() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText(
                  AppStrings.of(StringKey.classTitle),
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                ),
                spaceW(6),
                CustomTooltip(
                  message: AppStrings.of(StringKey.classTitleTip),
                ),
                Expanded(child: Container()),
                customText(
                  classTitleController.text.characters.length.toString(),
                  style: TextStyle(
                      color: AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                ),
                customText(
                  ' / 7 ~ 20',
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                )
              ],
            ),
          ),
          Container(
            height: 48,
            child: TextFormField(
                onChanged: (text) {
                  titlePass = true;
                  blankCheck(text: text, controller: classTitleController);
                  setState(() {});
                },
                maxLength: 20,
                maxLines: 1,
                controller: classTitleController,
                focusNode: classTitleFocus,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {},
                style: TextStyle(
                    color: AppColors.primaryDark10,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
                decoration: InputDecoration(
                  suffixIcon: classTitleController.text.length > 0
                      ? Padding(
                          padding: EdgeInsets.only(top: 14, bottom: 14),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                classTitleController.text = '';
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
                      borderSide:
                          BorderSide(width: 1, color: AppColors.gray200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: AppColors.primaryLight40)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 2, color: AppColors.primaryLight30)),
                )),
          ),
          titlePass
              ? Container()
              : issueMessage(title: AppStrings.of(StringKey.classTitleIssue))
        ],
      ),
    );
  }

  classContent() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText(
                  AppStrings.of(StringKey.classContent),
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                ),
                spaceW(6),
                CustomTooltip(
                  message: AppStrings.of(StringKey.classContentTip),
                ),
                Expanded(child: Container()),
                customText(
                  classContentController.text.characters.length.toString(),
                  style: TextStyle(
                      color: AppColors.primaryDark10,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                ),
                customText(
                  ' / 80 ~ 2000',
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                ),
              ],
            ),
          ),
          Container(
            height: 182,
            child: TextFormField(
                onChanged: (text) {
                  contentPass = true;
                  blankCheck(
                      text: text,
                      controller: classContentController,
                      multiline: true);
                  setState(() {});
                },
                maxLength: 2000,
                maxLines: null,
                controller: classContentController,
                focusNode: classContentFocus,
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
                  hintText: AppStrings.of(StringKey.classContentPlaceHolder),
                  hintMaxLines: 3,
                  hintStyle: TextStyle(
                      color: AppColors.primaryDark10.withOpacity(0.4),
                      fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                      fontSize: fontSizeSet(textSize: TextSize.T13)),
                  contentPadding:
                      EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                  fillColor: AppColors.primaryLight60,
                  filled: true,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(width: 1, color: AppColors.gray200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: AppColors.primaryLight40)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 2, color: AppColors.primaryLight30)),
                )),
          ),
          contentPass
              ? Container()
              : issueMessage(title: AppStrings.of(StringKey.classContentIssue))
        ],
      ),
    );
  }

  shareSelecter() {
    List<Widget> shareItem = [];
    for (int i = 0; i < 4; i++) {
      shareItem.add(GestureDetector(
        onTap: () {
          bloc.add(ShareTypeChangeEvent(type: i));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            bloc.selectShareType == i
                ? ClipOval(
                    child: Container(
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                      child: Center(
                          child: Image.asset(
                        AppImages.iCheckCSmall,
                        width: 12,
                        height: 12,
                        color: AppColors.white,
                      )),
                    ),
                  )
                : Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gray300)),
                  ),
            spaceW(8),
            customText(shareSelectText(i),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T14)))
          ],
        ),
      ));
      shareItem.add(spaceH(16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: shareItem,
    );
  }

  classCost() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: customText(
                    AppStrings.of(StringKey.cost),
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 36,
            child: Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    bloc.add(CostTypeChangeEvent(type: 0));
                  },
                  child: Center(
                    child: customText('시간당',
                        style: TextStyle(
                            color: bloc.selectCostType == 0
                                ? AppColors.white
                                : AppColors.gray400,
                            fontWeight: weightSet(
                              textWeight: bloc.selectCostType == 0
                                  ? TextWeight.BOLD
                                  : TextWeight.MEDIUM,
                            ),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: bloc.selectCostType == 0
                          ? AppColors.primary
                          : AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: bloc.selectCostType != 0
                              ? BorderSide(width: 1, color: AppColors.gray200)
                              : BorderSide.none,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6)))),
                )),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    costPass = true;
                    lowCostPass = true;
                    lowCostController.text = '';
                    bloc.firstFreeFlag = 0;
                    bloc.groupFlag = 0;
                    bloc.personCount = null;
                    bloc.costOfPerson = null;
                    bloc.add(CostTypeChangeEvent(type: 1));
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        bloc.selectCostType == 1
                            ? Container()
                            : Image.asset(
                                AppImages.iHintCs,
                                width: 14,
                                height: 14,
                              ),
                        bloc.selectCostType == 1 ? Container() : spaceW(4),
                        customText('배움나눔',
                            style: TextStyle(
                                color: bloc.selectCostType == 1
                                    ? AppColors.white
                                    : AppColors.secondaryDark30,
                                fontWeight: weightSet(
                                  textWeight: bloc.selectCostType == 1
                                      ? TextWeight.BOLD
                                      : TextWeight.MEDIUM,
                                ),
                                fontSize: fontSizeSet(textSize: TextSize.T13)))
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: bloc.selectCostType == 1
                          ? AppColors.primary
                          : AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: bloc.selectCostType != 1
                              ? BorderSide(width: 1, color: AppColors.gray200)
                              : BorderSide.none,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6)))),
                ))
              ],
            ),
          ),
          spaceH(12),
          bloc.selectCostType == 0
              ? Container(
                  height: 48,
                  child: Row(
                    children: [
                      Container(
                          width: 100,
                          child: customText('1:1 비용',
                              style: TextStyle(
                                  color: AppColors.gray900,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T13)))),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Stack(
                            children: [
                              TextFormField(
                                  onChanged: (text) {
                                    lowCostPass = true;
                                    costPass = true;
                                    setState(() {});
                                  },
                                  maxLines: 1,
                                  maxLength: 7,
                                  controller: lowCostController,
                                  focusNode: lowCostFocus,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (value) {},
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    suffixIcon: lowCostController.text.length >
                                            0
                                        ? Padding(
                                            padding: EdgeInsets.only(right: 30),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  lowCostController.text = '';
                                                });
                                              },
                                              child: Image.asset(
                                                  AppImages.iInputClear,
                                                  width: 20,
                                                  height: 20),
                                            ),
                                          )
                                        : null,
                                    hintText: AppStrings.of(
                                        StringKey.costPlaceHolder),
                                    hintStyle: TextStyle(
                                        color: AppColors.gray500,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T13)),
                                    contentPadding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: AppColors.gray200)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: AppColors.gray200)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            width: 2,
                                            color: AppColors.primary)),
                                  )),
                              Positioned(
                                  top: 15,
                                  bottom: 0,
                                  right: 10,
                                  child: customText(
                                    '원',
                                    style: TextStyle(
                                        color: AppColors.primaryDark10,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T13)),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : shareSelecter(),
          Row(
            children: [
              lowCostPass
                  ? Container()
                  : issueMessage(
                      title: AppStrings.of(StringKey.classLowCostIssue)),
              costPass
                  ? Container()
                  : (!lowCostPass)
                      ? Container()
                      : issueMessage(
                          title: AppStrings.of(StringKey.classCostIssue)),
            ],
          )
        ],
      ),
    );
  }

  classKeyword() {
    List<Widget> keywords = [];
    for (int i = 0; i < 5; i++) {
      keywords.add(IntrinsicWidth(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: keywordTextCheck[i]
                  ? AppColors.accentLight50
                  : AppColors.white),
          child: DottedBorder(
            strokeWidth: keywordTextCheck[i]
                ? 1
                : keywordFocusCheckMade[i]
                    ? 2
                    : 0,
            dashPattern: keywordFocusCheckMade[i] ? [1, 0] : [5, 3],
            padding: EdgeInsets.only(left: 16, right: 11),
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: keywordTextCheck[i]
                ? AppColors.transparent
                : keywordFocusCheckMade[i]
                    ? AppColors.accentLight20
                    : AppColors.accentLight30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText('#',
                    style: TextStyle(
                        color: AppColors.accentLight30,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                Flexible(
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (value != '') {
                          setState(() {
                            keywordTextingCheckMade[i] = true;
                          });
                        } else {
                          if (keywordTextingCheckMade[i] == true) {
                            setState(() {
                              keywordTextingCheckMade[i] = false;
                            });
                          }
                        }
                      },
                      controller: bloc.keywordController[i],
                      focusNode: keywordFocus[i],
                      onFieldSubmitted: (value) {
                        setState(() {
                          keywordPass = true;
                        });
                      },
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          color: keywordTextCheck[i]
                              ? AppColors.accentDark10
                              : AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T14)),
                      maxLines: 1,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: keywordHint(i),
                          hintStyle: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(right: 12)),
                    ),
                  ),
                ),
                keywordTextCheck[i]
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              bloc.keywordController[i].text = '';
                              keywordTextCheck[i] = false;
                              keywordTextingCheckMade[i] = false;
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                right: 1,
                                top: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              Image.asset(
                                AppImages.iInputClearTrans,
                                width: 20,
                                height: 20,
                                color: AppColors.accentLight20,
                              )
                            ],
                          ),
                        ),
                      )
                    : keywordFocusCheckMade[i]
                        ? keywordTextingCheckMade[i]
                            ? Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.accentDark10,
                                ),
                              )
                            : Transform.rotate(
                                angle: 180 * math.pi / 240,
                                child: Image.asset(
                                  AppImages.iInputClearTrans,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xFF808080).withOpacity(0.8),
                                ),
                              )
                        : Image.asset(
                            AppImages.iEditUnderG,
                            width: 16,
                            height: 16,
                          )
              ],
            ),
          ),
        ),
      ));
    }
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                customText(AppStrings.of(StringKey.keyword),
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T14))),
                spaceW(6),
                CustomTooltip(
                    message: '클래스' + AppStrings.of(StringKey.keywordTip)),
              ],
            ),
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: keywords,
          ),
          spaceH(4),
          keywordPass
              ? Container()
              : issueMessage(
                  title: !keywordPass
                      ? AppStrings.of(StringKey.classKeywordIssue)
                      : ''),
        ],
      ),
    );
  }

  classMainImage() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            height: 60,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 20,
                        child: customText(
                          AppStrings.of(StringKey.mainImage),
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                        )),
                    spaceH(2),
                    Container(
                        height: 14,
                        child: customText(
                          AppStrings.of(StringKey.mainImageHint),
                          style: TextStyle(
                              color: AppColors.gray400,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T12)),
                        ))
                  ],
                ),
                // Expanded(child: Container()),
                // GestureDetector(
                //   onTap: () {
                //     bloc.add(PreviewChangeEvent());
                //   },
                //   child: Container(
                //     height: 30,
                //     child: Row(
                //       children: [
                //         Center(
                //           child: customText(
                //             AppStrings.of(StringKey.preview),
                //             style: TextStyle(
                //                 color: bloc.preview
                //                     ? AppColors.primaryDark10
                //                     : AppColors.gray600,
                //                 fontWeight:
                //                     weightSet(textWeight: TextWeight.MEDIUM),
                //                 fontSize: fontSizeSet(textSize: TextSize.T12)),
                //           ),
                //         ),
                //         spaceW(6),
                //         Container(
                //           height: 20,
                //           decoration: BoxDecoration(
                //               color: bloc.preview
                //                   ? AppColors.primary
                //                   : AppColors.gray400,
                //               borderRadius: BorderRadius.circular(20)),
                //           padding: EdgeInsets.only(left: 7.5, right: 7.5),
                //           child: Center(
                //             child: customText(
                //               bloc.preview ? 'ON' : 'OFF',
                //               style: TextStyle(
                //                   color: AppColors.white,
                //                   fontWeight:
                //                       weightSet(textWeight: TextWeight.MEDIUM),
                //                   fontSize:
                //                       fontSizeSet(textSize: TextSize.T12)),
                //             ),
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (Platform.isAndroid
                  ? await Permission.storage.isGranted
                  : await Permission.photos.isGranted ||
                      await Permission.photos.isLimited) {
                if (bloc.imageFile == null &&
                    (bloc.classDetail == null
                        ? true
                        : bloc.classDetail!.content.images!.length != 0
                            ? bloc.classDetail!.content.images![0]
                                    .representativeFlag ==
                                0
                            : true)) {
                  await imagePicker
                      .pickImage(source: ImageSource.gallery, imageQuality: 20)
                      .then((value) async {
                    if (value != null) {
                      bloc.imageFile = value;
                      await ImageCropper.cropImage(
                          sourcePath: value.path,
                          aspectRatio: CropAspectRatio(
                              ratioX: MediaQuery.of(context).size.width,
                              ratioY: (MediaQuery.of(context).size.width - 40) *
                                  0.5625),
                          maxWidth:
                              MediaQuery.of(context).size.width.toInt() - 40,
                          androidUiSettings: AndroidUiSettings(
                            toolbarTitle: '이미지 자르기',
                            toolbarColor: AppColors.primary,
                            toolbarWidgetColor: AppColors.white,
                            activeControlsWidgetColor: AppColors.primary,
                            initAspectRatio: CropAspectRatioPreset.ratio3x2,
                            hideBottomControls: true,
                            lockAspectRatio: true,
                          ),
                          compressQuality: 20,
                          iosUiSettings: IOSUiSettings(
                            minimumAspectRatio: 1.0,
                            aspectRatioLockEnabled: true,
                            aspectRatioPickerButtonHidden: true,
                            rotateButtonsHidden: true,
                            resetButtonHidden: true,
                            rectHeight: 180,
                          )).then((value) {
                        if (value != null) {
                          mainImagePass = true;
                          bloc.cropImageFile = value;
                        } else {
                          bloc.imageFile = null;
                        }
                      });
                    }
                  });
                  systemColorSetting();
                  bloc.add(GetFileEvent());
                }
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
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 180,
              child: bloc.cropImageFile == null && !widget.edit
                  ? DottedBorder(
                      strokeWidth: 1,
                      dashPattern: [5, 3],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      color: AppColors.primary,
                      child: Center(
                        child: Image.asset(
                          AppImages.iImgUpload,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    )
                  : widget.edit &&
                          (bloc.classDetail!.content.images!.length == 0 ||
                              bloc.classDetail!.content.images!.indexWhere(
                                      (element) =>
                                          element.representativeFlag == 1) ==
                                  -1) &&
                          bloc.cropImageFile == null
                      ? DottedBorder(
                          strokeWidth: 1,
                          dashPattern: [5, 3],
                          borderType: BorderType.RRect,
                          radius: Radius.circular(10),
                          color: AppColors.primary,
                          child: Center(
                            child: Image.asset(
                              AppImages.iImgUpload,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: widget.edit &&
                                          bloc.cropImageFile == null
                                      ? CacheImage(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          imageUrl:
                                              '${bloc.classDetail!.content.images![0].toView(
                                            context: context,
                                          )}',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(bloc.cropImageFile!.path),
                                          fit: BoxFit.cover,
                                        )),
                            ),
                            Positioned(
                                top: 8,
                                right: 12,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (Platform.isAndroid
                                        ? await Permission.storage.isGranted
                                        : await Permission.photos.isGranted ||
                                            await Permission.photos.isLimited) {
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
                                                  ratioX: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  ratioY: 180),
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width
                                                      .toInt() -
                                                  40,
                                              compressQuality: 20,
                                              androidUiSettings:
                                                  AndroidUiSettings(
                                                toolbarTitle: '이미지 자르기',
                                                toolbarColor: AppColors.primary,
                                                toolbarWidgetColor:
                                                    AppColors.white,
                                                activeControlsWidgetColor:
                                                    AppColors.primary,
                                                initAspectRatio:
                                                    CropAspectRatioPreset
                                                        .ratio3x2,
                                                hideBottomControls: true,
                                                lockAspectRatio: true,
                                              ),
                                              iosUiSettings: IOSUiSettings(
                                                minimumAspectRatio: 1.0,
                                                aspectRatioLockEnabled: true,
                                                aspectRatioPickerButtonHidden:
                                                    true,
                                                rotateButtonsHidden: true,
                                                resetButtonHidden: true,
                                                rectHeight: 180,
                                              )).then((value) {
                                            if (value != null) {
                                              mainImagePass = true;
                                              bloc.cropImageFile = value;
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
                                            await Permission
                                                .storage.isPermanentlyDenied
                                        : await Permission.photos.isDenied ||
                                            await Permission
                                                .photos.isPermanentlyDenied) {
                                      decisionDialog(
                                          context: context,
                                          barrier: false,
                                          text: Platform.isAndroid
                                              ? AppStrings.of(
                                                  StringKey.storageCheckText)
                                              : AppStrings.of(
                                                  StringKey.photoCheckText),
                                          allowText:
                                              AppStrings.of(StringKey.check),
                                          disallowText:
                                              AppStrings.of(StringKey.cancel),
                                          allowCallback: () async {
                                            popDialog(context);
                                            await openAppSettings();
                                          },
                                          disallowCallback: () {
                                            popDialog(context);
                                          });
                                    }
                                    // bloc.imageFile = null;
                                    // bloc.cropImageFile = null;
                                    // if (widget.edit &&
                                    //     bloc.classDetail!.content.images![0]
                                    //             .representativeFlag ==
                                    //         1) {
                                    //   bloc.classDetail!.content.images!
                                    //       .removeAt(0);
                                    // }
                                    // bloc.add(GetFileEvent());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary:
                                          Color(0xFF808080).withOpacity(0.4),
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        side: BorderSide(
                                          color: AppColors.gray500,
                                        ),
                                      )),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppImages.iRequest,
                                          width: 16,
                                          height: 16,
                                          color: AppColors.white,
                                        ),
                                        spaceW(4),
                                        customText('이미지 수정',
                                            style: TextStyle(
                                                color: AppColors.white,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.BOLD),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T10)))
                                      ],
                                    ),
                                  ),
                                )),
                            bloc.preview
                                ? Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 82,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(14),
                                              bottomRight: Radius.circular(14)),
                                          gradient: LinearGradient(
                                              begin: FractionalOffset.topCenter,
                                              end:
                                                  FractionalOffset.bottomCenter,
                                              colors: [
                                                AppColors.gray100
                                                    .withOpacity(0),
                                                AppColors.gray100
                                              ],
                                              stops: [
                                                0.0,
                                                1.0
                                              ])),
                                    ),
                                  )
                                : Container(),
                            bloc.preview
                                ? Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 82,
                                      padding: EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 12,
                                          bottom: 10),
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                categoryImage(bloc.categorySet(
                                                    bloc.category!)),
                                                width: 14,
                                                height: 14,
                                              ),
                                              spaceW(4),
                                              customText(
                                                bloc.category!,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryDark10,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.BOLD),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T10)),
                                              ),
                                            ],
                                          ),
                                          spaceH(6),
                                          Container(
                                            height: 20,
                                            child: customText(
                                              classTitleController
                                                          .text.length ==
                                                      0
                                                  ? AppStrings.of(StringKey
                                                      .previewTitleHint)
                                                  : classTitleController.text,
                                              style: TextStyle(
                                                  color: classTitleController
                                                              .text.length ==
                                                          0
                                                      ? AppColors.gray400
                                                      : AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T14)),
                                            ),
                                          ),
                                          spaceH(6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child:
                                                    widget.profileGet.profile !=
                                                            null
                                                        ? Image.network(
                                                            widget.profileGet
                                                                .profile!,
                                                            width: 14,
                                                            height: 14,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            AppImages.dfProfile,
                                                            width: 14,
                                                            height: 14,
                                                          ),
                                              ),
                                              spaceW(6),
                                              customText(
                                                widget.profileGet.nickName,
                                                style: TextStyle(
                                                    color: AppColors.gray400,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.REGULAR),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T11)),
                                              ),
                                              Expanded(child: Container()),
                                              customText(
                                                lowCostController.text.length ==
                                                        0
                                                    ? AppStrings.of(StringKey
                                                        .previewCostHint)
                                                    : '${numberFormatter(int.parse(lowCostController.text))}원 ~',
                                                style: TextStyle(
                                                    color: AppColors.gray400,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T11)),
                                              ),
                                              spaceW(4),
                                              customText(
                                                  AppStrings.of(
                                                      StringKey.timePay),
                                                  style: TextStyle(
                                                      color: AppColors.gray400,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T8))),
                                            ],
                                          )
                                        ],
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),
            ),
          ),
          mainImagePass
              ? Container()
              : issueMessage(
                  title: AppStrings.of(StringKey.classMainImageIssue))
        ],
      ),
    );
  }

  classSubImage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              customText(
                AppStrings.of(StringKey.subImage),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              spaceW(4),
              customText(
                '(${AppStrings.of(StringKey.choice)})',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              )
            ],
          ),
        ),
        Container(
          height: 48,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ElevatedButton(
            onPressed: () async {
              if (Platform.isAndroid
                  ? await Permission.storage.isGranted
                  : await Permission.photos.isGranted ||
                      await Permission.photos.isLimited) {
                List<Asset> resultList = [];
                if (bloc.imageFiles.length == 0 ||
                    bloc.imageFiles.length <
                        (widget.edit
                            ? 10 -
                                (bloc.classDetail!.content.images!.length > 0
                                    ? bloc.classDetail!.content.images!.length -
                                        1
                                    : bloc.classDetail!.content.images!.length)
                            : 10)) {
                  resultList = await MultiImagePicker.pickImages(
                      maxImages: 10 -
                          bloc.imageFiles.length -
                          (widget.edit
                              ? (bloc.classDetail!.content.images!.length > 0
                                  ? (widget.edit
                                      ? bloc.classDetail!.content.images!
                                              .length -
                                          1
                                      : 0)
                                  : 0)
                              : 0),
                      enableCamera: false,
                      selectedAssets: resultList);

                  if (!mounted) return;

                  for (int i = 0; i < resultList.length; i++) {
                    bloc.imageFiles.add(resultList[i]);
                  }
                  systemColorSetting();
                  bloc.add(GetFileEvent());
                }
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
                primary: AppColors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.primary))),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customText(
                    '${AppStrings.of(StringKey.registration)}  ${widget.edit ? bloc.imageFiles.length + (bloc.classDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) != -1 ? bloc.classDetail!.content.images!.length - 1 : bloc.classDetail!.content.images!.length) : bloc.imageFiles.length == 0 ? 0 : bloc.imageFiles.length.toString()}',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                  customText(
                    ' / 10',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  )
                ],
              ),
            ),
          ),
        ),
        bloc.imageFiles.length == 0 ||
                (widget.edit == true &&
                    bloc.classDetail!.content.images!.length == 0)
            ? Container()
            : spaceH(12),
        bloc.imageFiles.length == 0 ||
                (widget.edit == true &&
                    bloc.classDetail!.content.images!.length == 0)
            ? Container()
            : Container(
                width: MediaQuery.of(context).size.width,
                height: 54,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 20),
                  itemBuilder: (context, idx) {
                    if (widget.edit) {
                      if (idx <
                          ((bloc.classDetail!.content.images!.indexWhere(
                                      (element) =>
                                          element.representativeFlag == 1) ==
                                  -1)
                              ? bloc.classDetail!.content.images!.length
                              : bloc.classDetail!.content.images!.length - 1)) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                bloc.classDetail!.content.images!.removeAt(
                                    ((bloc.classDetail!.content.images!
                                                .indexWhere((element) =>
                                                    element
                                                        .representativeFlag ==
                                                    1) ==
                                            -1)
                                        ? idx
                                        : idx + 1));
                                bloc.add(GetFileEvent());
                              },
                              child: Container(
                                width: 96,
                                height: 54,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: CacheImage(
                                      imageUrl:
                                          '${bloc.classDetail!.content.images![((bloc.classDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1) ? idx : idx + 1)].toView(
                                        context: context,
                                      )}',
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                      placeholder: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary),
                                        ),
                                      ),
                                    )),
                                    Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Image.asset(
                                          AppImages.iInputClearTrans,
                                          width: 16,
                                          height: 16,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            spaceW(10)
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                bloc.imageFiles.removeAt((((bloc.classDetail!.content.images!
                                                    .indexWhere((element) =>
                                                        element.representativeFlag ==
                                                        1) ==
                                                -1)
                                            ? bloc.classDetail!.content.images!
                                                .length
                                            : (bloc.classDetail!.content.images!.length -
                                                1)) >
                                        idx + 1)
                                    ? (bloc.classDetail!.content.images!
                                                .indexWhere((element) => element.representativeFlag == 1) ==
                                            -1)
                                        ? bloc.classDetail!.content.images!.length - idx + 1
                                        : (bloc.classDetail!.content.images!.length - 1) - idx + 1
                                    : (bloc.classDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                        ? idx - (bloc.classDetail!.content.images!.length)
                                        : idx - (bloc.classDetail!.content.images!.length - 1));
                                bloc.add(GetFileEvent());
                              },
                              child: Container(
                                width: 96,
                                height: 54,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: AssetThumb(
                                      asset: bloc.imageFiles[((bloc.classDetail!
                                                          .content.images!
                                                          .indexWhere((element) =>
                                                              element.representativeFlag ==
                                                              1) ==
                                                      -1)
                                                  ? bloc.classDetail!.content
                                                      .images!.length
                                                  : bloc.classDetail!.content
                                                          .images!.length -
                                                      1) >
                                              idx
                                          ? (bloc.classDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                              ? bloc.classDetail!.content.images!.length - idx
                                              : (bloc.classDetail!.content.images!.length - 1) - idx
                                          : (bloc.classDetail!.content.images!.indexWhere((element) => element.representativeFlag == 1) == -1)
                                              ? idx - (bloc.classDetail!.content.images!.length)
                                              : idx - (bloc.classDetail!.content.images!.length - 1)],
                                      width: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toInt(),
                                      height: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toInt(),
                                      spinner: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary),
                                        ),
                                      ),
                                    )),
                                    Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Image.asset(
                                          AppImages.iInputClearTrans,
                                          width: 16,
                                          height: 16,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            spaceW(10)
                          ],
                        );
                      }
                    } else {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              bloc.imageFiles.removeAt(idx);
                              bloc.add(GetFileEvent());
                            },
                            child: Container(
                              width: 96,
                              height: 54,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: AssetThumb(
                                    asset: bloc.imageFiles[idx],
                                    width: MediaQuery.of(context)
                                        .size
                                        .width
                                        .toInt(),
                                    height: MediaQuery.of(context)
                                        .size
                                        .width
                                        .toInt(),
                                    spinner: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.primary),
                                      ),
                                    ),
                                  )),
                                  Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Image.asset(
                                        AppImages.iInputClearTrans,
                                        width: 16,
                                        height: 16,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          spaceW(10)
                        ],
                      );
                    }
                  },
                  shrinkWrap: true,
                  itemCount: widget.edit
                      ? (bloc.classDetail!.content.images!.indexWhere(
                                      (element) =>
                                          element.representativeFlag == 1) !=
                                  -1
                              ? bloc.classDetail!.content.images!.length - 1
                              : bloc.classDetail!.content.images!.length) +
                          bloc.imageFiles.length
                      : bloc.imageFiles.length,
                  scrollDirection: Axis.horizontal,
                ),
              )
      ],
    );
  }

  twoStep() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        classTitle(),
        spaceH(24),
        classContent(),
        spaceH(24),
        classCost(),
        bloc.selectCostType == 0 ? spaceH(12) : Container(),
        bloc.selectCostType == 0 ? groupClassSelect() : Container(),
        bloc.groupFlag == 1 ? spaceH(12) : Container(),
        bloc.selectCostType == 0 ? flagSet() : Container(),
        spaceH(20),
        classKeyword(),
        spaceH(20),
        classMainImage(),
        spaceH(20),
        classSubImage(),
        spaceH(20),
        contentCheckListView(),
        spaceH(40),
      ],
    );
  }

  contentCheckListView() {
    List<Widget> checkList = [];
    for (int i = 0; i < contentCheckList.length; i++) {
      checkList.add(Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                contentCheckList[i] = !contentCheckList[i];
                contentCheckListPass = true;
              });
            },
            child: Row(
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      onChanged: (value) {
                        setState(() {
                          contentCheckList[i] = value!;
                          contentCheckListPass = true;
                        });
                      },
                      activeColor: AppColors.primary,
                      value: contentCheckList[i],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(width: 1, color: AppColors.gray300),
                    )),
                spaceW(8),
                Flexible(
                  child: customText(contentCheckListText(i),
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T15))),
                )
              ],
            ),
          ),
          i == 3 ? Container() : spaceH(22)
        ],
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText('체크리스트',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15))),
                customText('내용이 자세할수록 더 많은 연락을 받을 수 있어요 :)',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              ],
            ),
          ),
          Column(
            children: checkList,
          ),
          contentCheckListPass
              ? Container()
              : issueMessage(title: '체크리스트를 확인해주세요'),
          contentCheckListPass ? spaceH(20) : spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText('※',
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
              spaceW(6),
              Flexible(
                child: customText(
                    '유해 콘텐츠가 포함된 경우·부적절한 내용인 경우·내용이 명확하게 드러나지 않는 경우에는 클래스가 운영중지 처리될 수 있습니다.',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              )
            ],
          )
        ],
      ),
    );
  }

  flagSet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (bloc.firstFreeFlag == 0) {
                  bloc.firstFreeFlag = 1;
                } else {
                  bloc.firstFreeFlag = 0;
                }
              });
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.only(left: 10, right: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                        width: 1,
                        color: bloc.firstFreeFlag == 0
                            ? AppColors.gray200
                            : AppColors.error))),
            child: Center(
              child: Row(
                children: [
                  customText('첫회무료',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(2),
                  customText('진행하기',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(6),
                  Container(
                    height: 16,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      color: bloc.firstFreeFlag == 0
                          ? AppColors.white
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: customText(
                          '${bloc.firstFreeFlag == 0 ? 'OFF' : 'ON'}',
                          style: TextStyle(
                              color: bloc.firstFreeFlag == 0
                                  ? AppColors.gray400
                                  : AppColors.white,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T10))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        spaceW(10),
        Container(
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              if (bloc.groupFlag == 0) {
                bloc.groupFlag = 1;
              } else {
                bloc.groupFlag = 0;
                groupCostPass = true;
              }
              bloc.add(GroupFlagChangeEvent());
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.only(left: 10, right: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                        width: 1,
                        color: bloc.groupFlag == 0
                            ? AppColors.gray200
                            : AppColors.accent))),
            child: Center(
              child: Row(
                children: [
                  customText('그룹할인',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(2),
                  customText('설정하기',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                  spaceW(6),
                  Container(
                    height: 16,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      color: bloc.groupFlag == 0
                          ? AppColors.white
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: customText('${bloc.groupFlag == 0 ? 'OFF' : 'ON'}',
                          style: TextStyle(
                              color: bloc.groupFlag == 0
                                  ? AppColors.gray400
                                  : AppColors.white,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T10))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        spaceW(20)
      ],
    );
  }

  groupClassSelect() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          bloc.groupFlag == 0
              ? Container()
              : Row(
                  children: [
                    Container(
                        width: 100,
                        child: customText('그룹 비용\n(1인당)',
                            style: TextStyle(
                                color: AppColors.gray900,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize:
                                    fontSizeSet(textSize: TextSize.T13)))),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Stack(
                          children: [
                            TextFormField(
                                onChanged: (text) {
                                  groupCostPass = true;
                                  bloc.costOfPerson = text == ''
                                      ? 0
                                      : int.parse(groupCostController.text);
                                  setState(() {});
                                },
                                maxLines: 1,
                                maxLength: 7,
                                controller: groupCostController,
                                focusNode: groupCostFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {},
                                style: TextStyle(
                                    color: AppColors.gray900,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T13)),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  suffixIcon: groupCostController.text.length >
                                          0
                                      ? Padding(
                                          padding: EdgeInsets.only(right: 30),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                groupCostController.text = '';
                                              });
                                            },
                                            child: Image.asset(
                                                AppImages.iInputClear,
                                                width: 20,
                                                height: 20),
                                          ),
                                        )
                                      : null,
                                  hintText: '최소 비용',
                                  hintStyle: TextStyle(
                                      color: AppColors.gray500,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                  contentPadding:
                                      EdgeInsets.only(left: 10, right: 10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 1, color: AppColors.gray200)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 1, color: AppColors.gray200)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          width: 2, color: AppColors.primary)),
                                )),
                            Positioned(
                                top: 15,
                                bottom: 0,
                                right: 10,
                                child: customText(
                                  '원',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T13)),
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
          groupCostPass || bloc.groupFlag == 0
              ? Container()
              : issueMessage(title: '최소 1자 ~ 최대 7자')
        ],
      ),
    );
  }

  teacherInformation() {
    return Column(
      children: [
        Container(
          height: 48,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              customText(
                AppStrings.of(StringKey.teacherInformation),
                style: TextStyle(
                    color: AppColors.gray900,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T14)),
              ),
              spaceW(6),
              CustomTooltip(
                  message: AppStrings.of(StringKey.teacherInformationTip)),
              Expanded(child: Container()),
              customText(
                teacherController.text.characters.length.toString(),
                style: TextStyle(
                    color: AppColors.primaryDark10,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              customText(
                ' / 50 ~ 2000',
                style: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              )
            ],
          ),
        ),
        Container(
          height: 182,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: TextFormField(
              onChanged: (text) {
                teacherPass = true;
                blankCheck(
                    text: text, controller: teacherController, multiline: true);
                setState(() {});
              },
              maxLength: 2000,
              maxLines: null,
              controller: teacherController,
              focusNode: teacherFocus,
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
                hintText:
                    AppStrings.of(StringKey.teacherInformationPlaceHolder),
                hintMaxLines: 3,
                hintStyle: TextStyle(
                    color: AppColors.primaryDark10.withOpacity(0.4),
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                contentPadding:
                    EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
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
                        BorderSide(width: 2, color: AppColors.primaryLight40)),
              )),
        ),
        teacherPass
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: 20),
                child:
                    issueMessage(title: AppStrings.of(StringKey.teacherIssue)),
              )
      ],
    );
  }

  threeStep() {
    return Column(
      children: [teacherInformation(), spaceH(20), introduceCheckListView()],
    );
  }

  introduceCheckListView() {
    List<Widget> checkList = [];
    for (int i = 0; i < introduceCheckList.length; i++) {
      checkList.add(Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                introduceCheckList[i] = !introduceCheckList[i];
                introduceCheckListPass = true;
              });
            },
            child: Row(
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      onChanged: (value) {
                        setState(() {
                          introduceCheckList[i] = value!;
                          introduceCheckListPass = true;
                        });
                      },
                      activeColor: AppColors.primary,
                      value: introduceCheckList[i],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(width: 1, color: AppColors.gray300),
                    )),
                spaceW(8),
                Flexible(
                  child: customText(introduceCheckListText(i),
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T15))),
                )
              ],
            ),
          ),
          i == 1 ? Container() : spaceH(22)
        ],
      ));
    }

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText('체크리스트',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15))),
                customText('내용이 자세할수록 더 많은 연락을 받을 수 있어요 :)',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              ],
            ),
          ),
          Column(
            children: checkList,
          ),
          introduceCheckListPass
              ? Container()
              : issueMessage(title: '체크리스트를 확인해주세요'),
          introduceCheckListPass ? spaceH(20) : spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText('※',
                  style: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T12))),
              spaceW(6),
              Flexible(
                child: customText(
                    '유해 콘텐츠가 포함된 경우·부적절한 내용인 경우·내용이 명확하게 드러나지 않는 경우에는 클래스가 운영중지 처리될 수 있습니다.',
                    style: TextStyle(
                        color: AppColors.gray400,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
              )
            ],
          )
        ],
      ),
    );
  }

  stepView() {
    switch (bloc.step) {
      case 0:
        return oneStep();
      case 1:
        return twoStep();
      case 2:
        return threeStep();
      default:
        return Container();
    }
  }

  bottomSet() {
    return Positioned(
        bottom: 12 + MediaQuery.of(context).padding.bottom,
        left: 0,
        right: 0,
        child: Column(
          children: [
            bottomGradient(
                context: context, height: 20, color: AppColors.white),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Row(
                children: [
                  widget.ing
                      ? Container()
                      : Expanded(
                          child: Container(
                          height: 48,
                          child: ElevatedButton(
                              onPressed: () {
                                List<Area> areas = [];
                                for (int i = 0;
                                    i < bloc.neighborHoodList.length;
                                    i++) {
                                  areas.add(Area(
                                      hangCode:
                                          bloc.neighborHoodList[i].hangCode!,
                                      buildingName: bloc.neighborHoodList[i]
                                              .buildingName ??
                                          '',
                                      lati: bloc.neighborHoodList[i].lati!,
                                      longi: bloc.neighborHoodList[i].longi!,
                                      roadAddress: bloc.neighborHoodList[i]
                                              .roadAddress ??
                                          null,
                                      zipAddress:
                                          bloc.neighborHoodList[i].zipAddress!,
                                      sidoName:
                                          bloc.neighborHoodList[i].sidoName,
                                      sigunguName:
                                          bloc.neighborHoodList[i].sigunguName,
                                      eupmyeondongName: bloc.neighborHoodList[i]
                                          .eupmyeondongName));
                                }

                                bloc.add(SaveTempClassEvent(
                                    areas: areas,
                                    title: classTitleController.text == ''
                                        ? null
                                        : classTitleController.text,
                                    classContent:
                                        classContentController.text == ''
                                            ? null
                                            : classContentController.text,
                                    teacherContent: teacherController.text == ''
                                        ? null
                                        : teacherController.text,
                                    minCost: lowCostController.text == ''
                                        ? null
                                        : int.parse(lowCostController.text),
                                    status: 'TEMP',
                                    type: 'MADE',
                                    classUuid: widget.classUuid,
                                    edit: widget.edit));
                                FocusScope.of(context).unfocus();
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: AppColors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      side:
                                          BorderSide(color: AppColors.gray200),
                                      borderRadius: BorderRadius.circular(8))),
                              child: Center(
                                child: customText(
                                  AppStrings.of(StringKey.temporarily),
                                  style: TextStyle(
                                      color: AppColors.gray500,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                              )),
                        )),
                  widget.ing ? Container() : spaceW(10),
                  Expanded(
                      flex: 2,
                      child: bottomButton(
                          context: context,
                          onPress: () {
                            move = false;
                            if (bloc.step == 0) {
                              if (bloc.category == null) {
                                categoryPass = false;
                                if (!bloc.categorySelect) {
                                  bloc.categoryAnimationEnd = false;
                                }
                                bloc.categorySelect = true;
                                setState(() {});
                              }
                              if (categoryPass) {
                                scrollController.jumpTo(0);
                                amplitudeEvent(
                                    widget.edit && !widget.temp
                                        ? 'class_next_step_1_clicks_edit'
                                        : 'class_next_step_1_clicks',
                                    {
                                      'town_sido': bloc.neighborHoodList
                                          .map((e) => e.sidoName)
                                          .toList()
                                          .join(','),
                                      'town_sigungu': bloc.neighborHoodList
                                          .map((e) => e.sigunguName)
                                          .toList()
                                          .join(','),
                                      'town_dongeupmyeon': bloc.neighborHoodList
                                          .map((e) => e.eupmyeondongName)
                                          .toList()
                                          .join(','),
                                      'costType': bloc.selectCostType,
                                      'costSharing':
                                          shareType(bloc.selectShareType),
                                      'category':
                                          bloc.categorySet(bloc.category!),
                                      'temporary_storage': tempCheck[0],
                                      'inflow_page': widget.previousPage
                                    });
                                bloc.add(StepChangeEvent(step: bloc.step + 1));
                              }
                            } else if (bloc.step == 1) {
                              if (classTitleController.text.characters.length <
                                  7) {
                                titlePass = false;
                                if (!move) {
                                  move = true;
                                  FocusScope.of(context)
                                      .requestFocus(classTitleFocus);
                                }
                              }
                              if (classContentController
                                      .text.characters.length <
                                  80) {
                                contentPass = false;
                                if (!move) {
                                  move = true;
                                  FocusScope.of(context)
                                      .requestFocus(classContentFocus);
                                }
                              }
                              if (bloc.selectCostType == 0) {
                                if (lowCostController.text.length == 0) {
                                  lowCostPass = false;
                                  if (!move) {
                                    move = true;
                                    FocusScope.of(context)
                                        .requestFocus(lowCostFocus);
                                  }
                                }
                                if (bloc.groupFlag == 1) {
                                  if (groupCostController.text.length == 0) {
                                    groupCostPass = false;
                                    if (!move) {
                                      move = true;
                                      FocusScope.of(context)
                                          .requestFocus(groupCostFocus);
                                    }
                                  }
                                }
                              }
                              keywordPass = false;
                              for (int i = 0;
                                  i < bloc.keywordController.length;
                                  i++) {
                                if (bloc.keywordController[i].text != '') {
                                  keywordPass = true;
                                  break;
                                }
                              }
                              if (!keywordPass) {
                                if (!move) {
                                  move = true;
                                  FocusScope.of(context)
                                      .requestFocus(keywordFocus[0]);
                                }
                              }

                              if (widget.edit) {
                                if (bloc.classDetail!.content.images!.length ==
                                        0 &&
                                    bloc.cropImageFile == null) {
                                  mainImagePass = false;
                                  if (!move) {
                                    move = true;
                                    scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                }
                              } else {
                                if (bloc.cropImageFile == null) {
                                  mainImagePass = false;
                                  if (!move) {
                                    move = true;
                                    scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                }
                              }

                              if (contentCheckList.indexWhere(
                                      (element) => element == false) !=
                                  -1) {
                                contentCheckListPass = false;
                                if (!move) {
                                  move = true;
                                  scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                }
                              }

                              setState(() {});

                              if (titlePass &&
                                  contentPass &&
                                  costPass &&
                                  lowCostPass &&
                                  keywordPass &&
                                  mainImagePass &&
                                  groupCostPass &&
                                  contentCheckListPass) {
                                scrollController.jumpTo(0);
                                amplitudeEvent(
                                    widget.edit && !widget.temp
                                        ? 'class_next_step_2_clicks_edit'
                                        : 'class_next_step_2_clicks',
                                    {
                                      'first_free': bloc.firstFreeFlag == 0
                                          ? false
                                          : true,
                                      'group':
                                          bloc.groupFlag == 0 ? false : true,
                                      'group_cost': bloc.groupFlag == 0
                                          ? ''
                                          : groupCostController.text,
                                      'town_sido': bloc.neighborHoodList
                                          .map((e) => e.sidoName)
                                          .toList()
                                          .join(','),
                                      'town_sigungu': bloc.neighborHoodList
                                          .map((e) => e.sigunguName)
                                          .toList()
                                          .join(','),
                                      'town_dongeupmyeon': bloc.neighborHoodList
                                          .map((e) => e.eupmyeondongName)
                                          .toList()
                                          .join(','),
                                      'category':
                                          bloc.categorySet(bloc.category!),
                                      'temporary_storage': tempCheck[1],
                                      'cost_min': lowCostController.text,
                                      'costType': bloc.selectCostType,
                                      'costSharing':
                                          shareType(bloc.selectShareType),
                                      'inflow_page': widget.previousPage
                                    });
                                bloc.add(StepChangeEvent(step: bloc.step + 1));
                              }
                            } else {
                              if (bloc.step != 2) {
                                scrollController.jumpTo(0);
                                bloc.add(StepChangeEvent(step: bloc.step + 1));
                              } else if (bloc.step == 2) {
                                if (teacherController.text.characters.length <
                                    50) {
                                  teacherPass = false;
                                  if (!move) {
                                    move = true;
                                    FocusScope.of(context)
                                        .requestFocus(teacherFocus);
                                  }
                                  setState(() {});
                                }

                                if (introduceCheckList.indexWhere(
                                        (element) => element == false) !=
                                    -1) {
                                  introduceCheckListPass = false;
                                  if (!move) {
                                    move = true;
                                    scrollController.animateTo(
                                        scrollController
                                            .position.maxScrollExtent,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                  setState(() {});
                                }

                                if (teacherPass && introduceCheckListPass) {
                                  List<Area> areas = [];
                                  for (int i = 0;
                                      i < bloc.neighborHoodList.length;
                                      i++) {
                                    areas.add(Area(
                                        hangCode:
                                            bloc.neighborHoodList[i].hangCode!,
                                        buildingName: bloc.neighborHoodList[i]
                                                .buildingName ??
                                            '',
                                        lati: bloc.neighborHoodList[i].lati!,
                                        longi: bloc.neighborHoodList[i].longi!,
                                        roadAddress: bloc.neighborHoodList[i]
                                                .roadAddress ??
                                            null,
                                        zipAddress: bloc
                                            .neighborHoodList[i].zipAddress!,
                                        sidoName:
                                            bloc.neighborHoodList[i].sidoName,
                                        sigunguName: bloc
                                            .neighborHoodList[i].sigunguName,
                                        eupmyeondongName: bloc
                                            .neighborHoodList[i]
                                            .eupmyeondongName));
                                  }

                                  bloc.add(SaveClassEvent(
                                      areas: areas,
                                      title: classTitleController.text,
                                      classContent: classContentController.text,
                                      teacherContent: teacherController.text,
                                      minCost: bloc.selectCostType == 0
                                          ? int.parse(lowCostController.text)
                                          : 0,
                                      status: bloc.classDetail == null ||
                                              widget.temp
                                          ? 'NORMAL'
                                          : bloc.classDetail!.status,
                                      type: 'MADE',
                                      classUuid: widget.classUuid,
                                      edit: widget.edit));
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            }
                          },
                          text: bloc.step == 2
                              ? AppStrings.of(StringKey.finish)
                              : AppStrings.of(StringKey.nextStep)))
                ],
              ),
            )
          ],
        ));
  }

  finishClassCreateDialog() {
    return ListView(
      shrinkWrap: true,
      children: [
        spaceH(28),
        SizedBox(
          width: 135,
          height: 135,
          child: Lottie.asset(AppImages.checkAnimation, controller: controller,
              onLoaded: (composition) {
            setState(() {
              controller!.reset();
              controller!..duration = composition.duration;
              controller!.forward();
            });
          }),
        ),
        widget.stop
            ? Column(
                children: [
                  Container(
                    height: 24,
                    child: customText(
                      '조금만 기다려주세요!',
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T17)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  spaceH(20),
                  customText(
                    '검수는 영업일 기준 3일 이내에\n완료될 예정입니다.',
                    style: TextStyle(
                        color: AppColors.gray600,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                    textAlign: TextAlign.center,
                  ),
                  spaceH(20),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2.67)),
                                child: Center(
                                  child: customText(
                                    '영업일',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T10)),
                                  ),
                                ),
                              ),
                              spaceW(10),
                              customText('평일 10~17시',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                          spaceH(6),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2.67)),
                                child: Center(
                                  child: customText(
                                    '고객센터',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T10)),
                                  ),
                                ),
                              ),
                              spaceW(10),
                              customText('1661-2322',
                                  style: TextStyle(
                                      color: AppColors.primaryDark10,
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T12)))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  spaceH(40)
                ],
              )
            : Column(
                children: [
                  Container(
                    height: 24,
                    child: customText(
                      AppStrings.of(StringKey.finishClassCreateTitle),
                      style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T17)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  spaceH(20),
                  customText(
                    AppStrings.of(widget.edit && !widget.temp
                        ? StringKey.editClassCreateContent
                        : StringKey.finishClassCreateContent),
                    style: TextStyle(
                        color: AppColors.gray600,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12)),
                    textAlign: TextAlign.center,
                  ),
                  spaceH(60),
                ],
              ),
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: bottomButton(
              context: context,
              text: AppStrings.of(StringKey.check),
              onPress: () {
                popDialog(context);
                if (widget.floating) {
                  popWithResult(context, bloc.classUuid);
                } else {
                  if (widget.edit) {
                    popWithResult(context, true);
                  } else {
                    popWithResult(context, true);
                  }
                }
              }),
        )
      ],
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              if (bloc.step != 0) {
                scrollController.jumpTo(0);
                bloc.add(StepChangeEvent(step: bloc.step - 1));
              } else {
                decisionDialog(
                    context: context,
                    barrier: false,
                    text: AppStrings.of(StringKey.exitCheckText),
                    allowText: AppStrings.of(StringKey.check),
                    disallowText: AppStrings.of(StringKey.cancel),
                    allowCallback: () {
                      if (!widget.edit && !widget.temp) {
                        ClassRepository.classDeparture(
                            bloc.finalStep == 0 ? 1 : bloc.finalStep, 'MADE');
                      }

                      popDialog(context);
                      if (widget.edit) {
                        pop(context);
                      } else {
                        pop(context);
                      }
                    },
                    disallowCallback: () {
                      popDialog(context);
                    });
              }
              return Future.value(false);
            },
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                bloc.categorySelect = false;
                bloc.categoryAnimationEnd = false;
                setState(() {});
              },
              child: Container(
                color: AppColors.white,
                child: Stack(
                  children: [
                    Scaffold(
                      backgroundColor: AppColors.white,
                      appBar: baseAppBar(
                          title: AppStrings.of(widget.edit && !widget.temp
                              ? StringKey.editClass
                              : StringKey.madeClass),
                          context: context,
                          onPressed: () {
                            if (bloc.step != 0) {
                              scrollController.jumpTo(0);
                              bloc.add(StepChangeEvent(step: bloc.step - 1));
                            } else {
                              decisionDialog(
                                  context: context,
                                  barrier: false,
                                  text: AppStrings.of(StringKey.exitCheckText),
                                  allowText: AppStrings.of(StringKey.check),
                                  disallowText: AppStrings.of(StringKey.cancel),
                                  allowCallback: () {
                                    if (!widget.edit && !widget.temp) {
                                      ClassRepository.classDeparture(
                                          bloc.finalStep == 0
                                              ? 1
                                              : bloc.finalStep,
                                          'MADE');
                                    }

                                    popDialog(context);
                                    if (widget.edit) {
                                      pop(context);
                                    } else {
                                      pop(context);
                                    }
                                  },
                                  disallowCallback: () {
                                    popDialog(context);
                                  });
                            }
                          }),
                      resizeToAvoidBottomInset: true,
                      body: Container(
                        height: MediaQuery.of(context).size.height -
                            (MediaQuery.of(context).padding.top +
                                MediaQuery.of(context).padding.bottom +
                                120),
                        color: AppColors.white,
                        child: ListView(
                          controller: scrollController,
                          children: [
                            spaceH(20),
                            stepCount(),
                            spaceH(20),
                            mainView()
                          ],
                        ),
                      ),
                    ),
                    bottomSet(),
                    loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is CreateClassInitState) {
      if (widget.edit) {
        if (bloc.classDetail!.content.category != null) {
          bloc.category = bloc.classDetail!.content.category!.name;
        }
        classTitleController.text = bloc.classDetail!.content.title ?? '';
        classContentController.text =
            bloc.classDetail!.content.classIntroText ?? '';
        lowCostController.text = bloc.classDetail!.content.minCost == null
            ? ''
            : bloc.classDetail!.content.minCost.toString();
        for (int i = 0; i < bloc.classDetail!.content.keywords!.length; i++) {
          bloc.keywordController[i].text =
              bloc.classDetail!.content.keywords![i];
          keywordTextCheck[i] = true;
        }
        teacherController.text = bloc.classDetail!.content.tutorIntroText ?? '';
        bloc.selectCostType =
            bloc.classDetail!.content.costType == 'HOUR' ? 0 : 1;
        bloc.selectShareType =
            shareTypeIdx(bloc.classDetail!.content.shareType);
        bloc.groupFlag = bloc.classDetail!.content.groupFlag;
        bloc.firstFreeFlag = bloc.classDetail!.content.firstFreeFlag;
        groupCostController.text =
            bloc.classDetail!.content.costOfPerson.toString();
        bloc.costOfPerson = bloc.classDetail!.content.costOfPerson;
        setState(() {});
      } else {
        setState(() {
          classContentController.text = '💚 추천대상\n\n\n💚 알려줄 내용\n\n\n💚 수업방식\n';
          teacherController.text = '🗺 관련 경험\n\n\n🎉 자랑거리\n';
        });
      }
    }

    if (state is StepChangeState) {
      Timer(Duration(milliseconds: 300), () async {
        bloc.isNextStep = false;
        setState(() {});
      });
    }

    if (state is SaveClassState) {
      List<String> keyword = [];
      for (int i = 0; i < bloc.keywordController.length; i++) {
        if (bloc.keywordController[i].text != '') {
          keyword.add(bloc.keywordController[i].text);
        }
      }

      ProfileRepository.getProfile().then((value) {
        ProfileGet profile = ProfileGet.fromJson(value.data);
        if (widget.edit && !widget.temp) {
          amplitudeEvent('class_register_completed_edit', {
            'first_free': bloc.firstFreeFlag == 0 ? false : true,
            'group': bloc.groupFlag == 0 ? false : true,
            'group_cost': bloc.groupFlag == 0 ? '' : groupCostController.text,
            'town_sido':
                bloc.neighborHoodList.map((e) => e.sidoName).toList().join(','),
            'town_sigungu': bloc.neighborHoodList
                .map((e) => e.sigunguName)
                .toList()
                .join(','),
            'town_dongeupmyeon': bloc.neighborHoodList
                .map((e) => e.eupmyeondongName)
                .toList()
                .join(','),
            'category': bloc.categorySet(bloc.category!),
            'temporary_storage': tempCheck[2],
            'cost_min': lowCostController.text,
            'costType': bloc.selectCostType,
            'costSharing': shareType(bloc.selectShareType),
            'inflow_page': widget.previousPage,
            'class_id': bloc.classUuid,
            'class_name': classTitleController.text,
            'user_id': dataSaver.userData!.memberUuid,
            'user_name': profile.nickName,
            'keyword': keyword.join(",")
            // 추후에 수정된 사항들 변경됐는지 확인값 들어가야함
          });
        } else {
          amplitudeEvent('class_register_completed_step', {
            'first_free': bloc.firstFreeFlag == 0 ? false : true,
            'group': bloc.groupFlag == 0 ? false : true,
            'group_cost': bloc.groupFlag == 0 ? '' : groupCostController.text,
            'town_sido':
                bloc.neighborHoodList.map((e) => e.sidoName).toList().join(','),
            'town_sigungu': bloc.neighborHoodList
                .map((e) => e.sigunguName)
                .toList()
                .join(','),
            'town_dongeupmyeon': bloc.neighborHoodList
                .map((e) => e.eupmyeondongName)
                .toList()
                .join(','),
            'category': bloc.categorySet(bloc.category!),
            'temporary_storage': tempCheck[2],
            'cost_min': lowCostController.text,
            'costType': bloc.selectCostType,
            'costSharing': shareType(bloc.selectShareType),
            'inflow_page': widget.previousPage,
            'class_id': bloc.classUuid,
            'class_name': classTitleController.text,
            'user_id': dataSaver.userData!.memberUuid,
            'user_name': profile.nickName,
            'keyword': keyword.join(",")
          });
        }
      });
      dataSaver.mainBloc!.add(UiUpdateEvent());
      dataSaver.myBaeitBloc!.add(UpdateDataEvent());
      customDialog(
          context: context, barrier: true, widget: finishClassCreateDialog());
    }

    if (state is SaveTempClassState) {
      widget.classUuid = state.classUuid;
      tempCheck[bloc.step] = true;
      showToast(context: context, text: AppStrings.of(StringKey.tempSave));
    }
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    for (int i = 0; i < 5; i++) {
      keywordFocus[i].addListener(() {
        if (!keywordFocus[i].hasFocus) {
          keywordFocusCheckMade[i] = false;
          bloc.add(KeywordSetEvent());
          if (bloc.keywordController[i].text != '') {
            keywordTextCheck[i] = true;
            keywordPass = true;
          } else {
            keywordTextCheck[i] = false;
          }
          bloc.add(KeywordSetEvent());
        } else {
          keywordFocusCheckMade[i] = true;
          bloc.add(KeywordSetEvent());
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  CreateClassBloc initBloc() {
    // TODO: implement initBloc
    return CreateClassBloc(context)
      ..add(CreateClassInitEvent(
          neighborHood: dataSaver.neighborHood,
          edit: widget.edit,
          classUuid: widget.classUuid));
  }
}
