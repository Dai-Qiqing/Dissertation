import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../../mqtt/mqtt_util.dart';

class GlobalDataController extends GetxController {
  final SensorDataService _mqttService = SensorDataService();

  // ====== 距离统计相关 ======
  /// 当前实时距离 (米)
  final RxDouble currentDistance   = 0.0.obs;
  /// 记录总次数
  final RxInt    totalCount        = 0.obs;
  /// 距离和累加 (米)
  final RxDouble sumDistance       = 0.0.obs;
  /// 平均距离 (米)
  final RxDouble avgDistance       = 0.0.obs;

  /// 危险距离阈值 (米)
  final RxDouble dangerThreshold = 0.5.obs;
  /// 警告距离阈值 (米)
  final RxDouble alertThreshold = 1.0.obs;

  /// 心率危险阈值 (bpm)
  final RxInt dangerHrThreshold = 100.obs;
  /// 心率警告阈值 (bpm)
  final RxInt alertHrThreshold = 90.obs;

  /// 危险状态发生次数
  final RxInt dangerCount      = 0.obs;
  /// 警告状态发生次数
  final RxInt alertCount       = 0.obs;
  /// 舒适状态发生次数
  final RxInt comfortableCount = 0.obs;

  // ====== 心率统计相关 ======
  /// 当前实时心率 (bpm)
  final RxInt currentHeartRate = 0.obs;
  /// 心率总和
  final RxInt sumHeartRate = 0.obs;
  /// 平均心率
  final RxDouble avgHeartRate = 0.0.obs;

  /// 进度：当前距离 / 危险阈值
  double get dangerProgress => (currentDistance.value / alertThreshold.value).clamp(0.0, 1.0);

  /// 当前状态类型：danger/alert/comfortable（基于距离和心率双重判断）
  String get currentState {
    final distance = currentDistance.value;
    final heartRate = currentHeartRate.value;

    final distanceState = distance < dangerThreshold.value
        ? 'danger'
        : (distance < alertThreshold.value ? 'alert' : 'comfortable');

    final heartRateState = heartRate > dangerHrThreshold.value
        ? 'danger'
        : (heartRate > alertHrThreshold.value ? 'alert' : 'comfortable');

    // 任何一项达到危险级别则整体危险
    if (distanceState == 'danger' || heartRateState == 'danger') {
      return 'danger';
    }
    // 任何一项达到警告级别则整体警告
    else if (distanceState == 'alert' || heartRateState == 'alert') {
      return 'alert';
    }
    // 否则为舒适
    return 'comfortable';
  }

  // ====== 历史记录，用于折线图 ======
  /// 每次记录的时间点、距离和心率
  final RxList<Map<String, dynamic>> distanceHistory = <Map<String, dynamic>>[].obs;

  // ====== 距离持续时长统计 ======
  /// 上一次记录的时间，用于计算两次更新之间的间隔
  DateTime? _lastRecordTime;
  /// 每个距离累计占用的总时长 (单位：秒)
  final RxMap<double, int> distanceDurations = <double, int>{}.obs;

  /// 上一次状态
  String? _lastState;

  /// 雷达图周围人员目标
  final RxList<Map<String, dynamic>> surroundingTargets = <Map<String, dynamic>>[].obs;

  /// 反馈提醒开关
  final RxBool feedbackReminder = true.obs;

  /// 雷达图图层（每层多个点+颜色）
  final RxList<RadarLayer> radarLayers = <RadarLayer>[].obs;

  /// 最近交互记录
  final RxList<RecentInteraction> recentInteractions = <RecentInteraction>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化雷达图层
    _updateRadarLayers();

    // 连接状态回调
    _mqttService.onConnectionStatus = (connected) {
      if (connected) {
        _mqttService.requestData("tab1");
      } else {
        Get.snackbar('MQTT', '连接已断开');
      }
    };

    // 数据接收回调 - 增加心率字段接收
    _mqttService.onDataReceived = (data) {
      final double newDist = (data['distance'] ?? currentDistance.value).toDouble();
      final int newHr = (data['heartRate'] ?? currentHeartRate.value).toInt();
      _updateSensorData(newDist, newHr);
    };

