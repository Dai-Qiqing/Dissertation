class ResponseData {
  int code;
  String message;
  dynamic data;

  ResponseData({
    required this.code,
    required this.message,
    this.data,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        code: json["code"],
        message: json["message"],
        data: json["data"],
      );
}
