import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';

class ApiAuth {
  Future<ResponseData?> register(data) async {
    try {
      var response = await HttpClient().dio.post(
            ApiConfig.api_register,
            data: jsonEncode(data),
          );
      Map<String, dynamic> result = response.data;
      // 请求成功，处理响应数据
      return ResponseData.fromJson(result);
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('注册失败: $e');
    }
    return null;
  }

  Future<ResponseData?> login(data) async {
    try {
      var response = await HttpClient().dio.post(
            ApiConfig.api_login,
            data: jsonEncode(data),
          );
      Map<String, dynamic> result = response.data;
      // 请求成功，处理响应数据
      return ResponseData.fromJson(result);
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('登录失败: $e');
    }
    return null;
  }
}
