class ReturnData {
  final int code;
  final String? message;
  final dynamic data;

  ReturnData({required this.code, required this.message, this.data});

  factory ReturnData.fromJson(body) {
    return ReturnData(
        code: body['code'],
        message: body['message'],
        data: body['data']);
  }
}
