import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<String> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load(path);
  final Directory directory = await getTemporaryDirectory();
  final String filePath = '${directory.path}/$path';
  try {
    final File file = File(filePath);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    await file.create(recursive: true);
  } on PlatformException catch (e) {
    debugPrint("assetImageFile Error : $e");
  }

  return filePath;
}

Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<Map<String, dynamic>> imageResize(
    String url, int width, int height, int idx) async {
  http.Response response = await http.get(Uri.parse(url));
  Uint8List original = response.bodyBytes;

  // print("Reponse : ${response.bodyBytes.toString()}");

  ui.Image originalUiImage = await decodeImageFromList(original);
  ByteData? originalByteData = await originalUiImage.toByteData();

  var codec = await ui.instantiateImageCodec(original,
      targetWidth: width * 2, targetHeight: height * 2);
  var frameInfo = await codec.getNextFrame();
  ui.Image targetUiImage = frameInfo.image;

  ByteData? resizeByteData =
      await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
  Map<String, dynamic> data = {};
  data.addAll({'resize': resizeByteData!.buffer.asUint8List()});
  data.addAll({'index': idx});

  return data;
}
