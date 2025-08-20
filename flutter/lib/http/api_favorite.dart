import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';

class ApiFavorite {
  Future<List<Favorite>> getFavorites(data) async {
    try {
      var response = await HttpClient().dio.get(
            ApiConfig.api_favorite_list,
            queryParameters: data,
          );
      if (response.data['code'] == 200) {
        return (response.data['data'] as List)
            .map(
              (e) => Favorite.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('获取收藏列表失败: $e');
    }
    return [];
  }

  Future<bool> deleteFavorites(data) async {
    try {
      var response = await HttpClient().dio.post(
            ApiConfig.api_favorite_delete,
            data: jsonEncode(data),
          );
      return response.data['code'] == 200;
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('删除收藏失败: $e');
    }
    return false;
  }

  Future<bool> addFavorite(data) async {
    try {
      var response = await HttpClient().dio.post(
            ApiConfig.api_favorite_add,
            data: jsonEncode(data),
          );
      return response.data['code'] == 200;
    } catch (e) {
      // 请求失败，处理错误信息
      debugPrint('添加收藏失败: $e');
    }
    return false;
  }
}
