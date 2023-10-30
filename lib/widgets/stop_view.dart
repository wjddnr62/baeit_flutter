import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailStop extends StatefulWidget {
  final String whyRemove;
  final BuildContext context;
  final VoidCallback editPress;

  DetailStop(
      {this.whyRemove = '', required this.context, required this.editPress});

  @override
  State<StatefulWidget> createState() {
    return DetailStopState();
  }
}

class DetailStopState extends State<DetailStop> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.black.withOpacity(0.6),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            (MediaQuery.of(context).padding.top +
                MediaQuery.of(context).padding.bottom),
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '관리자에서 운영정지\n하였습니다',
                style: TextStyle(
                    color: AppColors.white,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T20)),
              ),
              spaceH(30),
              Text(
                '정지사유',
                style: TextStyle(
                    color: AppColors.gray300,
                    fontSize: fontSizeSet(textSize: TextSize.T12),
                    fontWeight: weightSet(textWeight: TextWeight.BOLD)),
              ),
              spaceH(4),
              Text(
                widget.whyRemove,
                style: TextStyle(
                    color: AppColors.gray300,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
              ),
              spaceH(30),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          pop(widget.context);
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: AppColors.gray900,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: Center(
                          child: Text(
                            '목록으로',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaceW(10),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: widget.editPress,
                          style: ElevatedButton.styleFrom(
                              primary: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: Center(
                            child: Text(
                              '수정하기',
                              style: TextStyle(
                                  color: AppColors.gray900,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T12)),
                            ),
                          ),
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class ListStop extends StatefulWidget {
  final String whyRemove;
  final VoidCallback editPress;

  ListStop({this.whyRemove = '', required this.editPress});

  @override
  State<StatefulWidget> createState() {
    return ListStopState();
  }
}

class ListStopState extends State<ListStop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.black.withOpacity(0.6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              customText(
                '관리자에서 운영정지\n처리하였습니다',
                style: TextStyle(
                    color: AppColors.white,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T16)),
              ),
              Expanded(child: Container()),
              Container(
                height: 42,
                child: ElevatedButton(
                  onPressed: widget.editPress,
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.gray900,
                      elevation: 0,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFF9e9e9e)))),
                  child: Center(
                    child: customText(
                      '수정하기',
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: weightSet(textWeight: TextWeight.BOLD),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
                  ),
                ),
              )
            ],
          ),
          // Expanded(child: Container()),
          // customText('정지사유',
          //     style: TextStyle(
          //         color: AppColors.gray300,
          //         fontWeight: weightSet(textWeight: TextWeight.BOLD),
          //         fontSize: fontSizeSet(textSize: TextSize.T11))),
          // spaceH(4),
          // customText(widget.whyRemove,
          //     style: TextStyle(
          //         overflow: widget.whyRemove.length > 100
          //             ? TextOverflow.ellipsis
          //             : null,
          //         color: AppColors.gray300,
          //         fontWeight: weightSet(textWeight: TextWeight.REGULAR),
          //         fontSize: fontSizeSet(textSize: TextSize.T11)))
        ],
      ),
    );
  }
}
