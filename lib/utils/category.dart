import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';

categorySet(categorySet) {
  switch (categorySet) {
    case 'CAREER':
      return AppStrings.of(StringKey.career);
    case 'HOBBY':
      return AppStrings.of(StringKey.hobby);
    case 'HOME_BASED':
      return AppStrings.of(StringKey.homeBaseSideJob);
    case 'HEALTH':
      return AppStrings.of(StringKey.healthSports);
    case 'LANGUAGE':
      return AppStrings.of(StringKey.language);
    case 'CERTIFICATE':
      return AppStrings.of(StringKey.certificateExamination);
    case 'LESSON':
      return AppStrings.of(StringKey.privateLesson);
    case 'LIFE':
      return AppStrings.of(StringKey.life);
    case 'ETC':
      return AppStrings.of(StringKey.etc);
  }
}

categoryImage(categorySet) {
  switch (categorySet) {
    case 'CAREER':
      return AppImages.iCategoryCpCareer;
    case 'HOBBY':
      return AppImages.iCategoryCpHobby;
    case 'HOME_BASED':
      return AppImages.iCategoryCpNJob;
    case 'HEALTH':
      return AppImages.iCategoryCpSports;
    case 'LANGUAGE':
      return AppImages.iCategoryCpLanguage;
    case 'CERTIFICATE':
      return AppImages.iCategoryCpTest;
    case 'LESSON':
      return AppImages.iCategoryCpLesson;
    case 'LIFE':
      return AppImages.iCategoryCpLife;
    case 'ETC':
      return AppImages.iCategoryCpEtc;
  }
}

categoryBackground(categorySet) {
  switch (categorySet) {
    case 'CAREER':
      return AppImages.bgRequestDetailCareer;
    case 'HOBBY':
      return AppImages.bgRequestDetailHobby;
    case 'HOME_BASED':
      return AppImages.bgRequestDetailNJob;
    case 'HEALTH':
      return AppImages.bgRequestDetailSports;
    case 'LANGUAGE':
      return AppImages.bgRequestDetailLanguage;
    case 'CERTIFICATE':
      return AppImages.bgRequestDetailTest;
    case 'LESSON':
      return AppImages.bgRequestDetailLesson;
    case 'LIFE':
      return AppImages.bgRequestDetailLife;
    case 'ETC':
      return AppImages.bgRequestDetailEtc;
  }
}
