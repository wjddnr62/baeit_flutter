import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/ui/image_view/image_view_bloc.dart';
import 'package:baeit/ui/image_view/image_view_detail_page.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ImageViewPage extends BlocStatefulWidget {
  final List<Data> imageUrls;
  final String heroTag;
  final Data? originImage;

  ImageViewPage(
      {required this.imageUrls, required this.heroTag, this.originImage});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ImageViewState();
  }
}

class ImageViewState extends BlocState<ImageViewBloc, ImageViewPage> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: baseAppBar(
                  title: AppStrings.of(StringKey.allImage),
                  context: context,
                  onPressed: () {
                    pop(context);
                  }),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 202,
                      child: GestureDetector(
                        onTap: () {
                          pushTransition(
                              context,
                              ImageViewDetailPage(
                                idx: 0,
                                images: widget.imageUrls,
                                heroTag: widget.heroTag,
                                originImage: widget.originImage,
                              ));
                        },
                        child: CacheImage(
                          imageUrl: '${widget.imageUrls[0].toView(context: context, )}',
                          width: MediaQuery.of(context).size.width,
                          placeholder: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(4)),
                            child: Image.asset(
                              AppImages.dfClassMain,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    spaceH(6),
                    StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      itemBuilder: (BuildContext context, int idx) {
                        return GestureDetector(
                          onTap: () {
                            pushTransition(
                                context,
                                ImageViewDetailPage(
                                    idx: idx + 1,
                                    images: widget.imageUrls,
                                    heroTag: 'TAG'));
                          },
                          child: CacheImage(
                            imageUrl: '${widget.imageUrls[idx + 1].toView(context: context, )}',
                            width: MediaQuery.of(context).size.width,
                            heightSet: false,
                            placeholder: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(4)),
                              child: Image.asset(
                                AppImages.dfClassMain,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      itemCount: widget.imageUrls.length - 1,
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  ImageViewBloc initBloc() {
    return ImageViewBloc(context)..add(ImageViewInitEvent());
  }
}