    // 发起连接
    _mqttService.connect();
  }

  void _updateRadarLayers() {
    // 1. 用户自身位置
    final userLayer = RadarLayer(
      points: [
        RadarPoint(angle: 90, radius: 0), // 用户自身在中心
      ],
      color: Colors.blue,
    );

    // 2. 周围人员点
    final peopleLayer = RadarLayer(
      points: _generateSurroundingPoints(),
      color: Colors.white,
    );

    radarLayers.assignAll([
      peopleLayer,
      userLayer,
    ]);
  }

  List<RadarPoint> _generateSurroundingPoints() {
    List<RadarPoint> points = [];

    // 根据距离计算目标数量
    int targetCount;
    if (currentDistance.value < dangerThreshold.value) {
      targetCount = 3; // 危险状态：3个目标
    } else if (currentDistance.value < alertThreshold.value) {
      targetCount = 2; // 警告状态：2个目标
    } else {
      targetCount = 1; // 安全状态：1个目标
    }

    for (int i = 0; i < targetCount; i++) {
      // 计算角度 - 均匀分布在360度
      double angle = i * (360 / targetCount);

      // 计算距离 - 根据状态变化
      double radius;
      if (currentDistance.value < dangerThreshold.value) {
        radius = 0.4; // 危险状态：近距离0.4米
      } else if (currentDistance.value < alertThreshold.value) {
        radius = 0.8; // 警告状态：中距离0.8米
      } else {
        radius = 1.2; // 安全状态：远距离1.2米
      }

      points.add(RadarPoint(
        angle: angle,
        radius: radius,
      ));
    }

    return points;
  }

  void _updateSensorData(double newDistance, int newHeartRate) {
    final now = DateTime.now();

    // 如果已经有上一次记录，则累加两次之间的时长到上一个 distance
    if (_lastRecordTime != null) {
      final elapsed = now.difference(_lastRecordTime!).inSeconds;
      final lastDist = currentDistance.value;
      distanceDurations[lastDist] = (distanceDurations[lastDist] ?? 0) + elapsed;
    }
    // 更新为这次的记录时间
    _lastRecordTime = now;

    // 只有传感器数据发生变化时才更新统计和历史
    if (newDistance != currentDistance.value || newHeartRate != currentHeartRate.value) {
      // 次数统计
      totalCount.value  += 1;

      // 距离统计
      sumDistance.value += newDistance;
      avgDistance.value  = sumDistance.value / totalCount.value;

      // 心率统计
      sumHeartRate.value += newHeartRate;
      avgHeartRate.value = sumHeartRate.value / totalCount.value.toDouble();

      // 综合状态分类计数
      // 保存旧值用于临时计算状态
      final tempDistance = currentDistance.value;
      final tempHeartRate = currentHeartRate.value;

      // 临时更新为最新值用于状态判断
      currentDistance.value = newDistance;
      currentHeartRate.value = newHeartRate;

      // 根据当前状态计数
      switch (currentState) {
        case 'danger':
          dangerCount.value += 1;
          break;
        case 'alert':
          alertCount.value += 1;
          break;
        default:
          comfortableCount.value += 1;
          break;
      }

      // 还原旧值（后面会更新）
      currentDistance.value = tempDistance;
      currentHeartRate.value = tempHeartRate;

      // 历史记录（同时存储距离和心率）
      distanceHistory.add({
        'time': now,
        'distance': newDistance,
        'heartRate': newHeartRate,
      });
    }

    // 更新当前值
    currentDistance.value = newDistance;
    currentHeartRate.value = newHeartRate;

    // 检查状态变化，生成新的交互记录
    _checkStateChange();

    // 更新雷达图层（仍基于距离）
    _updateRadarLayers();
  }

  /// 检查状态变化并生成交互记录
  void _checkStateChange() {
    if (_lastState == currentState) return;

    String title;
    String type;
    int count;

    if (_lastState == null) {
      // 初始状态
      switch (currentState) {
        case 'danger':
          title = 'Danger: Person Approaching and Heart Rate Elevated'; // 危险状态：人员靠近且心率升高
          type = 'alert';
          count = dangerCount.value;
          break;
        case 'alert':
          title = 'Alert: Please Pay Attention to Your Surroundings'; // 警告：请注意周围环境
          type = 'alert';
          count = alertCount.value;
          break;
        default:
          title = 'Comfortable Space'; // 舒适空间
          type = 'comfort';
          count = comfortableCount.value;
          break;
      }
    } else {
      // 状态变化
      switch (currentState) {
        case 'danger':
          title = 'Entering Danger Zone!'; // 进入危险区域！
          type = 'alert';
          count = dangerCount.value;
          break;
        case 'alert':
          title = 'Environmental Change Alert'; // 环境变化警告
          type = _lastState == 'danger' ? 'comfort' : 'alert';
          count = alertCount.value;
          break;
        default: // 'comfortable'
          title = 'Safe Distance Restored'; // 恢复安全距离
          type = 'comfort';
          count = comfortableCount.value;
          break;
      }
    }
    // 添加到最近交互记录
    recentInteractions.insert(0, RecentInteraction(
      title: title,
      count: count, // 使用状态发生的次数
      type: type,
    ));

    // 只保留最近的10条记录
    if (recentInteractions.length > 10) {
      recentInteractions.removeRange(10, recentInteractions.length);
    }

    // 更新状态
    _lastState = currentState;
  }

  @override
  void onClose() {
    _mqttService.disconnect();
    super.onClose();
  }

  static const COMMAND_TOPIC= 'sensors/esp32c3/command';

  /// 将当前阈值通过 MQTT 发布到设备
  void publishThresholds() {
    final payload = jsonEncode({
      'dangerThreshold': dangerThreshold.value,
      'alertThreshold': alertThreshold.value,
    });
    // 假设你的 SensorDataService 提供了一个 publish 方法
    // 你也可以根据你的 mqtt_util 实际 API 调整这里
    _mqttService.publish(COMMAND_TOPIC, payload);
  }
}

/// 雷达图层定义
class RadarLayer {
  final List<RadarPoint> points;
  final Color color;

  RadarLayer({
    required this.points,
    required this.color,
  });
}

/// 雷达顶点定义
class RadarPoint {
  final double angle;
  final double radius;

  RadarPoint({
    required this.angle,
    required this.radius,
  });
}

/// 最近交互记录
class RecentInteraction {
  final String title;
  final int count;     // 该状态发生的次数
  final String type;   // 'comfort', 'warning', 'alert'

  RecentInteraction({
    required this.title,
    required this.count,
    required this.type
  });
}