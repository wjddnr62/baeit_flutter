import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/chat/report.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:http/http.dart';

class ChatReportService extends BaseService {
  final Report report;

  ChatReportService({required this.report});

  @override
  expiration(body) {
    return ReturnData.fromJson(body);
  }

  @override
  Future<Response> request() {
    return fetchPost(body: jsonEncode(report.toMap()));
  }

  @override
  setUrl() {
    return baseUrl + 'chat/report';
  }

  @override
  success(body) {
    return ReturnData.fromJson(body);
  }
}
