import 'dart:io';

import 'package:baeit/config/config.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  late File imageFile;

  ImageUploadService({required this.imageFile});

  Future<String> start() async {
    late String returnValue;
    var client = http.Client();
    Uri uri = Uri.parse(baseUrl + "common/file");

    try {
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      if (imageFile.path
              .substring(imageFile.path.length - 3, imageFile.path.length) ==
          'jpg') {
        request.files.add(await http.MultipartFile.fromPath(
            'file', imageFile.path,
            contentType: MediaType('image', 'jpeg')));
      } else if (imageFile.path
              .substring(imageFile.path.length - 3, imageFile.path.length) ==
          'png') {
        request.files.add(await http.MultipartFile.fromPath(
            'file', imageFile.path,
            contentType: MediaType('image', 'png')));
      } else if (imageFile.path
              .substring(imageFile.path.length - 3, imageFile.path.length) ==
          'heic') {
        request.files.add(await http.MultipartFile.fromPath(
            'file', imageFile.path,
            contentType: MediaType('image', 'heic')));
      } else if (imageFile.path
              .substring(imageFile.path.length - 3, imageFile.path.length) ==
          'heif') {
        request.files.add(await http.MultipartFile.fromPath(
            'file', imageFile.path,
            contentType: MediaType('image', 'heif')));
      }

      var response = await request.send();

      await response.stream.bytesToString().then((value) {
        if (response.statusCode == 200) {
          returnValue = value;
        } else {
          returnValue = '';
        }
      });
    } on PlatformException catch (e) {
      print("FILE UPLOAD ERROR : ${e.message}");
    } finally {
      client.close();
    }
    return returnValue;
  }
}
