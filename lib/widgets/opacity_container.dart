import 'dart:async';

import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OpacityTextContainer extends StatefulWidget {
  final String text;
  final Color? color;

  OpacityTextContainer({required this.text, this.color});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OpacityTextContainerState();
  }
}

class OpacityTextContainerState extends State<OpacityTextContainer>
    with TickerProviderStateMixin {
  AnimationController? controller;
  late Animation<double> animation;
  late Timer animationTimer;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween(begin: 1.0, end: 0.0).animate(controller!);
    super.initState();
    runAnimation();
  }

  runAnimation() {
    animationTimer = Timer(Duration(milliseconds: 1200), () async {
      await controller!.forward();
      await controller!.reverse();
      await controller!.forward();
      await controller!.reverse();
    });
  }

  @override
  void dispose() {
    animationTimer.cancel();
    if (controller!.isAnimating) {
      controller!.stop();
    }
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 24,
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          color: widget.color == null
              ? AppColors.error.withOpacity(0.8)
              : widget.color,
          borderRadius: BorderRadius.circular(16.5)),
      child: Center(
        child: FadeTransition(
          opacity: animation,
          child: customText(
            widget.text,
            style: TextStyle(
                color: AppColors.white,
                fontSize: fontSizeSet(textSize: TextSize.T11),
                fontWeight: weightSet(textWeight: TextWeight.BOLD)),
          ),
        ),
      ),
    );
  }
}
