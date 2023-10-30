import 'package:baeit/config/common.dart';
import 'package:baeit/data/chat/chat_room.dart';
import 'package:baeit/data/class/class.dart' as cl;
import 'package:baeit/data/keyword/keyword.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';
import 'package:baeit/data/profile/amplitude.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/reword/reword.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/ui/chat/chat_bloc.dart';
import 'package:baeit/ui/chat/chat_detail_bloc.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_bloc.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/main_navigation/main_navigation_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/my_create_community/my_create_community_bloc.dart';
import 'package:baeit/ui/neighborhood_class/neighborhood_class_bloc.dart';
import 'package:baeit/ui/profile/profile_dialog_bloc.dart';
import 'package:baeit/ui/review/review_detail_bloc.dart';
import 'package:baeit/ui/search/search_bloc.dart';
import 'package:baeit/ui/splash/splash_bloc.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DataSaver {
  static final DataSaver _instance = DataSaver._internal();

  ProfileGet? profileGet;
  cl.ClassList? neighborHoodClass;
  cl.ClassList? requestClass;

  late List<cl.Category> category;
  late List<NeighborHood> neighborHood;
  late String nickName;
  NeighborHoodClassBloc? classBloc;
  MainNavigationBloc? mainNavigationBloc;
  MainBloc? mainBloc;
  ChatBloc? chatBloc;
  ChatDetailBloc? chatDetailBloc;
  LearnBloc? learnBloc;
  GatherBloc? gatherBloc;
  ProfileDialogBloc? profileDialogBloc;
  List<bool>? classFilterValues;
  int? sliderSelectValue;
  bool nonMember = false;
  int order = 0;
  String searchText = '';
  bool keyword = false;
  bool notificationInit = false;
  bool connectStomp = false;
  bool subscribeChat = false;
  ChatRoom? chatRoom;
  dynamic unsubscribe;
  String? chatRoomUuid;
  double iosBottom = 0;
  double statusTop = 0;
  bool sessionStartCheck = false;
  dynamic readSubscribe;
  dynamic chatSubscribe;
  UserData? userData;
  double mainScrollOffset = 0;
  SplashBloc? splashBloc;
  String? abTest;
  bool feedbackBanner = false;
  bool share = false;
  Keyword? classKeywordNotification;
  SearchBloc? searchBloc;
  VoidCallback? filterOpen;
  VoidCallback? dayOpen;
  ClassDetailPage? keywordClassDetail;
  int? keywordViewIndex;
  Widget? keywordViewWidget;
  MyBaeitBloc? myBaeitBloc;
  bool forceUpdate = false;
  bool updatePass = false;
  String lastNextCursor = '';
  PackageInfo? packageInfo;
  Amplitude? amplitudeUserData;
  String? themeType;
  bool bannerMoveEnable = false;
  MyCreateCommunityBloc? myCreateCommunityBloc;
  bool logout = false;
  CommunityDetailBloc? communityDetailBloc;
  int alarmCount = 0;
  bool touring = true;
  BuildContext? chatDetailContext;
  ReviewDetailBloc? reviewDetailBloc;
  Reward? reward;

  factory DataSaver() {
    return _instance;
  }

  DataSaver._internal() {
    category = [];
    neighborHood = [];
  }

  clear() {
    bool saveFeedbackBanner = feedbackBanner;
    category = [];
    neighborHood = [];
    nickName = '';
    classBloc = null;
    mainNavigationBloc = null;
    mainBloc = null;
    chatBloc = null;
    chatDetailBloc = null;
    profileDialogBloc = null;
    classFilterValues = null;
    sliderSelectValue = null;
    order = 0;
    searchText = '';
    keyword = false;
    chatRoom = null;
    subscribeChat = false;
    unsubscribe = null;
    chatRoomUuid = null;
    readSubscribe = null;
    chatSubscribe = null;
    profileGet = null;
    neighborHoodClass = null;
    requestClass = null;
    userData = null;
    mainScrollOffset = 0;
    splashBloc = null;
    feedbackBanner = saveFeedbackBanner;
    share = false;
    learnBloc = null;
    classKeywordNotification = null;
    searchBloc = null;
    filterOpen = null;
    dayOpen = null;
    keywordClassDetail = null;
    keywordViewIndex = null;
    keywordViewWidget = null;
    myBaeitBloc = null;
    lastNextCursor = '';
    amplitudeUserData = null;
    gatherBloc = null;
    themeType = null;
    myCreateCommunityBloc = null;
    alarmCount = 0;
    chatDetailContext = null;
    reviewDetailBloc = null;
    reward = null;
  }
}

final dataSaver = DataSaver();

sharedClear() async {
  bool iosNotification = prefs!.getBool("iosNotification") ?? false;
  bool permission = prefs!.getBool('permission') ?? false;
  String installDate =
      prefs!.getString("installDate") ?? DateTime.now().yearMonthDay;
  String forceUpdateCheck = prefs!.getString('forceUpdateData') ?? '';
  List<String>? chatEvent = prefs!.getStringList('chatEvent');
  bool keyword = prefs!.getBool('keyword') ?? false;
  bool communityFirstIn = prefs!.getBool('communityFirstIn') ?? true;
  await prefs!.clear();

  await prefs!.setBool('iosNotification', iosNotification);
  await prefs!.setBool('permission', permission);
  await prefs!.setString('installDate', installDate);
  await prefs!.setString('forceUpdateData', forceUpdateCheck);
  await prefs!.setBool('keyword', keyword);
  if (chatEvent != null) {
    await prefs!.setStringList('chatEvent', chatEvent);
  }
  await prefs!.setBool('communityFirstIn', communityFirstIn);
}
