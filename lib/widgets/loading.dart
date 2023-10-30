import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  AnimationController? loadingController;

  @override
  void initState() {
    super.initState();
    loadingController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    loadingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Center(
        child: ClipOval(
          child: Container(
            width: 80,
            height: 80,
            color: AppColors.white.withOpacity(0.8),
            child: Center(
              child: Lottie.asset(AppImages.loadingAnimation,
                  controller: loadingController, onLoaded: (composition) {
                setState(() {
                  loadingController!..duration = composition.duration;
                  loadingController!.repeat();
                });
              }),
            ),
          ),
        ),
      ),
    );
  }
}

loadingView(bool isLoading) {
  if (!isLoading) return Container();

  return Loading();
}
