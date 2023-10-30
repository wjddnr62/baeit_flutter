import 'dart:convert';
import 'dart:io';

import 'package:baeit/config/common.dart';
import 'package:baeit/config/push_config.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

export 'dart:convert';

export 'package:flutter/foundation.dart';

abstract class BaseService<T> {
  String? _url;
  bool withAccessToken = dataSaver.nonMember ? false : true;
  bool jsonContentType = true;
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
    'App-Version':
        dataSaver.packageInfo == null ? '' : dataSaver.packageInfo!.version
  };

  BaseService({this.withAccessToken = true, this.jsonContentType = true});

  dynamic setUrl();

  String get url => _url!;

  dynamic _contentTypes() {
    return jsonContentType
        ? {'Content-Type': 'application/json'}
        : {'Content-Type': 'application/x-www-form-urlencoded'};
  }

  dynamic _extraHeaders() async {
    if (prefs!.getBool('guest') ?? false) {
      dataSaver.nonMember = true;
    } else {
      dataSaver.nonMember = false;
    }
    withAccessToken = dataSaver.nonMember ? false : true;
    return withAccessToken && prefs!.getString('accessToken') != null
        ? {'Authorization': 'Bearer ${prefs!.getString('accessToken')}'}
        : {};
  }

  Future<dynamic> start() async {
    _url = await setUrl();
    _headers = {
      'Content-Type': 'application/json',
      'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
      'App-Version':
          dataSaver.packageInfo == null ? '' : dataSaver.packageInfo!.version
    };
    var extra = await _extraHeaders();
    if (extra != null && extra is Map<String, String>) {
      _headers.addAll(extra);
    }
    _headers.addAll(_contentTypes());

    return await _start();
  }

  bool refreshAccessTokenIng = false;

  Future<dynamic> refreshAccessToken({bool reEntry = false}) async {
    UserData userData =
        UserData.fromJson(jsonDecode(prefs!.getString('userData').toString()));
    Map<String, dynamic> data = {};
    data.addAll({'memberUuid': userData.memberUuid});
    data.addAll({'refreshToken': userData.refreshToken});

    Map<String, String> _headers = {
      'Content-Type': 'application/json',
      'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
      'App-Version':
          dataSaver.packageInfo == null ? '' : dataSaver.packageInfo!.version
    };

    _headers.addAll({'Content-Type': 'application/json'});

    http.Response response = await http.post(Uri.parse(baseUrl + "accessToken"),
        headers: _headers, body: jsonEncode(data));

    var body;
    try {
      if (response.bodyBytes.length != 0) {
        body = json.decode(
            Utf8Decoder(allowMalformed: false).convert(response.bodyBytes));
      }
    } catch (e) {
      body = (String.fromCharCodes(response.bodyBytes));
    }

    if (response.statusCode == 403) {
      debugPrint('response body : $body');
      selectedNotificationPayload = null;
      messaging.deleteToken();
      if (dataSaver.mainBloc != null) {
        dataSaver.mainBloc!.add(StopEvent());
        sharedClear();
        dataSaver.clear();
        return;
      } else {
        if (body != null) {
          return expiration(body);
        } else {
          return;
        }
      }
    }

    ReturnData returnData = ReturnData.fromJson(body);

    await prefs!.setString(
        'accessToken', UserData.fromJson(returnData.data).accessToken);

    return await start();
  }

  Future<dynamic> _start() async {
    http.Response response = await request();

    var body;
    try {
      if (response.bodyBytes.length != 0) {
        body = json.decode(
            Utf8Decoder(allowMalformed: false).convert(response.bodyBytes));
      }
    } catch (e) {
      body = (String.fromCharCodes(response.bodyBytes));
    }

    if (response.statusCode == 200 || response.statusCode == 204) {
      debugPrint('response body : $body');
      return success(body);
    }

    if (response.statusCode == 401) {
      return await refreshAccessToken();
    }

    if (response.statusCode == 403) {
      debugPrint('response body : $body');
      selectedNotificationPayload = null;
      messaging.deleteToken();
      if (dataSaver.mainBloc != null) {
        dataSaver.mainBloc!.add(StopEvent());
        sharedClear();
        dataSaver.clear();
        return;
      } else {
        if (body != null) {
          return expiration(body);
        } else {
          return;
        }
      }
    }
  }

  Future<http.Response> request();

  T success(dynamic body);

  T expiration(dynamic body);

  Future<http.Response> fetchGet() async {
    debugPrint('request url : $url');
    debugPrint('request header : $_headers');
    return await http.get(Uri.parse(url), headers: _headers);
  }

  Future<http.Response> fetchPut({
    dynamic body,
    Encoding? encoding,
  }) async {
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');
    return await http.put(Uri.parse(url),
        headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> fetchPost({
    dynamic body,
  }) async {
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');

    return await http.post(Uri.parse(url), headers: _headers, body: body);
  }

  Future<http.Response> fetchDelete() async {
    debugPrint('request url : $url');
    debugPrint('request header : $_headers');
    return await http.delete(Uri.parse(url), headers: _headers);
  }
}
