import 'package:baeit/data/survey/service/get_survey_detail_service.dart';
import 'package:baeit/data/survey/service/registration_survey_service.dart';

class SurveyRepository {
  static Future<dynamic> getSurveyDetail() => GetSurveyDetailService().start();

  static Future<dynamic> registrationSurvey(String surveyUuid) =>
      RegistrationSurveyService(surveyUuid: surveyUuid).start();
}
