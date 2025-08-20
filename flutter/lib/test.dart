import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

void main() {
  runApp(const SensorDashboardApp());
}

class SensorDashboardApp extends StatelessWidget {
  const SensorDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SensorDashboardScreen(),
    );
  }
}

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

  @override
  _SensorDashboardScreenState createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  final SensorDataService _sensorService = SensorDataService();
  Map<String, dynamic> _sensorData = {
    'hr': -1,
    'dist': 0,
    'ecg': 0,
  };
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _initMQTT();
  }

  void _initMQTT() {
    _sensorService.onConnectionStatus = (connected) {
      setState(() {
        _isConnected = connected;
        _connectionStatus = connected ? 'Connected to MQTT' : 'Disconnected';
      });
    };

    _sensorService.onDataReceived = (data) {
      setState(() => _sensorData = data);
    };

    _sensorService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('传感器监控面板'),
        actions: [
          Icon(
            _isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 连接状态
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                    children: [
                    const Icon(Icons.wifi, size: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                  _connectionStatus,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Topic: sensors/esp32c3/data',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),

    // 传感器数据卡片
    Expanded(
    child: ListView(
    children: [
    _buildHeartRateCard(),
    const SizedBox(height: 20),
    _buildUltrasonicCard(),
    const SizedBox(height: 20),
    _buildECGCard(),
    ],
    ),
    ),
    ],
    ),
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    if (_isConnected) {
    _sensorService.disconnect();
    } else {
    _sensorService.connect();
    }
    },
    tooltip: _isConnected ? 'Disconnect' : 'Connect',
    child: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
    ),
    );
  }

  Widget _buildHeartRateCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('心率监测',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (_sensorData['hr'] == -1)
              Column(
                children: [
                  const Icon(Icons.fingerprint, size: 60, color: Colors.orange),
                  const SizedBox(height: 10),
                  const Text('手指未检测到',
                      style: TextStyle(fontSize: 20, color: Colors.orange)),
                  const SizedBox(height: 5),
                  Text('请将手指放在传感器上',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              )
            else
              Column(
                children: [
                  Icon(Icons.favorite, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('${_sensorData['hr']} BPM',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('心率正常',
                      style: TextStyle(fontSize: 16, color: Colors.green[700])),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltrasonicCard() {
    double distValue = _sensorData['dist']?.toDouble() ?? 0.0;
    double progress = distValue > 100 ? 1.0 : distValue / 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('距离监测',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.social_distance, size: 40, color: Colors.blue),
                Text('$distValue cm',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progress,
              minHeight: 25,
              backgroundColor: Colors.grey[300],
              color: progress > 0.8 ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 cm', style: TextStyle(color: Colors.grey[600])),
                Text('100 cm', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildECGCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('肌肉电信号',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.abc_outlined, size: 40, color: Colors.green),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_sensorData['ecg']} RAW',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${(_sensorData['ecg'] * 3.3 / 4095).toStringAsFixed(2)} V',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                  painter: ECGWavePainter(_sensorData['ecg']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorService.disconnect();
    super.dispose();
  }
}

class SensorDataService {
  static const MQTT_BROKER = 'broker.emqx.io';
  static const MQTT_PORT = 1883;
  static const MQTT_TOPIC = 'sensors/esp32c3/data';

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
}

class ECGWavePainter extends CustomPainter {
  final int ecgValue;
  final List<int> _values = [];

  ECGWavePainter(this.ecgValue) {
    _values.add(ecgValue);
    if (_values.length > 100) _values.removeAt(0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (_values.isEmpty) return;

    final path = Path();
    final xStep = size.width / (_values.length - 1);
    final scaleFactor = size.height / 4095;

    path.moveTo(0, size.height - (_values[0] * scaleFactor));

    for (int i = 1; i < _values.length; i++) {
      final x = i * xStep;
      final y = size.height - (_values[i] * scaleFactor);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // 绘制网格
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 水平网格线
    for (double y = 0; y < size.height; y += size.height / 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 垂直网格线
    for (double x = 0; x < size.width; x += size.width / 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}