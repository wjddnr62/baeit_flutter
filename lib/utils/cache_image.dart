import 'dart:typed_data';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CacheImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double width;
  final double? height;
  final Widget? placeholder;
  final int? q;
  final bool heightSet;

  const CacheImage({
    required this.imageUrl,
    required this.fit,
    required this.width,
    this.height,
    this.placeholder,
    this.q,
    this.heightSet = true,
    Key? key,
  }) : super(key: key);

  @override
  CacheImageState createState() => CacheImageState();
}

Uint8List convertStringToUint8List(String str) {
  final List<int> codeUnits = str.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  return unit8List;
}

class CacheImageData {
  final String imageUrl;
  final Uint8List imageMemory;

  CacheImageData({required this.imageUrl, required this.imageMemory});

  factory CacheImageData.fromJson(data) {
    return CacheImageData(
        imageUrl: data['imageUrl'],
        imageMemory: convertStringToUint8List(data['imageMemory']));
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'imageUrl': imageUrl});
    data.addAll({'imageMemory': String.fromCharCodes(imageMemory)});
    return data;
  }
}

class CacheImageState extends State<CacheImage> {
  var _isLoading = false;
  var _hasError = false;

  Uint8List? _image;

  Uint8List get image => _image!;

  bool get showPlaceholder => _hasError || _isLoading || _image == null;

  @override
  void initState() {
    super.initState();
    // _getImage();
  }

  @override
  void didUpdateWidget(CacheImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.imageUrl != widget.imageUrl) {
    //   _getImage();
    // }
  }

  Future _getImage() async {
    final originalUrl = widget.imageUrl;
    final widgetWidth = widget.width;
    final widgetHeight = widget.height;

    String cacheData = '';

    if (prefs!.getString(widget.imageUrl) != null &&
        prefs!.getString(widget.imageUrl) != '') {
      cacheData = prefs!.getString(widget.imageUrl) ?? '';
    }

    if (cacheData != '') {
      _image = CacheImageData.fromJson(jsonDecode(cacheData)).imageMemory;
    } else if (originalUrl.contains('https')) {
      try {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
        final width = (widgetWidth).toInt();
        final height = (widgetHeight ?? 0).toInt();
        final url = '$originalUrl';

        await NetworkAssetBundle(Uri.parse(url)).load(url).then((value) {
          Uint8List imageBytes = value.buffer.asUint8List();

          if (height != 0) {
            FlutterImageCompress.compressWithList(
              imageBytes,
              minWidth: width,
              minHeight: (width * 0.5625).toInt(),
              quality: widget.q == null ? 40 : 100,
            ).then((value) {
              _image = value;
              cacheData = jsonEncode(
                  CacheImageData(imageUrl: widget.imageUrl, imageMemory: value)
                      .toMap());
              prefs!.setString(widget.imageUrl, cacheData);
              if (mounted) {
                setState(() {});
              }
            });
          } else {
            FlutterImageCompress.compressWithList(
              imageBytes,
              minWidth: width,
              minHeight: (width * 0.5625).toInt(),
              quality: widget.q == null ? 40 : 100,
            ).then((value) {
              _image = value;
              cacheData = jsonEncode(
                  CacheImageData(imageUrl: widget.imageUrl, imageMemory: value)
                      .toMap());
              prefs!.setString(widget.imageUrl, cacheData);
              if (mounted) {
                setState(() {});
              }
            });
          }
        });
      } catch (e) {
        debugPrint('Failed to parse image: $originalUrl, $e');
        _isLoading = false;
        _hasError = true;
      } finally {
        _isLoading = false;
      }

      // try {
      //   setState(() {
      //     _isLoading = true;
      //     _hasError = false;
      //   });
      //   final width = (widgetWidth).toInt();
      //   final height = (widgetHeight ?? 0).toInt();
      //   final url = '$originalUrl';
      //
      //   Uint8List imageBytes =
      //       (await NetworkAssetBundle(Uri.parse(url)).load(url))
      //           .buffer
      //           .asUint8List();
      //
      //   if (height != 0) {
      //     _image = await FlutterImageCompress.compressWithList(
      //       imageBytes,
      //       minWidth: width,
      //       minHeight: height,
      //       quality: 20,
      //     );
      //   } else {
      //     _image = await FlutterImageCompress.compressWithList(
      //       imageBytes,
      //       minWidth: width,
      //       minHeight: width,
      //       quality: 20,
      //     );
      //   }
      //
      //   cacheData = jsonEncode(
      //       CacheImageData(imageUrl: widget.imageUrl, imageMemory: _image!)
      //           .toMap());
      //
      //   await prefs!.setString(widget.imageUrl, cacheData);
      //
      //   DefaultCacheManager().emptyCache();
      // } catch (e) {
      //   debugPrint('Failed to parse image: $originalUrl, $e');
      //   _hasError = true;
      // } finally {
      //   _isLoading = false;
      // }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget viewWidget = Container();

    return Image.network(
      widget.imageUrl,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(AppImages.dfClassMain);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
            baseColor: AppColors.gray100,
            highlightColor: AppColors.gray50,
            child: Stack(
              children: [
                Container(
                  child: widget.placeholder ?? Container(),
                  color: AppColors.gray300,
                )
              ],
            ));
      },
      fit: BoxFit.fill,
      width: widget.width,
      cacheWidth: widget.width.toInt(),
      cacheHeight: widget.heightSet ? (widget.width * 0.5625).toInt() : null,
    );

    return Image.network(widget.imageUrl,
        width: widget.width,
        cacheWidth: widget.width.toInt(),
        cacheHeight: (widget.width * 0.5625).toInt());

    if (showPlaceholder) {
      setState(() {
        viewWidget = Shimmer.fromColors(
            baseColor: AppColors.gray100,
            highlightColor: AppColors.gray50,
            child: Stack(
              children: [
                Container(
                  child: widget.placeholder ?? Container(),
                  color: AppColors.gray300,
                )
              ],
            ));
      });
    }
    if (_image != null) {
      ImageProvider provider = MemoryImage(image);
      ImageProvider placeHolderProvider = AssetImage(AppImages.dfClassList);
      setState(() {
        viewWidget = FadeInImage(
          placeholder: placeHolderProvider,
          placeholderFit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: 300),
          image: provider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      });
    }

    return viewWidget;
  }
}
