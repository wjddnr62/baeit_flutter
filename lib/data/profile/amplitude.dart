class Amplitude {
  final String? gender;
  final int? age;
  final String? ageGroup;
  final String signupYear;
  final String signupMonth;
  final String signupWeek;
  final String signupDay;
  final String signupDate;
  final String town1;
  final String town2;
  final String town3;
  final String townRecent;
  final String townSido1;
  final String townSido2;
  final String townSido3;
  final String townSidoRecent;
  final String townSigungu1;
  final String townSigungu2;
  final String townSigungu3;
  final String townSigunguRecent;
  final bool chatTeacherWho;
  final bool chatStudentsWho;
  final bool registerTeacherWho;
  final bool registerStudentsWho;
  final int totalClass;
  final int totalRequest;
  final int totalWish;
  final String registeredCategoryClass;
  final String registeredCategoryRequest;
  final String chatCategoryClass;
  final String chatCategoryRequest;
  final String lastLoginDate;
  final String lastLoginTime;
  final int loginCount;
  final bool pushMarketingAllowed;
  final bool pushChatAllowed;
  final bool pushDistrubAllowed;
  final int classStatusIng;
  final int classStatusPause;
  final int classStatusTemporary;
  final int requestStatusIng;
  final int requestStatusPause;
  final int requestStatusTemporary;
  final int userChatClassStartCount;
  final int userChatRequestStartCount;
  final String nickName;
  final String phone;
  final String? email;
  final String? ssamType;
  final String? studentType;
  final bool classKeyword;
  final String? type;
  final int reviewRegisterStudent;

  Amplitude(
      {required this.gender,
      required this.age,
      required this.ageGroup,
      required this.signupYear,
      required this.signupMonth,
      required this.signupWeek,
      required this.signupDay,
      required this.signupDate,
      required this.town1,
      required this.town2,
      required this.town3,
      required this.townRecent,
      required this.townSido1,
      required this.townSido2,
      required this.townSido3,
      required this.townSidoRecent,
      required this.townSigungu1,
      required this.townSigungu2,
      required this.townSigungu3,
      required this.townSigunguRecent,
      required this.chatTeacherWho,
      required this.chatStudentsWho,
      required this.registerTeacherWho,
      required this.registerStudentsWho,
      required this.totalClass,
      required this.totalRequest,
      required this.totalWish,
      required this.registeredCategoryClass,
      required this.registeredCategoryRequest,
      required this.chatCategoryClass,
      required this.chatCategoryRequest,
      required this.lastLoginDate,
      required this.lastLoginTime,
      required this.loginCount,
      required this.pushMarketingAllowed,
      required this.pushChatAllowed,
      required this.pushDistrubAllowed,
      required this.classStatusIng,
      required this.classStatusPause,
      required this.classStatusTemporary,
      required this.requestStatusIng,
      required this.requestStatusPause,
      required this.requestStatusTemporary,
      required this.userChatClassStartCount,
      required this.userChatRequestStartCount,
      required this.nickName,
      required this.phone,
      this.email,
      this.studentType = '',
      this.ssamType = '',
      required this.classKeyword,
      required this.requestKeyword,
      this.type,
      required this.reviewRegisterStudent});

  final bool requestKeyword;

  factory Amplitude.fromJson(data) {
    return Amplitude(
        gender: data['gender'] != null ? data['gender'] : null,
        age: data['age'] != null ? data['age'] : null,
        ageGroup: data['age_group'] != null ? data['age_group'] : null,
        signupYear: data['signup_year'],
        signupMonth: data['signup_month'],
        signupWeek: data['signup_week'],
        signupDay: data['signup_day'],
        signupDate: data['signup_date'],
        town1: data['town_1'],
        town2: data['town_2'],
        town3: data['town_3'],
        townRecent: data['town_recent'],
        townSido1: data['town_sido_1'],
        townSido2: data['town_sido_2'],
        townSido3: data['town_sido_3'],
        townSidoRecent: data['town_sido_recent'],
        townSigungu1: data['town_sigungu_1'],
        townSigungu2: data['town_sigungu_2'],
        townSigungu3: data['town_sigungu_3'],
        townSigunguRecent: data['town_sigungu_recent'],
        chatTeacherWho: data['chat_teacher_who'],
        chatStudentsWho: data['chat_students_who'],
        registerTeacherWho: data['register_teacher_who'],
        registerStudentsWho: data['register_students_who'],
        totalClass: data['total_class'],
        totalRequest: data['total_request'],
        totalWish: data['total_wish'],
        registeredCategoryClass: data['registered_category__class'],
        registeredCategoryRequest: data['registered_category__request'],
        chatCategoryClass: data['chat_category_class'],
        chatCategoryRequest: data['chat_category_request'],
        lastLoginDate: data['last_login_date'],
        lastLoginTime: data['last_login_time'],
        loginCount: data['login_count'],
        pushMarketingAllowed: data['push_marketing_allowed'],
        pushChatAllowed: data['push_chat_allowed'],
        pushDistrubAllowed: data['push_distrub_allowed'],
        classStatusIng: data['class_status_ing'],
        classStatusPause: data['class_status_pause'],
        classStatusTemporary: data['class_status_temporary'],
        requestStatusIng: data['request_status_ing'],
        requestStatusPause: data['request_status_pause'],
        requestStatusTemporary: data['request_status_temporary'],
        userChatClassStartCount: data['user_chat_class_start_count'],
        userChatRequestStartCount: data['user_chat_request_start_count'],
        nickName: data['nick_name'],
        phone: data['phone'],
        email: data['email'] != null ? data['email'] : data['email'],
        studentType: data['user_student_type'],
        ssamType: data['user_ssam_type'],
        classKeyword: data['class_keyword'],
        requestKeyword: data['request_keyword'],
        type: data['type'],
        reviewRegisterStudent: data['review_register_student']);
  }

  toMap() {
    Map<String, dynamic> data = {};
    if (gender != null) {
      data.addAll({'gender': gender});
    }
    if (age != null) {
      data.addAll({'age': age});
    }
    if (ageGroup != null) {
      data.addAll({'age_group': ageGroup});
    }
    data.addAll({'signup_year': signupYear});
    data.addAll({'signup_month': signupMonth});
    data.addAll({'signup_week': signupWeek});
    data.addAll({'signup_date': signupDate});
    data.addAll({'signup_day': signupDay});
    data.addAll({'signup_date': signupDate});
    data.addAll({'town_1': town1});
    data.addAll({'town_2': town2});
    data.addAll({'town_3': town3});
    data.addAll({'town_recent': townRecent});
    data.addAll({'town_sido_1': townSido1});
    data.addAll({'town_sido_1': townSido2});
    data.addAll({'town_sido_1': townSido3});
    data.addAll({'town_sido_recent': townSidoRecent});
    data.addAll({'town_sigungu_1': townSigungu1});
    data.addAll({'town_sigungu_2': townSigungu2});
    data.addAll({'town_sigungu_3': townSigungu3});
    data.addAll({'town_sigungu_recent': townSigunguRecent});
    data.addAll({'chat_teacher_who': chatTeacherWho});
    data.addAll({'register_teacher_who': registerTeacherWho});
    data.addAll({'chat_students_who': chatStudentsWho});
    data.addAll({'register_students_who': registerStudentsWho});
    data.addAll({'total_class': totalClass});
    data.addAll({'total_request': totalRequest});
    data.addAll({'total_wish': totalWish});
    data.addAll({'registered_category_class': registeredCategoryClass});
    data.addAll({'registered_category_request': registeredCategoryRequest});
    data.addAll({'last_login_date': lastLoginDate});
    data.addAll({'last_login_time': lastLoginTime});
    data.addAll({'login_count': loginCount});
    data.addAll({'push_marketing_allowed': pushMarketingAllowed});
    data.addAll({'push_chat_allowed': pushChatAllowed});
    data.addAll({'push_distrub_allowed': pushDistrubAllowed});
    data.addAll({'user_chat_class_start_count': userChatClassStartCount});
    data.addAll({'user_chat_request_start_count': userChatRequestStartCount});
    data.addAll({'nick_name': nickName});
    data.addAll({'phone': phone});
    if (email != null) {
      data.addAll({'email': email});
    }
    data.addAll({'student_type': studentType});
    data.addAll({'ssam_type': ssamType});
    data.addAll({'push_keyword_class': classKeyword});
    data.addAll({'push_keyword_request': requestKeyword});
    data.addAll({'type': type});
    data.addAll({'review_register_student': reviewRegisterStudent});
    return data;
  }
}
