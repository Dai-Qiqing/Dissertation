import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SensorDataService {
  static const MQTT_BROKER = '8.141.3.32';
  static const MQTT_PORT = 1883;
  static const MQTT_TOPIC = 'HD_top';
  static const COMMAND_TOPIC= 'sensors/esp32c3/command';

  MqttServerClient? client;

  // 连接状态回调
  Function(bool)? onConnectionStatus;
  // 数据接收回调
  Function(Map<String, dynamic>)? onDataReceived;

  Future<void> connect() async {
    try {
      client = MqttServerClient(MQTT_BROKER, 'flutter-client-${DateTime.now().millisecondsSinceEpoch}');
      client!.port = MQTT_PORT;
      client!.logging(on: false);

      // 设置连接选项
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(client!.clientIdentifier)
          .startClean() // 不保留会话
          .withWillQos(MqttQos.atLeastOnce);

      client!.connectionMessage = connMessage;

      // 连接回调
      client!.onConnected = _onConnected;
      client!.onDisconnected = _onDisconnected;
      client!.onSubscribed = _onSubscribed;

      // 尝试连接
      await client!.connect();

      // 订阅主题
      client!.subscribe(MQTT_TOPIC, MqttQos.atLeastOnce);

      // 设置消息回调
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _processMessage(payload);
      });

    } catch (e) {
      print('MQTT Connection Error: $e');
      if (onConnectionStatus != null) {
        onConnectionStatus!(false);
      }
      _reconnect();
    }
  }

  void _onConnected() {
    print('MQTT Connected');
    if (onConnectionStatus != null) {
      onConnectionStatus!(true);
    }
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
    if (onConnectionStatus != null) {
      onConnectionStatus!(false);
    }
    _reconnect();
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _processMessage(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (onDataReceived != null) {
        onDataReceived!(data);
      }
    } catch (e) {
      print('Error parsing MQTT payload: $e\nPayload: $payload');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      print('Attempting MQTT reconnection...');
      connect();
    });
  }

  void disconnect() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.disconnect();
    }
  }

  /// 发布请求命令，告诉设备"请给我最新数据"
  Future<void> requestData(String type) async {
    if (client?.connectionStatus?.state != MqttConnectionState.connected) return;

    final builder = MqttClientPayloadBuilder();
    // 修改为发送 { "type": "tab1" }
    builder.addString(jsonEncode({ 'type': type }));

    client!.publishMessage(COMMAND_TOPIC, MqttQos.atLeastOnce, builder.payload!);

    print('Sent command: {type: tab1} to $COMMAND_TOPIC');
  }

  /// 下面保留你原来的 publish 方法，如果还要用
  Future<void> publish(String topic, String message, {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (client?.connectionStatus?.state != MqttConnectionState.connected) return;
    final builder = MqttClientPayloadBuilder()..addString(message);
    client!.publishMessage(topic, qos, builder.payload!);
  }

}