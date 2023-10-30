import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/gather/gather_detail_bloc.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GatherDetailPage extends BlocStatefulWidget {
  final String curationThemeUuid;
  final String title;

  GatherDetailPage({required this.curationThemeUuid, required this.title});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return GatherDetailState();
  }
}

class GatherDetailState extends BlocState<GatherDetailBloc, GatherDetailPage> {
  ScrollController? scrollController;
  int listIdx = 0;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
              color: AppColors.white,
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: AppColors.white,
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: AppColors.white,
                      // automaticallyImplyLeading: false,
                      // leadingWidth: MediaQuery.of(context).size.width,
                      centerTitle: false,
                      leadingWidth: 0,
                      leading: Container(),
                      titleSpacing: 0,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          spaceW(20),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: IconButton(
                              onPressed: () {
                                pop(context);
                              },
                              icon: Image.asset(
                                AppImages.iChevronPrev,
                                width: 24,
                                height: 24,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          spaceW(20),
                          Expanded(
                            child: customText(
                              widget.title,
                              style: TextStyle(
                                  color: AppColors.gray900,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T15)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                    body: SingleChildScrollView(
                        controller: scrollController!,
                        child:
                            // GridView.builder(
                            //   padding: EdgeInsets.only(left: 8, right: 8),
                            //   gridDelegate:
                            //       SliverGridDelegateWithMaxCrossAxisExtent(
                            //           maxCrossAxisExtent: 230,
                            //           crossAxisSpacing: 0,
                            //           mainAxisSpacing: 0,
                            //           mainAxisExtent: 230),
                            //   itemBuilder: (context, idx) {
                            //     return gatherClassItem(
                            //         bloc.themeData!.classData[idx], idx);
                            //   },
                            //   physics: NeverScrollableScrollPhysics(),
                            //   shrinkWrap: true,
                            //   itemCount: bloc.themeData == null
                            //       ? 0
                            //       : bloc.themeData!.classData.length,
                            // )
                            // ListView.builder(
                            //   itemBuilder: (context, idx) {
                            //     return Column(
                            //       children: [
                            //         Container(
                            //           height: 230,
                            //           child: Row(
                            //             children: [
                            //               spaceW(12),
                            //               Expanded(child: gatherClassItem(bloc.themeData!.classData[idx], idx)),
                            //               bloc.themeData!.classData.length % 2 == 0 ? Expanded(child: gatherClassItem(bloc.themeData!.classData[(idx )], idx)) : Container(),
                            //               spaceW(12)
                            //             ],
                            //           ),
                            //         ),
                            //         // spaceH(20)
                            //       ],
                            //     );
                            //   },
                            //   shrinkWrap: true,
                            //   physics: NeverScrollableScrollPhysics(),
                            //   itemCount: bloc.themeData == null
                            //       ? 0
                            //       : bloc.themeData!.classData.length,
                            // )
                            StaggeredGridView.countBuilder(
                          key: Key('grid'),
                          physics: NeverScrollableScrollPhysics(),
                          addAutomaticKeepAlives: false,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          padding: EdgeInsets.only(left: 12, right: 12),
                          itemBuilder: (BuildContext context, int idx) {
                            return gatherClassItem(
                                bloc.themeData!.classData[idx], idx);
                          },
                          itemCount: bloc.themeData == null
                              ? 0
                              : bloc.themeData!.classData.length,
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.count(1, 1.21),
                          mainAxisSpacing: 20,
                        )),
                  ),
                  loadingView(bloc.loading)
                ],
              ));
        });
  }

  gatherClassItem(Class classData, int idx) {
    return Padding(
      key: Key(idx.toString()),
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Container(
        key: Key((idx.toString() + '*').toString()),
        child: GestureDetector(
          onTap: () {
            airbridgeEvent('class_view');
            amplitudeEvent('totals_class_clicks', {
              'themeType': widget.title,
              'townSido': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sidoName,
              'townSigungu': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sigunguName,
              'townDongeupmyeon': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .eupmyeondongName,
              'costMin': classData.content.minCost!,
              'costType': classData.content.costType == 'HOUR' ? 0 : 1,
              'costSharing': classData.content.shareType ?? '',
              'classId': classData.classUuid,
              'className': classData.content.title,
              'userId':
                  dataSaver.nonMember ? null : dataSaver.profileGet!.memberUuid,
              'userName':
                  dataSaver.nonMember ? null : dataSaver.profileGet!.nickName,
              'first_free': classData.content.firstFreeFlag == 0 ? false : true,
              'group': classData.content.groupFlag == 0 ? false : true,
              'group_cost': classData.content.costOfPerson.toString()
            });
            amplitudeEvent('gather_class_clicks', {
              'themeType': widget.title,
              'townSido': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sidoName,
              'townSigungu': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .sigunguName,
              'townDongeupmyeon': dataSaver
                  .neighborHood[dataSaver.neighborHood
                      .indexWhere((element) => element.representativeFlag == 1)]
                  .eupmyeondongName,
              'costMin': classData.content.minCost!,
              'costType': classData.content.costType == 'HOUR' ? 0 : 1,
              'costSharing': classData.content.shareType ?? '',
              'classId': classData.classUuid,
              'className': classData.content.title,
              'userId':
                  dataSaver.nonMember ? null : dataSaver.profileGet!.memberUuid,
              'userName':
                  dataSaver.nonMember ? null : dataSaver.profileGet!.nickName,
              'first_free': classData.content.firstFreeFlag == 0 ? false : true,
              'group': classData.content.groupFlag == 0 ? false : true,
              'group_cost': classData.content.costOfPerson.toString()
            });
            dataSaver.themeType = widget.title;
            ClassDetailPage classDetailPage = ClassDetailPage(
              heroTag: 'listImage${classData.classUuid}',
              classUuid: classData.classUuid,
              mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                  .indexWhere((element) => element.representativeFlag == 1)],
              bloc: bloc,
              profileGet: dataSaver.nonMember ? null : dataSaver.profileGet,
              inputPage: 'gather_class',
            );
            dataSaver.keywordClassDetail = classDetailPage;
            pushTransition(context, classDetailPage);
          },
          child: Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: ((MediaQuery.of(context).size.width / 2) - 28) *
                          0.5625,
                      child: CacheImage(
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        imageUrl: classData.content.image!.toView(context: context, ),
                        placeholder: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: AppColors.gray200,
                              borderRadius: BorderRadius.circular(4)),
                          child: Image.asset(
                            AppImages.dfClassMain,
                            width: MediaQuery.of(context).size.width,
                            height:
                                ((MediaQuery.of(context).size.width / 2) - 28) *
                                    0.5625,
                          ),
                        ),
                      ),
                    )
                    //     CachedNetworkImage(
                    //   imageUrl: classData.content.image!
                    //       .toView(w: MediaQuery.of(context).size.width.toInt()),
                    //   height: ((MediaQuery.of(context).size.width / 2) - 28) *
                    //       0.5625,
                    //   memCacheWidth: MediaQuery.of(context).size.width ~/ 2,
                    //   memCacheHeight:
                    //       (((MediaQuery.of(context).size.width / 2) - 28) *
                    //               0.5625)
                    //           .toInt(),
                    //   placeholder: (context, a) {
                    //     return Container(
                    //       width: MediaQuery.of(context).size.width,
                    //       decoration: BoxDecoration(
                    //           color: AppColors.gray200,
                    //           borderRadius: BorderRadius.circular(4)),
                    //       child: Image.asset(
                    //         AppImages.dfClassMain,
                    //         width: MediaQuery.of(context).size.width,
                    //         height:
                    //             ((MediaQuery.of(context).size.width / 2) - 28) *
                    //                 0.5625,
                    //       ),
                    //     );
                    //   },
                    //   errorWidget: (context, error, _) {
                    //     return Container(
                    //       width: MediaQuery.of(context).size.width,
                    //       decoration: BoxDecoration(
                    //           color: AppColors.gray200,
                    //           borderRadius: BorderRadius.circular(4)),
                    //       child: Image.asset(
                    //         AppImages.dfClassMain,
                    //         width: MediaQuery.of(context).size.width,
                    //         height:
                    //             ((MediaQuery.of(context).size.width / 2) - 28) *
                    //                 0.5625,
                    //       ),
                    //     );
                    //   },
                    //   fit: BoxFit.cover,
                    // )
                    ),
                spaceH(8),
                customText(
                  '${double.parse(classData.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(classData.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(classData.content.distance) / 1000).toStringAsFixed(1)}km'} ${classData.content.hangNames.split(',')[0]}' : '${double.parse(classData.content.distance).toString().split('.')[0].length == 3 ? (double.parse(classData.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(classData.content.distance).toString().split('.')[0]}m ${classData.content.hangNames.split(',')[0]}'}',
                  style: TextStyle(
                      color: AppColors.greenGray500,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T12)),
                  overflow: TextOverflow.ellipsis,
                ),
                spaceH(4),
                customText(classData.content.title!,
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                spaceH(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: classData.member.profile == null
                          ? Image.asset(
                              AppImages.dfProfile,
                              width: 16,
                              height: 16,
                            )
                          : Container(
                              width: 16,
                              height: 16,
                              child: CacheImage(
                                fit: BoxFit.cover,
                                placeholder: Image.asset(
                                  AppImages.dfProfile,
                                  width: 16,
                                  height: 16,
                                ),
                                imageUrl: classData.member.profile!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                    ),
                    spaceW(4),
                    customText(
                        classData.member.nickName.length > 8
                            ? classData.member.nickName.substring(0, 8) + '...'
                            : classData.member.nickName,
                        style: TextStyle(
                            color: AppColors.gray500,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T11)))
                  ],
                ),
                spaceH(16),
                Flexible(
                  child: classData.content.costType == 'HOUR'
                      ? Row(
                          children: [
                            classData.content.groupFlag == 1
                                ? Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        padding:
                                            EdgeInsets.only(left: 6, right: 6),
                                        child: Center(
                                            child: customText('그룹할인',
                                                style: TextStyle(
                                                    color: AppColors.white,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.BOLD),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T10)))),
                                        decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                      spaceW(6)
                                    ],
                                  )
                                : Container(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    customTextSpan(
                                        text:
                                            '${numberFormatter(classData.content.groupFlag == 0 ? classData.content.minCost! : classData.content.costOfPerson)}원 ~',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: classData
                                                            .content.minCost!
                                                            .toString()
                                                            .length >
                                                        7
                                                    ? TextSize.T12
                                                    : TextSize.T14)))
                                  ])),
                            ),
                          ],
                        )
                      : customText('배움나눔',
                          style: TextStyle(
                              color: AppColors.secondaryDark30,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T14))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  blocListener(BuildContext context, state) {}

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

        // if (!bloc.scrollUnder &&
        //     (bloc.bottomOffset == 0 ||
        //         bloc.bottomOffset < scrollController!.offset) &&
        //     scrollController!.offset >=
        //         (scrollController!.position.maxScrollExtent * 0.7) &&
        //     !scrollController!.position.outOfRange) {
        //   bloc.add(NewDataEvent());
        // }
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
    super.dispose();
  }

  @override
  GatherDetailBloc initBloc() {
    return GatherDetailBloc(context)
      ..add(GatherDetailInitEvent(curationThemeUuid: widget.curationThemeUuid));
  }
}
