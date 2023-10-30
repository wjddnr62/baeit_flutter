import 'package:baeit/data/profile/goal.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/service/get_amplitude_service.dart';
import 'package:baeit/data/profile/service/get_goal_keyword_service.dart';
import 'package:baeit/data/profile/service/get_profile_other_service.dart';
import 'package:baeit/data/profile/service/profile_get_service.dart';
import 'package:baeit/data/profile/service/profile_update_service.dart';
import 'package:baeit/data/profile/service/set_goal_service.dart';

class ProfileRepository {
  static Future<dynamic> getProfile() => ProfileGetService().start();

  static Future<dynamic> updateProfile(Profile profile) =>
      ProfileUpdateService(profile: profile).start();

  static Future<dynamic> getAmplitude() => GetAmplitudeService().start();

  static Future<dynamic> setGoal(Goal goal) =>
      SetGoalService(goal: goal).start();

  static Future<dynamic> getProfileOther({required String memberUuid}) =>
      GetProfileOtherService(memberUuid: memberUuid).start();

  static Future<dynamic> getGoalKeyword({String? type, String? cursor}) =>
      GetGoalKeywordService(type: type, cursor: cursor).start();
}
