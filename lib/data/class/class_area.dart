import 'class.dart';

class ClassArea {
  final String classUuid;
  final String title;
  final String classCategoryId;
  final List<Areas>? areas;

  ClassArea(
      {required this.classUuid, required this.title, required this.classCategoryId, required this.areas});

  factory ClassArea.fromJson(data) {
    return ClassArea(
        classUuid: data['classUuid'],
        title: data['title'],
        classCategoryId: data['classCategoryId'],
        areas: data['areas'] == null
            ? null
            : (data['areas'] as List).map((e) => Areas.fromJson(e)).toList());
  }
}
