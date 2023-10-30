import 'dart:io';

import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  final String url;
  final String title;

  WebviewPage({required this.url, required this.title});

  @override
  State<StatefulWidget> createState() {
    return WebviewState();
  }
}

class WebviewState extends State<WebviewPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: baseAppBar(
              title: widget.title,
              context: context,
              onPressed: () {
                pop(context);
              }),
          body: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
