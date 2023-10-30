import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import 'class_location_bloc.dart';

class ClassLocationPage extends BlocStatefulWidget {
  final String title;
  final String classUuid;
  final String lati;
  final String longi;

  ClassLocationPage(
      {required this.title,
      required this.classUuid,
      required this.lati,
      required this.longi});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ClassLocationState();
  }
}

class ClassLocationState
    extends BlocState<ClassLocationBloc, ClassLocationPage> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        return Container(
          color: AppColors.white,
          child: Stack(
            children: [
              Scaffold(
                appBar: baseAppBar(
                    title: widget.title,
                    centerTitle: true,
                    context: context,
                    close: true,
                    onPressed: () {
                      pop(context);
                    }),
                body: NaverMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(widget.lati),
                          double.parse(widget.longi)), zoom: 15),
                  maxZoom: 15,
                  locationButtonEnable: true,
                  markers: bloc.markers,
                ),
              ),
              loadingView(bloc.loading)
            ],
          ),
        );
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  ClassLocationBloc initBloc() {
    return ClassLocationBloc(context)
      ..add(ClassLocationInitEvent(
          classUuid: widget.classUuid, lati: widget.lati, longi: widget.longi));
  }
}
