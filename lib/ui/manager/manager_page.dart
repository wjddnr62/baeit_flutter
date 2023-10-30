import 'dart:async';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/manager/manager_bloc.dart';
import 'package:baeit/ui/splash/splash_page.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ManagerPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ManagerState();
  }
}

class ManagerState extends BlocState<ManagerBloc, ManagerPage> {
  TextEditingController idController = TextEditingController();
  Timer? idTimer;
  Timer? countTimer;
  int outTime = 8;
  bool outCheck = false;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: Scaffold(
              backgroundColor: AppColors.black.withOpacity(0.6),
              resizeToAvoidBottomInset: true,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Column(
                    children: [
                      spaceH(MediaQuery.of(context).size.height / 3),
                      outCheck && outTime != 0
                          ? customText(outTime.toString(),
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T20)))
                          : Container(),
                      spaceH(12),
                      TextFormField(
                        controller: idController,
                      ),
                      spaceH(16),
                      ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              outCheck = false;
                              if (idTimer != null) {
                                idTimer!.cancel();
                              }
                            });
                            if (idController.text != '') {
                              bloc.add(ManagerLoginEvent(
                                  accessId: idController.text));
                            } else {
                              setState(() {
                                outCheck = true;
                              });
                              if (countTimer != null) {
                                countTimer!.cancel();
                              }
                              outTime = 8;
                              showToast(
                                  context: context,
                                  text: '아이디를 입력해주세요 8초 드립니다',
                                  toastGravity: ToastGravity.CENTER);
                              countTimer = Timer.periodic(
                                  Duration(milliseconds: 1000), (timer) {
                                setState(() {
                                  outTime -= 1;
                                  if (outTime == 6) {
                                    showToast(
                                        context: context,
                                        text: '1초 차감',
                                        toastGravity: ToastGravity.CENTER);
                                    outTime -= 1;
                                  }
                                  if (outTime == 2) {
                                    showToast(
                                        context: context,
                                        text: '1초 더 차감',
                                        toastGravity: ToastGravity.CENTER);
                                    outTime -= 1;
                                  }
                                });
                                if (outTime == 0) {
                                  countTimer!.cancel();
                                }
                              });
                              idTimer = Timer(
                                Duration(milliseconds: 6000),
                                () {
                                  pop(context);
                                },
                              );
                            }
                          },
                          child: Center(
                            child: customText('로그인'),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    if (idTimer != null) {
      idTimer!.cancel();
    }
    if (countTimer != null) {
      countTimer!.cancel();
    }
    super.dispose();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is ManagerLoginState) {
      stompClient.deactivate();
      stompClient.activate();
      pushAndRemoveUntil(context, SplashPage());
    }

    if (state is ManagerLoginFailState) {
      showToast(
          context: context, text: state.msg, toastGravity: ToastGravity.CENTER);
    }
  }

  @override
  ManagerBloc initBloc() {
    return ManagerBloc(context)..add(ManagerInitEvent());
  }
}
