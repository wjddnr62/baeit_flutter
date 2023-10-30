import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/gradient.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewDetailPage extends StatefulWidget {
  final int idx;
  final List<Data> images;
  final String heroTag;
  final bool download;
  final Data? originImage;

  ImageViewDetailPage(
      {required this.idx,
      required this.images,
      this.originImage,
      required this.heroTag,
      this.download = false});

  @override
  State<StatefulWidget> createState() {
    return ImageViewDetailState();
  }
}

class ImageViewDetailState extends State<ImageViewDetailPage> {
  int num = 0;
  bool loading = false;
  PageController? pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: widget.idx);
    num = widget.idx + 1;

    ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
      if (progress == 100) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.black,
          child: Stack(
            children: [
              PageView.builder(
                itemBuilder: (context, idx) {
                  return PhotoViewGallery.builder(
                    itemCount: widget.images.length * 100,
                    builder: (context, idx) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(
                            '${(idx % widget.images.length) == 0 ? widget.originImage != null ? widget.originImage?.toView(context: context, image: false) : widget.images[idx % widget.images.length].toView(context: context, image: false) : widget.images[idx % widget.images.length].toView(context: context, image: false)}'),
                        errorBuilder: (context, error, _) {
                          return CacheImage(
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              imageUrl:
                                  '${(idx % widget.images.length) == 0 ? widget.originImage != null ? widget.originImage?.toView(context: context, image: false) : widget.images[idx % widget.images.length].toView(context: context, image: false) : widget.images[idx % widget.images.length].toView(context: context, image: false)}');
                        },
                        initialScale: PhotoViewComputedScale.contained * 1,
                        minScale: PhotoViewComputedScale.contained * 0.5,
                      );
                    },
                    onPageChanged: (idx) {
                      setState(() {
                        num = idx % widget.images.length + 1;
                      });
                    },
                    pageController: pageController,
                    loadingBuilder: (context, idx) => loadingView(true),
                  );
                },
              ),
              Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: topGradient(
                          context: context,
                          height: 80,
                          downColor: AppColors.black.withOpacity(0),
                          upColor: AppColors.black.withOpacity(0.3))),
                  Column(
                    children: [
                      spaceH(18),
                      Container(
                        height: 24,
                        child: Row(
                          children: [
                            spaceW(44),
                            Expanded(child: Container()),
                            customText(
                              '$num',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: AppColors.white,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T15)),
                            ),
                            customText(
                              '/',
                              style: TextStyle(
                                  letterSpacing: 5,
                                  decoration: TextDecoration.none,
                                  color: AppColors.gray600,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T15)),
                            ),
                            customText(
                              '${widget.images.length}',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: AppColors.gray600,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T15)),
                            ),
                            Expanded(child: Container()),
                            GestureDetector(
                              onTap: () {
                                pop(context);
                              },
                              child: Image.asset(
                                AppImages.iX,
                                width: 24,
                                height: 24,
                                color: AppColors.white,
                              ),
                            ),
                            spaceW(20)
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
              widget.download
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await Permission.storage.isGranted) {
                              loading = true;
                              setState(() {});
                              await ImageDownloader.downloadImage(
                                  "${widget.images[num - 1].prefixUrl}/${widget.images[num - 1].path}/${widget.images[num - 1].storedName}");
                            } else if (await Permission.storage.isDenied ||
                                await Permission.storage.isPermanentlyDenied) {
                              decisionDialog(
                                  context: context,
                                  barrier: false,
                                  text:
                                      AppStrings.of(StringKey.storageCheckText),
                                  allowText: AppStrings.of(StringKey.check),
                                  disallowText: AppStrings.of(StringKey.cancel),
                                  allowCallback: () async {
                                    popDialog(context);
                                    await openAppSettings();
                                  },
                                  disallowCallback: () {
                                    popDialog(context);
                                  });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0, primary: AppColors.accentLight20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                customText(
                                  '이미지 다운로드',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                ),
                                Icon(Icons.download_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              loadingView(loading)
            ],
          ),
        ),
      ),
    );
  }
}
