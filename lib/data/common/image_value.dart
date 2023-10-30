import 'package:flutter/material.dart';

class ImageValue {
  final int code;
  final String message;
  final Data data;

  ImageValue({required this.code, required this.message, required this.data});

  factory ImageValue.fromJson(data) {
    return ImageValue(
        code: data['code'], message: data['message'], data: data['data']);
  }
}

class Data {
  String? prefixUrl;
  final String path;
  final String storedName;
  final String originName;
  final String contentType;
  final int size;
  final int? representativeFlag;

  Data(
      {required this.prefixUrl,
      required this.path,
      required this.storedName,
      required this.originName,
      required this.contentType,
      required this.size,
      this.representativeFlag});

  factory Data.fromJson(data) {
    return Data(
        prefixUrl: data['prefixUrl'] ?? '',
        path: data['path'],
        storedName: data['storedName'],
        originName: data['originName'],
        contentType: data['contentType'],
        size: data['size'],
        representativeFlag: data['representativeFlag'] != null
            ? data['representativeFlag']
            : null);
  }

  toMap() {
    Map<String, Object> data = {};
    data.addAll({'prefixUrl': prefixUrl!});
    data.addAll({'path': path});
    data.addAll({'storedName': storedName});
    data.addAll({'originName': originName});
    data.addAll({'contentType': contentType});
    data.addAll({'size': size});
    return data;
  }

  toDecode() {
    return {
      'prefixUrl': prefixUrl,
      'path': path,
      'storedName': storedName,
      'originName': originName,
      'contentType': contentType,
      'size': size
    };
  }

  toView({int? w, int q = 100, bool image = true, required BuildContext context}) {
    if (storedName.contains('MOV')) {
      return '$prefixUrl/$path/$storedName';
    }

    if (storedName.contains('HEIC')) {
      return '$prefixUrl/$path/$storedName';
    }

    if (image) {
      return '$prefixUrl/$path/$storedName?w=500&f=webp';
    } else if (!image) {
      return '$prefixUrl/$path/$storedName';
    } else if (w != null) {
      return '$prefixUrl/$path/$storedName?w=500&f=webp';
    } else {
      return '$prefixUrl/$path/$storedName?w=500&f=webp';
    }
  }
}
