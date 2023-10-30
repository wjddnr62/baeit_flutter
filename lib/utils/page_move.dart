import 'dart:io';

import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Future<dynamic> push(BuildContext context, Widget widget) async {
  return await Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => widget));
}

Future<dynamic> pushTransition(BuildContext context, Widget widget) async {
  if (Platform.isIOS) {
    return Navigator.of(context).push(IosPageMove(widget: widget));
  }
  return await Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      reverseTransitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: widget,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      }));
}

Future<dynamic> pushAndRemoveUntilTransition(
    BuildContext context, Widget widget, {bool fade = true}) async {
  if (Platform.isIOS) {
    return Navigator.of(context)
        .pushAndRemoveUntil(IosPageMove(widget: widget), (route) => false);
  }
  return await Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
          transitionDuration: Duration(milliseconds: fade ? 200 : 0),
          reverseTransitionDuration: Duration(milliseconds: fade ? 200 : 0),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: widget,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          }),
      (route) => false);
}

class IosPageMove extends CupertinoPageRoute {
  final Widget widget;

  IosPageMove({required this.widget}) : super(builder: (context) => widget);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return widget;
  }
}

pushReplacement(BuildContext context, Widget widget) async {
  await Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => widget));
}

pushAndRemoveUntil(BuildContext context, Widget widget) async {
  await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget), (route) => false);
}

pop(BuildContext context) {
  Navigator.of(context).pop();
}

popDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

popWithResult(BuildContext context, result) {
  Navigator.of(context).pop(result);
}

popUntil(BuildContext context) {
  Navigator.of(context).popUntil((route) => true);
}

popUntilSearch(BuildContext context, int index) {
  dataSaver.mainBloc!.add(MenuChangeEvent(select: index));
  Navigator.of(context).popUntil((route) => route.isFirst);
}
