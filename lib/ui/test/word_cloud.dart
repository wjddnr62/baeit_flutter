import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';

class WordCloudTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WordCloudState();
  }
}

class WordCloudState extends State<WordCloudTest> {
  List<Widget> widgets = <Widget>[];

  @override
  void initState() {
    super.initState();

    // for (int i = 0; i < 300; i++) {
    //   widgets.add(Padding(
    //     padding: EdgeInsets.only(
    //         left: i % 2 == 0 ? 5 : 3, right: i % 2 == 0 ? 2 : 4),
    //     child: customText('테스트 $i',
    //         style: i == 50
    //             ? TextStyle(
    //                 color: AppColors.primaryDark10,
    //                 fontWeight: weightSet(textWeight: TextWeight.BOLD),
    //                 fontSize: fontSizeSet(textSize: TextSize.T20))
    //             : TextStyle(
    //                 color: AppColors.gray500,
    //                 fontWeight: weightSet(textWeight: TextWeight.REGULAR),
    //                 fontSize: fontSizeSet(textSize: TextSize.T14)),
    //         textAlign: TextAlign.start),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

            ],
          ),
        ),
      ),
    );
  }
}
