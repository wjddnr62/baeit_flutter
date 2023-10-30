import 'dart:io';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageMultipleUploadService {
  late List<File> imageFiles;
  bool image;

  ImageMultipleUploadService({required this.imageFiles, this.image = true});

  Future<List<Data>> start() async {
    var client = http.Client();
    Uri uri = Uri.parse(baseUrl + "common/files");
    List<Data> subImages = [];

    try {
      List<http.MultipartFile> files = [];
      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      for (int i = 0; i < imageFiles.length; i++) {
        if (image) {
          files.add(await http.MultipartFile.fromPath(
              'files', imageFiles[i].path,
              contentType: contentType(imageFiles[i].path.substring(
                  imageFiles[i].path.length - 3, imageFiles[i].path.length).toLowerCase())));
        } else {
          files.add(await http.MultipartFile.fromPath(
            'files',
            imageFiles[i].path,
          ));
        }
      }

      request.files.addAll(files);

      var response = await request.send();

      await response.stream.bytesToString().then((value) {
        if (response.statusCode == 200) {
          ReturnData returnRes = ReturnData.fromJson(jsonDecode(value));
          for (int i = 0; i < returnRes.data.length; i++) {
            subImages.add(Data.fromJson(returnRes.data[i]));
          }
        }
      });
    } on PlatformException catch (e) {
      print("FILE UPLOAD ERROR : ${e.message}");
    } finally {
      client.close();
    }
    return subImages;
  }

  contentType(type) {
    switch (type) {
      case 'jpg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
    }
  }
}
