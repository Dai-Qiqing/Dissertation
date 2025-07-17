import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';
import 'package:flutter_outfit/modules/device/view.dart';
import 'package:get/get.dart';

import '../../mqtt/mqtt_util.dart';
import '../chart/view.dart';
import '../interaction/view.dart';

class MainController extends GetxController {
  MainController();

  final SensorDataService _sensorService = SensorDataService();

  /// 当前连接状态
  var isConnected = false.obs;
  /// 最新接收到的传感器数据
  var sensorData = <String, dynamic>{
    'hr': -1,
    'dist': 0,
    'ecg': 0,
  }.obs;


  _initData() {
    update(["main"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
    //_initMQTT();
  }

  void _initMQTT() {
    // 连接状态回调
    _sensorService.onConnectionStatus = (connected) {
      isConnected.value = connected;
      print('Connection status: ${connected ? 'Connected' : 'Disconnected'}');
    };

    // 数据接收回调
    _sensorService.onDataReceived = (data) {
      sensorData.value = data;
      // 这里也可以直接 update(["main"])，刷新部分 UI
    };

    // 建立连接
    _sensorService.connect();
  }

  var currentNavIndex = 0.obs;
  //增加一个新的变量，默认值为0
  PageController pageController = PageController(initialPage: 0);

  final mainPages = [
    const HomePage(),
    const ChartPage(),
    RealTimeInteractionPage(),
    DevicePage(),
    const ProfilePage(),
  ];

  void setCurrentNavIndex(index) {
    currentNavIndex.value = index;
    update();
  }

  void updatePageIndex(index) {
    pageController.jumpToPage(index);
    setCurrentNavIndex(index);
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
