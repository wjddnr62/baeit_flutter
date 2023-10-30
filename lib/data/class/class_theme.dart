import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:flutter/cupertino.dart';

class ClassTheme {
  final String curationThemeUuid;
  final String status;
  final String title;
  final int seq;
  final DateTime createDate;
  final DateTime updateDate;
  final List<Class> classList;
  final Data image;
  final bool hide;

  ClassTheme(
      {required this.curationThemeUuid,
      required this.status,
      required this.title,
      required this.seq,
      required this.createDate,
      required this.updateDate,
      required this.classList,
      required this.image,
      this.hide = false});

  factory ClassTheme.fromJson(data) {
    return ClassTheme(
        curationThemeUuid: data['curationThemeUuid'],
        status: data[' status'],
        title: data['title'],
        seq: data['seq'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: DateTime.parse(data['updateDate']),
        classList: data['list'] != null || data['list'].length == 0
            ? (data['list'] as List).map((e) => Class.fromJson(e)).toList()
            : [],
        image: Data.fromJson(data['image']));
  }
}
