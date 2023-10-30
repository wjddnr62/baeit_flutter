import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/reword/reword.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/support_fund/support_fund_bloc.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/issue_message.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SupportFundPage extends BlocStatefulWidget {
  final Reward reward;

  SupportFundPage({required this.reward});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return SupportFundState();
  }
}

class SupportFundState extends BlocState<SupportFundBloc, SupportFundPage>
    with TickerProviderStateMixin {
  AnimationController? controller;
  ScrollController scrollController = ScrollController();

  TextEditingController nameController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode bankNameFocus = FocusNode();
  FocusNode bankAccountFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

  bool namePass = true;
  bool bankNamePass = true;
  bool bankAccountPass = true;
  bool phonePass = true;

  personCount() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 20, bottom: 20),
        decoration: BoxDecoration(
            color: AppColors.secondaryLight40,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: AppColors.secondaryLight10)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              customText('현재 남은 인원은 ',
                  style: TextStyle(
                      color: AppColors.secondaryDark30,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T15))),
              customText('${widget.reward.availCnt}명',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T20))),
              customText(' 이에요 :)',
                  style: TextStyle(
                      color: AppColors.secondaryDark30,
                      fontWeight: weightSet(textWeight: TextWeight.BOLD),
                      fontSize: fontSizeSet(textSize: TextSize.T15)))
            ],
          ),
        ),
      ),
    );
  }

  infoInput() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: customText('성함',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15)),
                    textAlign: TextAlign.start),
              )),
          nameInput(),
          spaceH(20),
          Container(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: customText('계좌번호',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15)),
                    textAlign: TextAlign.start),
              )),
          bankAccountInput(),
          spaceH(20),
          Container(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: customText('휴대폰 번호',
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T15)),
                    textAlign: TextAlign.start),
              )),
          phoneInput(),
          spaceH(20),
        ],
      ),
    );
  }

  nameInput() {
    return Column(
      children: [
        Container(
          height: 48,
          child: TextFormField(
              onChanged: (text) {
                namePass = true;
                blankCheck(text: text, controller: nameController);
                setState(() {});
              },
              maxLength: 20,
              maxLines: 1,
              controller: nameController,
              focusNode: nameFocus,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {},
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              decoration: InputDecoration(
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
                          BorderSide(width: 2, color: AppColors.primary)))),
        ),
        namePass ? Container() : issueMessage(title: '받으실분의 성함을 입력해주세요')
      ],
    );
  }

  bankAccountInput() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 40) / 3,
              height: 48,
              child: TextFormField(
                  onChanged: (text) {
                    bankNamePass = true;
                    blankCheck(text: text, controller: bankNameController);
                    setState(() {});
                  },
                  maxLength: 20,
                  maxLines: 1,
                  controller: bankNameController,
                  focusNode: bankNameFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {},
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                  decoration: InputDecoration(
                      suffixIcon: bankNameController.text.length > 0
                          ? Padding(
                              padding: EdgeInsets.only(top: 14, bottom: 14),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    bankNameController.text = '';
                                  });
                                },
                                child: Image.asset(AppImages.iInputClear,
                                    width: 20, height: 20),
                              ),
                            )
                          : null,
                      hintText: '은행명',
                      hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T13)),
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
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
                              BorderSide(width: 2, color: AppColors.primary)))),
            ),
            spaceW(10),
            Expanded(
              child: Container(
                height: 48,
                child: TextFormField(
                    onChanged: (text) {
                      bankAccountPass = true;
                      blankCheck(text: text, controller: bankAccountController);
                      setState(() {});
                    },
                    maxLength: 20,
                    maxLines: 1,
                    controller: bankAccountController,
                    focusNode: bankAccountFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {},
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                        color: AppColors.gray900,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                    decoration: InputDecoration(
                        suffixIcon: bankAccountController.text.length > 0
                            ? Padding(
                                padding: EdgeInsets.only(top: 14, bottom: 14),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      bankAccountController.text = '';
                                    });
                                  },
                                  child: Image.asset(AppImages.iInputClear,
                                      width: 20, height: 20),
                                ),
                              )
                            : null,
                        hintText: '숫자만 입력해주세요',
                        hintStyle: TextStyle(
                            color: AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T13)),
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
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
                            borderSide: BorderSide(
                                width: 2, color: AppColors.primary)))),
              ),
            ),
          ],
        ),
        bankNamePass && bankAccountPass
            ? Container()
            : issueMessage(
                title: !bankNamePass
                    ? '은행명을 입력해주세요'
                    : !bankAccountPass
                        ? '계좌번호를 입력해주세요'
                        : '')
      ],
    );
  }

  phoneInput() {
    return Column(
      children: [
        Container(
          height: 48,
          child: TextFormField(
              onChanged: (text) {
                phonePass = true;
                blankCheck(text: text, controller: phoneController);
                setState(() {});
              },
              maxLength: 11,
              maxLines: 1,
              controller: phoneController,
              focusNode: phoneFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
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
                  hintText: '\'-\'없이 숫자만 입력해주세요',
                  hintStyle: TextStyle(
                      color: AppColors.gray400,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T13)),
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
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
                          BorderSide(width: 2, color: AppColors.primary)))),
        ),
        phonePass ? Container() : issueMessage(title: '휴대폰 번호를 입력해주세요')
      ],
    );
  }

  applicantView() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spaceH(10),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: bottomButton(
                context: context,
                text: '신청하기',
                elevation: 0,
                onPress: bloc.applicantCheck == 0
                    ? () {
                        applicant();
                      }
                    : () {
                        FocusScope.of(context).unfocus();
                        showToast(context: context, text: '이미 신청 완료했습니다');
                      }),
          ),
          spaceH(42),
          CacheImage(
            imageUrl:
            dataSaver.reward!.noticeImages[0].toView(context: context),
            width: MediaQuery.of(context).size.width * 3,
            heightSet: false,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  applicant() {
    if (bloc.applicantCheck == 0) {
      bool move = false;
      setState(() {
        if (nameController.text.length == 0 || nameController.text == '') {
          if (!move) {
            move = true;
            FocusScope.of(context).requestFocus(nameFocus);
          }
          namePass = false;
        }
        if (bankNameController.text.length == 0 ||
            bankNameController.text == '') {
          if (!move) {
            move = true;
            FocusScope.of(context).requestFocus(bankNameFocus);
          }
          bankNamePass = false;
        }
        if (bankAccountController.text.length == 0 ||
            bankAccountController.text == '') {
          if (!move) {
            move = true;
            FocusScope.of(context).requestFocus(bankAccountFocus);
          }
          bankAccountPass = false;
        }
        if (phoneController.text.length == 0 ||
            phoneController.text == '' ||
            phoneController.text.length < 11) {
          if (!move) {
            move = true;
            FocusScope.of(context).requestFocus(phoneFocus);
          }
          phonePass = false;
        }
      });
    }

    if (namePass && bankNamePass && bankAccountPass && phonePass) {
      bloc.add(ApplicantEvent(
          account: bankAccountController.text,
          bank: bankNameController.text,
          name: nameController.text,
          phone: phoneController.text,
          rewardUuid: widget.reward.rewardUuid));
    }
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
            },
            child: Stack(
              children: [
                Scaffold(
                    backgroundColor: AppColors.white,
                    appBar: baseAppBar(
                        title: '배잇생활 지원금 이벤트',
                        close: true,
                        context: context,
                        onPressed: () {
                          pop(context);
                        }),
                    body: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          CacheImage(
                              imageUrl: dataSaver.reward!.contentImages[0]
                                  .toView(context: context),
                              width: MediaQuery.of(context).size.width * 2,
                              heightSet: false,
                              q: 100,
                              fit: BoxFit.cover),
                          spaceH(20),
                          personCount(),
                          spaceH(20),
                          infoInput(),
                          spaceH(10),
                          applicantView()
                        ],
                      ),
                    )),
                loadingView(bloc.loading)
              ],
            ),
          ),
        );
      },
    );
  }

  finishApplicant() {
    return ListView(
      shrinkWrap: true,
      children: [
        spaceH(40),
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
        Column(
          children: [
            Center(
              child: customText('완료되었어요!',
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T17))),
            ),
            spaceH(60),
            Padding(
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: bottomButton(
                  context: context,
                  text: '확인',
                  onPress: () {
                    popDialog(context);
                    pop(context);
                  }),
            )
          ],
        )
      ],
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SupportFundInitState) {
      phoneController.text = dataSaver.profileGet!.phone;
    }

    if (state is ApplicantState) {
      return customDialog(
          context: context, barrier: true, widget: finishApplicant());
    }
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  SupportFundBloc initBloc() {
    return SupportFundBloc(context)
      ..add(SupportFundInitEvent(reward: widget.reward));
  }
}
