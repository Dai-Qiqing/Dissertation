import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';

class ApiRecord {
  Future<List<dynamic>> getDates(data) async {
    try {
      var response = await HttpClient().dio.get(
            ApiConfig.api_date,
            queryParameters: data,
          );
      if (response.data['code'] == 200) {
        return response.data['data'];
      }
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('获取浏览日期列表失败: $e');
    }
    return [];
  }

  Future<List<Record>?> getRecords(data) async {
    try {
      var response = await HttpClient().dio.get(
            ApiConfig.api_record,
            queryParameters: data,
          );
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map(
              (e) => Record.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('获取浏览历史列表失败: $e');
    }
    return null;
  }
}
