import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/review/review.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/image_view/image_view_detail_page.dart';
import 'package:baeit/ui/image_view/image_view_page.dart';
import 'package:baeit/ui/review/create_review_page.dart';
import 'package:baeit/ui/review/review_detail_bloc.dart';
import 'package:baeit/ui/review/review_report_page.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReviewDetailPage extends BlocStatefulWidget {
  final String classUuid;
  final ReviewCount? reviewCount;
  final int? chatBlock;
  final VoidCallback? moveChat;
  final String? nickName;
  final bool myClass;
  final Class? classDetail;

  ReviewDetailPage(
      {required this.classUuid,
      this.reviewCount,
      this.chatBlock,
      this.moveChat,
      this.nickName,
      this.myClass = false,
      this.classDetail});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ReviewDetailState();
  }
}

class ReviewDetailState extends BlocState<ReviewDetailBloc, ReviewDetailPage> {
  ScrollController? scrollController;
  bool comment = false;
  bool commentEdit = false;
  String editComment = '';
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  int currentLine = 1;
  String selectClassReviewUuid = '';

  reviewCounts(int num) {
    switch (num) {
      case 0:
        return widget.reviewCount == null
            ? bloc.reviewCount?.typeZeroSumCnt
            : widget.reviewCount!.typeZeroSumCnt;
      case 1:
        return widget.reviewCount == null
            ? bloc.reviewCount?.typeFirstSumCnt
            : widget.reviewCount!.typeFirstSumCnt;
      case 2:
        return widget.reviewCount == null
            ? bloc.reviewCount?.typeSecondSumCnt
            : widget.reviewCount!.typeSecondSumCnt;
      case 3:
        return widget.reviewCount == null
            ? bloc.reviewCount?.typeThirdSumCnt
            : widget.reviewCount!.typeThirdSumCnt;
      case 4:
        return widget.reviewCount == null
            ? bloc.reviewCount?.typeFourthSumCnt
            : widget.reviewCount!.typeFourthSumCnt;
    }
  }

  reviewColors(int num, int count) {
    Color? setColor;
    switch (num) {
      case 0:
        setColor = AppColors.primaryLight40;
        break;
      case 1:
        setColor = AppColors.primaryLight40.withOpacity(0.8);
        break;
      case 2:
        setColor = AppColors.primaryLight40.withOpacity(0.2);
        break;
      case 3:
        setColor = AppColors.white;
        break;
    }
    if (setColor == AppColors.white && count != 0) {
      setColor = AppColors.primaryLight40.withOpacity(0.2);
    }

    if (count == 0) {
      setColor = AppColors.white;
    }

    return setColor;
  }

  types() {
    List<Widget> types = [];
    for (int i = 0; i < bloc.reviewType.length; i++) {
      types.add(Container(
        width: MediaQuery.of(context).size.width,
        height: 54,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(i == 0 ? 10 : 0),
                topRight: Radius.circular(i == 0 ? 10 : 0),
                bottomLeft: Radius.circular(i == 4 ? 10 : 0),
                bottomRight: Radius.circular(i == 4 ? 10 : 0)),
            color: reviewColors(
                bloc
                    .reviewGrade[bloc.reviewGrade.indexWhere(
                        (element) => element.type == bloc.reviewType[i])]
                    .num,
                reviewCounts(i))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              spaceW(20),
              customText(reviewTypeText(bloc.reviewType[i]),
                  style: TextStyle(
                      color: reviewCounts(i) == 0
                          ? AppColors.gray400
                          : AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              Expanded(
                child: Container(),
              ),
              customText('${reviewCounts(i)}',
                  style: TextStyle(
                      color: reviewCounts(i) == 0
                          ? AppColors.gray400
                          : AppColors.primary,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T16))),
              spaceW(4),
              customText('표',
                  style: TextStyle(
                      color: reviewCounts(i) == 0
                          ? AppColors.gray400
                          : AppColors.greenGray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              spaceW(20),
            ],
          ),
        ),
      ));
    }

    return types;
  }

  review() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child:
                        bloc.reviewList!.reviewData[idx].writerMember.profile ==
                                null
                            ? Image.asset(
                                AppImages.dfProfile,
                                width: 32,
                                height: 32,
                              )
                            : CacheImage(
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                imageUrl: bloc.reviewList!.reviewData[idx]
                                    .writerMember.profile!,
                              ),
                  ),
                ),
                spaceW(10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        customText(
                            bloc.reviewList!.reviewData[idx].writerMember
                                .nickName,
                            style: TextStyle(
                                color: AppColors.greenGray500,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12))),
                        spaceW(8),
                        bloc.reviewList!.reviewData[idx].writerMember.status ==
                                    'STOP' ||
                                bloc.reviewList!.reviewData[idx].writerMember
                                        .status ==
                                    'WITHDRAWAL'
                            ? Container()
                            : Container(
                                width: 1,
                                height: 10,
                                color: AppColors.gray300,
                              ),
                        bloc.reviewList!.reviewData[idx].writerMember.status ==
                                    'STOP' ||
                                bloc.reviewList!.reviewData[idx].writerMember
                                        .status ==
                                    'WITHDRAWAL'
                            ? Container()
                            : spaceW(8),
                        bloc.reviewList!.reviewData[idx].writerMember.status ==
                                    'STOP' ||
                                bloc.reviewList!.reviewData[idx].writerMember
                                        .status ==
                                    'WITHDRAWAL'
                            ? Container()
                            : customText(
                                '${bloc.reviewList!.reviewData[idx].eupmyeondongName}·${DateTime.now().difference(bloc.reviewList!.reviewData[idx].editFlag == 1 ? bloc.reviewList!.reviewData[idx].updateDate! : bloc.reviewList!.reviewData[idx].createDate!).inMinutes > 14400 ? (bloc.reviewList!.reviewData[idx].editFlag == 1 ? bloc.reviewList!.reviewData[idx].updateDate : bloc.reviewList!.reviewData[idx].createDate!)?.yearMonthDay : timeCalculationText(DateTime.now().difference(bloc.reviewList!.reviewData[idx].editFlag == 1 ? bloc.reviewList!.reviewData[idx].updateDate! : bloc.reviewList!.reviewData[idx].createDate!).inMinutes)}',
                                style: TextStyle(
                                    color: AppColors.gray500,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.MEDIUM),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11))),
                      ],
                    ),
                    spaceH(8),
                    bloc.reviewList!.reviewData[idx].images != null &&
                            bloc.reviewList!.reviewData[idx].images!.length != 0
                        ? Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  amplitudeEvent('review_tabclick_imageclick', {
                                    'class_uuid': widget.classUuid,
                                    'class_review_uuid': bloc.reviewList!
                                        .reviewData[idx].classReviewUuid
                                  });
                                  pushTransition(
                                      context,
                                      ImageViewPage(
                                          imageUrls: bloc.reviewList!
                                              .reviewData[idx].images!,
                                          heroTag: ''));
                                },
                                child: Container(
                                  width: 96,
                                  height: 54,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CacheImage(
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                      imageUrl: bloc.reviewList!.reviewData[idx]
                                          .images![0]
                                          .toView(context: context),
                                    ),
                                  ),
                                ),
                              ),
                              bloc.reviewList!.reviewData[idx].images!.length >
                                      1
                                  ? spaceW(8)
                                  : Container(),
                              bloc.reviewList!.reviewData[idx].images!.length >
                                      1
                                  ? Container(
                                      width: 54,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          amplitudeEvent(
                                              'review_tabclick_imageclick', {
                                            'class_uuid': widget.classUuid,
                                            'class_review_uuid': bloc
                                                .reviewList!
                                                .reviewData[idx]
                                                .classReviewUuid
                                          });
                                          pushTransition(
                                              context,
                                              ImageViewDetailPage(
                                                  idx: 0,
                                                  images: bloc.reviewList!
                                                      .reviewData[idx].images!,
                                                  heroTag: ''));
                                        },
                                        child: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AppImages.iPlusC,
                                              width: 16,
                                              height: 16,
                                              color: AppColors.primary,
                                            ),
                                            spaceH(4),
                                            customText('더보기',
                                                style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.BOLD),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T11)))
                                          ],
                                        )),
                                        style: ElevatedButton.styleFrom(
                                            primary: AppColors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.only(
                                                left: 8, right: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            side: BorderSide(
                                                width: 1,
                                                color: AppColors.primary)),
                                      ),
                                    )
                                  : Container()
                            ],
                          )
                        : Container(),
                    bloc.reviewList!.reviewData[idx].images != null &&
                            bloc.reviewList!.reviewData[idx].images!.length != 0
                        ? spaceH(8)
                        : Container(),
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Row(
                        children: [
                          Flexible(
                            child: customText(
                                bloc.reviewList!.reviewData[idx].contentText,
                                style: TextStyle(
                                    color: AppColors.gray900,
                                    fontWeight: weightSet(
                                        textWeight: TextWeight.REGULAR),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T14))),
                          ),
                        ],
                      ),
                    ),
                    bloc.reviewList!.reviewData[idx].editFlag == 1
                        ? customText('(수정됨)',
                            style: TextStyle(
                                color: AppColors.gray400,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T12)))
                        : Container(),
                    widget.myClass &&
                            bloc.reviewList!.reviewData[idx].answerFlag == 0
                        ? spaceH(8)
                        : Container(),
                    widget.myClass &&
                            bloc.reviewList!.reviewData[idx].answerFlag == 0
                        ? GestureDetector(
                            onTap: () async {
                              setState(() {
                                comment = true;
                                commentController.text = '';
                                selectClassReviewUuid = bloc.reviewList!
                                    .reviewData[idx].classReviewUuid;
                              });

                              await Future.delayed(Duration(milliseconds: 200));

                              commentFocus.unfocus();
                              FocusScope.of(context).requestFocus(commentFocus);
                            },
                            child: customText('답글달기 >',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T11))),
                          )
                        : Container(),
                  ],
                ),
                Expanded(child: Container()),
                bloc.reviewList!.reviewData[idx].writerMember.status ==
                            'STOP' ||
                        bloc.reviewList!.reviewData[idx].writerMember.status ==
                            'WITHDRAWAL' || (!widget.myClass && bloc.reviewList!.reviewData[idx].mineFlag ==
                    0)
                    ? Container()
                    : !dataSaver.nonMember
                        ? GestureDetector(
                            onTap: () {
                              if (bloc.reviewList!.reviewData[idx].mineFlag ==
                                  1) {
                                editDialog(
                                    bloc.reviewList!.reviewData[idx]
                                        .contentText,
                                    bloc.reviewList!.reviewData[idx]
                                        .classReviewUuid,
                                    nickName: widget.nickName);
                              } else if (widget.myClass) {
                                reportDialog(
                                    bloc.reviewList!.reviewData[idx]
                                        .contentText,
                                    bloc.reviewList!.reviewData[idx]
                                        .classReviewUuid,
                                    bloc.reviewList!.reviewData[idx]
                                                .reportFlag ==
                                            1
                                        ? true
                                        : false);
                              }
                            },
                            child: Image.asset(
                              AppImages.iMore,
                              width: 18,
                              height: 18,
                            ),
                          )
                        : Container()
              ],
            ),
            spaceH(20),
            bloc.reviewList!.reviewData[idx].answerFlag == 0
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(left: 42),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: bloc.reviewList!.reviewData[idx]
                                            .answerMember!.profile ==
                                        null
                                    ? Image.asset(
                                        AppImages.dfProfile,
                                        width: 32,
                                        height: 32,
                                      )
                                    : CacheImage(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                        imageUrl: bloc
                                            .reviewList!
                                            .reviewData[idx]
                                            .answerMember!
                                            .profile!,
                                      ),
                              ),
                            ),
                            spaceW(10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    customText(
                                        bloc.reviewList!.reviewData[idx]
                                            .answerMember!.nickName,
                                        style: TextStyle(
                                            color: AppColors.greenGray500,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12))),
                                    spaceW(8),
                                    bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'STOP' ||
                                            bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'WITHDRAWAL'
                                        ? Container()
                                        : Container(
                                            width: 1,
                                            height: 10,
                                            color: AppColors.gray300,
                                          ),
                                    bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'STOP' ||
                                            bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'WITHDRAWAL'
                                        ? Container()
                                        : spaceW(8),
                                    bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'STOP' ||
                                            bloc.reviewList!.reviewData[idx]
                                                    .answerMember!.status ==
                                                'WITHDRAWAL'
                                        ? Container()
                                        : customText(
                                            '${bloc.reviewList!.reviewData[idx].answerEupmyeondongName}·${DateTime.now().difference(bloc.reviewList!.reviewData[idx].answerDate!).inMinutes > 14400 ? bloc.reviewList!.reviewData[idx].answerDate!.yearMonthDay : timeCalculationText(DateTime.now().difference(bloc.reviewList!.reviewData[idx].answerDate!).inMinutes)}',
                                            style: TextStyle(
                                                color: AppColors.gray500,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.MEDIUM),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T11))),
                                  ],
                                ),
                                spaceH(8),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 142,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: customText(
                                            bloc.reviewList!.reviewData[idx]
                                                .answerText!,
                                            style: TextStyle(
                                                color: AppColors.gray900,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.REGULAR),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T14))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
                            bloc.reviewList!.reviewData[idx].answerMember!
                                        .memberUuid !=
                                    dataSaver.profileGet!.memberUuid
                                ? Container()
                                : !dataSaver.nonMember
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (bloc.reviewList!.reviewData[idx]
                                                  .answerMember!.memberUuid ==
                                              dataSaver
                                                  .profileGet!.memberUuid) {
                                            editDialog(
                                                bloc.reviewList!.reviewData[idx]
                                                    .contentText,
                                                bloc.reviewList!.reviewData[idx]
                                                    .classReviewUuid,
                                                nickName: widget.nickName,
                                                answerText: bloc
                                                    .reviewList!
                                                    .reviewData[idx]
                                                    .answerText!,
                                                commentEditCheck: true);
                                          }
                                        },
                                        child: Image.asset(
                                          AppImages.iMore,
                                          width: 18,
                                          height: 18,
                                        ),
                                      )
                                    : Container()
                          ],
                        ),
                        spaceH(20)
                      ],
                    ),
                  )
          ],
        );
      },
      shrinkWrap: true,
      itemCount: bloc.reviewList!.reviewData.length,
    );
  }

  commentTextField() {
    return LayoutBuilder(
      builder: (context, size) {
        final span = TextSpan(
            text: commentController.text,
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14)));
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: size.maxWidth - 36);

        return TextFormField(
            maxLines: null,
            maxLength: 300,
            controller: commentController,
            focusNode: commentFocus,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T14)),
            onChanged: (text) {
              currentLine = tp.computeLineMetrics().length;
              blankCheck(
                  text: text, controller: commentController, multiline: true);
              setState(() {});
            },
            decoration: InputDecoration(
                counterText: '',
                isDense: false,
                isCollapsed: false,
                contentPadding: EdgeInsets.only(left: 12, right: 12),
                hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13)),
                border: InputBorder.none));
      },
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        return Container(
          color: AppColors.white,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                comment = false;
              });
            },
            child: SafeArea(
              child: Stack(
                children: [
                  bloc.reviewList == null || bloc.loading
                      ? Container()
                      : Scaffold(
                          resizeToAvoidBottomInset: true,
                          backgroundColor: AppColors.white,
                          appBar: baseAppBar(
                              context: context,
                              onPressed: () {
                                pop(context);
                              },
                              title: '후기 ${bloc.reviewList!.totalRow}'),
                          body: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              children: [
                                bloc.reviewList!.reviewData.length == 0
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          spaceH(40),
                                          Image.asset(
                                            AppImages.imgEmptyReview,
                                            height: 160,
                                          ),
                                          customText('앗, 아직 후기가 없네요!',
                                              style: TextStyle(
                                                  color: AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T15))),
                                          widget.myClass
                                              ? Container()
                                              : spaceH(20),
                                          widget.myClass
                                              ? Container()
                                              : Center(
                                                  child: RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(children: [
                                                      customTextSpan(
                                                          text:
                                                              '${dataSaver.profileGet!.nickName}님',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .accentLight20,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .REGULAR),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T14))),
                                                      customTextSpan(
                                                          text:
                                                              '이 가장 먼저 수업을 듣고\n우리동네 숨은 보석같은 쌤을 발견해보세요!',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .gray400,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .REGULAR),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T14))),
                                                    ]),
                                                  ),
                                                ),
                                          widget.myClass
                                              ? Container()
                                              : spaceH(20),
                                          widget.myClass
                                              ? Container()
                                              : widget.chatBlock == 0 ||
                                                      widget.chatBlock == 1
                                                  ? Container()
                                                  : Container(
                                                      width: 120,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          amplitudeEvent(
                                                              'chat_consultation',
                                                              {
                                                                'inflow_page':
                                                                    'review_empty',
                                                                'class_name': widget
                                                                    .classDetail!
                                                                    .content
                                                                    .title,
                                                                'cost_min': widget
                                                                    .classDetail!
                                                                    .content
                                                                    .minCost,
                                                                'town_sido': widget
                                                                    .classDetail!
                                                                    .content
                                                                    .areas!
                                                                    .map((e) =>
                                                                        e.sidoName)
                                                                    .toList()
                                                                    .join(','),
                                                                'town_sigungu': widget
                                                                    .classDetail!
                                                                    .content
                                                                    .areas!
                                                                    .map((e) =>
                                                                        e.sigunguName)
                                                                    .toList()
                                                                    .join(','),
                                                                'town_dongeupmyeon': widget
                                                                    .classDetail!
                                                                    .content
                                                                    .areas!
                                                                    .map((e) =>
                                                                        e.eupmyeondongName)
                                                                    .toList()
                                                                    .join(','),
                                                                'costType': widget
                                                                            .classDetail!
                                                                            .content
                                                                            .costType ==
                                                                        'HOUR'
                                                                    ? 0
                                                                    : 1,
                                                                'costSharing': widget
                                                                        .classDetail!
                                                                        .content
                                                                        .shareType ??
                                                                    '',
                                                                'type': 'class',
                                                                'first_free': widget
                                                                            .classDetail!
                                                                            .content
                                                                            .firstFreeFlag ==
                                                                        0
                                                                    ? false
                                                                    : true,
                                                                'group': widget
                                                                            .classDetail!
                                                                            .content
                                                                            .groupFlag ==
                                                                        0
                                                                    ? false
                                                                    : true,
                                                                'group_cost': widget
                                                                            .classDetail!
                                                                            .content
                                                                            .groupFlag ==
                                                                        0
                                                                    ? ''
                                                                    : widget
                                                                        .classDetail!
                                                                        .content
                                                                        .costOfPerson
                                                              });
                                                          if (dataSaver
                                                                  .chatDetailBloc !=
                                                              null) {
                                                            pop(context);
                                                          }
                                                          widget.moveChat!();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            primary:
                                                                AppColors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            side: BorderSide(
                                                                width: 1,
                                                                color: AppColors
                                                                    .primary),
                                                            elevation: 0,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15,
                                                                    bottom:
                                                                        15)),
                                                        child: Center(
                                                          child: customText(
                                                              '채팅하기',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .primaryDark10,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                          TextWeight
                                                                              .MEDIUM),
                                                                  fontSize: fontSizeSet(
                                                                      textSize:
                                                                          TextSize
                                                                              .T14))),
                                                        ),
                                                      ),
                                                    )
                                        ],
                                      )
                                    : Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        bottom: comment
                                            ? ((currentLine > 2)
                                                    ? 110
                                                    : currentLine == 2
                                                        ? 90
                                                        : 70) +
                                                (commentEdit ? 40 : 0)
                                            : 0,
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: Column(
                                            children: [
                                              spaceH(10),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: AppColors
                                                              .primaryLight40)),
                                                  child: Column(
                                                    children: bloc.reviewGrade
                                                                .length ==
                                                            0
                                                        ? []
                                                        : types(),
                                                  ),
                                                ),
                                              ),
                                              spaceH(30),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: review(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                comment
                                    ? Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 12,
                                        child: Column(
                                          children: [
                                            commentEdit
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryLight60,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        spaceW(12),
                                                        customText(
                                                            '\'${editComment.length > 10 ? editComment.substring(0, 10) + '...' : editComment}\'',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .primaryDark10,
                                                                fontWeight: weightSet(
                                                                    textWeight:
                                                                        TextWeight
                                                                            .MEDIUM),
                                                                fontSize: fontSizeSet(
                                                                    textSize:
                                                                        TextSize
                                                                            .T12))),
                                                        customText(' 답변 수정',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .greenGray400,
                                                                fontWeight: weightSet(
                                                                    textWeight:
                                                                        TextWeight
                                                                            .MEDIUM),
                                                                fontSize: fontSizeSet(
                                                                    textSize:
                                                                        TextSize
                                                                            .T12))),
                                                        Expanded(
                                                            child: Container()),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              commentEdit =
                                                                  false;
                                                              comment = false;
                                                              editComment = '';
                                                              commentController
                                                                  .text = '';
                                                              currentLine = 1;
                                                            });
                                                          },
                                                          child: Image.asset(
                                                            AppImages
                                                                .iInputClearTrans,
                                                            width: 18,
                                                            height: 18,
                                                          ),
                                                        ),
                                                        spaceW(12)
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            commentEdit
                                                ? spaceH(10)
                                                : Container(),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .gray200,
                                                                width: 1)),
                                                        height: (currentLine >
                                                                2)
                                                            ? 88
                                                            : currentLine == 2
                                                                ? 68
                                                                : 48,
                                                        child:
                                                            commentTextField())),
                                                spaceW(10),
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      if (!dataSaver
                                                          .nonMember) {
                                                        if (commentController
                                                                .text ==
                                                            '') {
                                                          showToast(
                                                              context: context,
                                                              text:
                                                                  '답글을 입력해주세요',
                                                              toastGravity:
                                                                  ToastGravity
                                                                      .CENTER);
                                                        } else if (commentController
                                                                .text.length <
                                                            5) {
                                                          showToast(
                                                              context: context,
                                                              text:
                                                                  '5글자 이상 입력해주세요',
                                                              toastGravity:
                                                                  ToastGravity
                                                                      .CENTER);
                                                        } else {
                                                          if (commentEdit) {
                                                            amplitudeEvent(
                                                                'review_feedback_edit',
                                                                {
                                                                  'class_uuid':
                                                                      bloc.classUuid,
                                                                  'class_review_uuid':
                                                                      selectClassReviewUuid
                                                                });
                                                          } else {
                                                            amplitudeEvent(
                                                                'review_feedback_completed',
                                                                {
                                                                  'class_uuid':
                                                                      bloc.classUuid,
                                                                  'class_review_uuid':
                                                                      selectClassReviewUuid
                                                                });
                                                          }
                                                          bloc.add(AddCommentEvent(
                                                              text:
                                                                  commentController
                                                                      .text,
                                                              classReviewUuid:
                                                                  selectClassReviewUuid));

                                                          setState(() {
                                                            currentLine = 0;
                                                            commentController
                                                                .text = '';
                                                            comment = false;
                                                          });
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                        }
                                                      } else {
                                                        nonMemberDialog(
                                                            context: context,
                                                            title: '답글달기',
                                                            content:
                                                                '로그인을하면 게시글에\n댓글을 달 수 있어요');
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Image.asset(
                                                        AppImages.iChatSendingW,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            AppColors.primary,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8))),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                  loadingView(bloc.loading)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  editDialog(String contentText, String classReviewUuid,
      {String? nickName,
      bool commentEditCheck = false,
      String answerText = ''}) {
    customDialog(
        context: context,
        barrier: false,
        widget: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 60,
              child: Row(
                children: [
                  spaceW(24),
                  Expanded(
                    child: customText(
                        commentEditCheck ? answerText : contentText,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  spaceW(16),
                  GestureDetector(
                    onTap: () {
                      popDialog(context);
                    },
                    child: Image.asset(
                      AppImages.iX,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  spaceW(20)
                ],
              ),
            ),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  popDialog(context);
                  if (commentEditCheck) {
                    setState(() {
                      comment = true;
                      commentEdit = true;
                      editComment = answerText;
                      selectClassReviewUuid = classReviewUuid;
                    });

                    commentFocus.unfocus();
                    await Future.delayed(Duration(milliseconds: 200));
                    FocusScope.of(context).requestFocus(commentFocus);
                    commentController.text = answerText;
                    return;
                  }
                  pushTransition(
                          context,
                          CreateReviewPage(
                              classUuid: widget.classUuid,
                              classReviewUuid: classReviewUuid,
                              nickName: nickName ?? '',
                              edit: true))
                      .then((value) {
                    if (value != null && value) {
                      bloc.add(ReviewDetailInitEvent(
                          classUuid: widget.classUuid,
                          reviewCount: widget.reviewCount));
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.only(left: 24)),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.iEditUnderG,
                      width: 16,
                      height: 16,
                    ),
                    spaceW(4),
                    customText('수정하기',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))
                  ],
                ),
              ),
            ),
            spaceH(20)
          ],
        ));
  }

  reportDialog(String contentText, String classReviewUuid, bool reported) {
    customDialog(
        context: context,
        barrier: false,
        widget: ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 60,
              child: Row(
                children: [
                  spaceW(24),
                  Expanded(
                    child: customText(contentText,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                        overflow: TextOverflow.ellipsis),
                  ),
                  spaceW(16),
                  GestureDetector(
                    onTap: () {
                      popDialog(context);
                    },
                    child: Image.asset(
                      AppImages.iX,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  spaceW(20)
                ],
              ),
            ),
            Container(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (!dataSaver.nonMember) {
                    if (reported) {
                      popDialog(context);
                    } else {
                      popDialog(context);
                      pushTransition(
                          context,
                          ReviewReportPage(
                            classReviewUuid: classReviewUuid,
                          )).then((value) {
                        if (value != null && value) {
                          bloc.add(ReviewDetailInitEvent(
                              classUuid: widget.classUuid,
                              reviewCount: widget.reviewCount));
                        }
                      });
                    }
                  } else {
                    nonMemberDialog(
                        context: context,
                        title: '신고하기',
                        content: '로그인하면 신고하기 기능을\n사용하실 수 있어요');
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: AppColors.white,
                    elevation: 0,
                    padding: EdgeInsets.only(left: 24)),
                child: Row(
                  children: [
                    Image.asset(
                      reported ? AppImages.iWarningG : AppImages.iWarningCe,
                      width: 16,
                      height: 16,
                    ),
                    spaceW(4),
                    customText(reported ? '신고완료' : '신고하기',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)))
                  ],
                ),
              ),
            ),
            spaceH(20)
          ],
        ));
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }

        if (scrollController!.position.userScrollDirection ==
            ScrollDirection.reverse) {
          bloc.add(NewDataEvent());
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < scrollController!.offset) &&
            scrollController!.offset >=
                scrollController!.position.maxScrollExtent &&
            !scrollController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = scrollController!.offset;
        }
      });
  }

  @override
  void dispose() {
    dataSaver.reviewDetailBloc = null;
    super.dispose();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is ReviewDetailInitState) {
      dataSaver.reviewDetailBloc = bloc;
      setState(() {});
    }
  }

  @override
  ReviewDetailBloc initBloc() {
    return ReviewDetailBloc(context)
      ..add(ReviewDetailInitEvent(
          classUuid: widget.classUuid, reviewCount: widget.reviewCount));
  }
}
