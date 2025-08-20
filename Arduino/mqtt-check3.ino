#include <Wire.h>/Users/dankao/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat/2.0b4.0.9/32c452a1e6200d18e50bf6d690b1110d/Message/MessageTemp/e2f713024116572111ce767b386065db/File/0711/arduino_secrets.h
#include <U8g2lib.h>
#include "MAX30105.h"
#include <WiFi.h>
#include <Ticker.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "arduino_secrets.h"

// ============= OLED屏幕配置 =============
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE, /* clock=*/ 4, /* data=*/ 5);

// ============= 心率传感器对象 =============
MAX30105 particleSensor;

// ============= 引脚定义 =============
const int trigPin = 2;   // 超声波Trig
const int echoPin = 3;   // 超声波Echo
const int ecgPin = 0;    // 肌肉电传感器

// ============= 传感器数据变量 =============
int heartRate = 0;       // 心率值
bool fingerDetected = false; // 手指是否检测到
int distance = 0;        // 距离值
int ecgValue = 0;        // 肌肉电值
float ecgVoltage = 0.0;  // 肌肉电电压

// ============= WiFi和MQTT配置 =============
const char* WIFI_SSID = "CE_mobile"; //  group1 //CE-Hub-Student
const char* WIFI_PASSWORD = "CELAB2025"; // daiqiqing  // casa-ce-gagarin-public-service

// 从arduino_secrets.h引入MQTT配置
const char* mqtt_username = SECRET_MQTTUSER;
const char* mqtt_password = SECRET_MQTTPASS;
const char* mqtt_server = SECRET_MQTTSERVER;
const int mqtt_port = SECRET_MQTTPORT;

// ============= 全局变量 =============
int count;                    // Ticker计数器
char jsonBuffer[256];         // JSON缓冲区
unsigned long messageCount = 0; // 消息计数器
unsigned long lastScreenUpdate = 0;
const int SCREEN_UPDATE_INTERVAL = 200; // 屏幕刷新间隔(ms)

// ============= 对象实例 =============
Ticker ticker;
WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

// ============= 函数声明 =============
void setupWiFi();
void connectMQTTServer();
void pubMQTTmsg();
void tickerCount();
void readHeartRate();
void readUltrasonic();
void readECG();
void updateDisplay();
void printSensorData();
void showError(const char *message);

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== ESP32 传感器系统 ===");
  
  // 初始化OLED屏幕
  u8g2.begin();
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.drawStr(0, 10, "Initializing...");
  u8g2.sendBuffer();
  
  // 初始化心率传感器
  Wire.begin(5, 4); // SDA=GPIO5, SCL=GPIO4
  if (!particleSensor.begin()) {
    showError("MAX30102 Error!");
    Serial.println("心率传感器初始化失败！");
    // 继续运行，但心率功能不可用
  } else {
    particleSensor.setup();
    particleSensor.setPulseAmplitudeRed(0x0A);
    Serial.println("心率传感器初始化成功");
  }
  
  // 初始化超声波传感器
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.println("超声波传感器初始化成功");
  
  // 初始化ADC（肌肉电传感器）
  analogReadResolution(12);
  Serial.println("肌肉电传感器初始化成功");
  
  // 设置Ticker，每秒触发一次
  ticker.attach(1, tickerCount);
  
  // 设置WiFi模式
  WiFi.mode(WIFI_STA);
  
  // 初始化WiFi
  setupWiFi();
  
  // 设置MQTT服务器
  mqttClient.setServer(mqtt_server, mqtt_port);
  
  // 连接MQTT服务器
  connectMQTTServer();
  
  // 显示准备信息
  u8g2.clearBuffer();
  u8g2.drawStr(0, 10, "System Ready");
  u8g2.drawStr(0, 30, "Place finger on HR");
  u8g2.sendBuffer();
  
  Serial.println("系统初始化完成！");
}

void loop() {
  // 读取所有传感器数据
  readHeartRate();
  readUltrasonic();
  readECG();
  
  // 更新屏幕显示
  updateDisplay();
  
  // 串口输出数据（调试用）
  printSensorData();
  
  // 检查MQTT连接状态
  if (mqttClient.connected()) {
    // 每隔1秒钟发布一次信息
    if (count >= 1) {
      pubMQTTmsg();
      count = 0;
    }
    // 保持MQTT心跳
    mqttClient.loop();
  } else {
    // 如果断开连接，尝试重新连接
    Serial.println("MQTT连接丢失，尝试重新连接...");
    connectMQTTServer();
  }
  
  delay(50);
}

// ============= WiFi连接函数 =============
void setupWiFi() {
  Serial.print("正在连接WiFi: ");
  Serial.println(WIFI_SSID);
  
  u8g2.clearBuffer();
  u8g2.drawStr(0, 10, "WiFi Connecting...");
  u8g2.drawStr(0, 30, WIFI_SSID);
  u8g2.sendBuffer();
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi连接成功!");
    Serial.print("IP地址: ");
    Serial.println(WiFi.localIP());
    Serial.print("MAC地址: ");
    Serial.println(WiFi.macAddress());
    
    u8g2.clearBuffer();
    u8g2.drawStr(0, 10, "WiFi Connected");
    u8g2.drawStr(0, 30, WiFi.localIP().toString().c_str());
    u8g2.sendBuffer();
    delay(1000);
  } else {
    Serial.println("\nWiFi连接失败!");
    showError("WiFi Connection Failed");
  }
}

// ============= MQTT连接函数 =============
void connectMQTTServer() {
  // 如果WiFi未连接，先连接WiFi
  if (WiFi.status() != WL_CONNECTED) {
    setupWiFi();
  }
  
  // 先进行网络诊断
  Serial.println("\n=== 网络诊断 ===");
  Serial.print("WiFi状态: ");
  Serial.println(WiFi.status() == WL_CONNECTED ? "已连接" : "未连接");
  Serial.print("本地IP: ");
  Serial.println(WiFi.localIP());
  Serial.print("信号强度: ");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
  
  // 测试网络连通性
  Serial.println("\n正在测试MQTT服务器连通性...");
  Serial.print("MQTT服务器: ");
  Serial.print(mqtt_server);
  Serial.print(":");
  Serial.println(mqtt_port);
  
  // 生成随机客户端ID（参考main_program）
  String clientId = "ESP32_SensorHub_";
  clientId += String(random(0xffff), HEX);
  
  Serial.print("\n正在连接MQTT服务器...");
  
  // 使用用户名和密码连接MQTT服务器
  if (mqttClient.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
    Serial.println("\nMQTT服务器连接成功!");
    Serial.println("服务器地址: " + String(mqtt_server));
    Serial.println("客户端ID: " + clientId);
    Serial.println("----------------------------");
  } else {
    Serial.print("\nMQTT服务器连接失败! 状态码: ");
    Serial.println(mqttClient.state());
    
    // 详细的错误诊断
    Serial.println("\n=== 错误诊断 ===");
    switch(mqttClient.state()) {
      case -4:
        Serial.println("超时 - 服务器没有响应");
        Serial.println("建议：检查服务器地址和端口是否正确");
        break;
      case -3:
        Serial.println("连接丢失 - 物理连接中断");
        Serial.println("建议：检查网络稳定性");
        break;
      case -2:
        Serial.println("连接失败 - 无法建立网络连接");
        Serial.println("可能原因：");
        Serial.println("1. MQTT服务器地址错误");
        Serial.println("2. MQTT服务器端口错误");
        Serial.println("3. 防火墙阻止了连接");
        Serial.println("4. MQTT服务器未运行");
        Serial.println("5. 网络无法访问外网");
        break;
      case -1:
        Serial.println("连接断开 - 客户端主动断开");
        break;
      case 1:
        Serial.println("协议错误 - MQTT版本不匹配");
        break;
      case 2:
        Serial.println("客户端ID被拒绝");
        break;
      case 3:
        Serial.println("服务器不可用");
        break;
      case 4:
        Serial.println("用户名/密码错误");
        Serial.println("请检查arduino_secrets.h中的认证信息");
        break;
      case 5:
        Serial.println("未授权");
        break;
    }
    Serial.println("=================");
    delay(5000);
  }
}

// ============= MQTT消息发布函数 =============
void pubMQTTmsg() {
  messageCount++;
  
  // 创建JSON文档 - 保持原有格式
  StaticJsonDocument<200> doc;
  doc["distance"] = distance;
  doc["heartRate"] = heartRate;
  
  // 序列化JSON到缓冲区
  serializeJson(doc, jsonBuffer);
  
  // 使用原主题 "HD_top" 发布消息
  Serial.print("发送MQTT消息 #" + String(messageCount) + " ... ");
  
  if (mqttClient.publish("student/HD_top", jsonBuffer)) {
    Serial.println("成功!");
    Serial.println("主题: HD_top");
    Serial.println("内容: " + String(jsonBuffer));
    Serial.println("----------------------------");
  } else {
    Serial.println("失败!");
    Serial.println("请检查MQTT连接状态");
    Serial.println("----------------------------");
  }
}

// ============= 传感器读取函数 =============
void readHeartRate() {
  if (particleSensor.begin()) {
    int32_t irValue = particleSensor.getIR();
    
    if (irValue > 50000) {
      fingerDetected = true;
      // 实际应用中应使用真实算法，这里使用模拟数据
      heartRate = random(60, 100);
    } else {
      fingerDetected = false;
      heartRate = 0;
    }
  }
}

void readUltrasonic() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  long duration = pulseIn(echoPin, HIGH, 30000); // 30ms超时
  
  if (duration > 0) {
    distance = duration * 0.034 / 2;
    // 限制有效范围
    if (distance > 400) distance = 400;
    if (distance < 0) distance = 0;
  }
}

void readECG() {
  ecgValue = analogRead(ecgPin);
  ecgVoltage = ecgValue * (3.3 / 4095.0);
}

// ============= OLED显示更新 =============
void updateDisplay() {
  // 控制刷新频率
  if (millis() - lastScreenUpdate < SCREEN_UPDATE_INTERVAL) 
    return;
  
  lastScreenUpdate = millis();
  
  u8g2.clearBuffer();
  
  // 第一行：心率数据
  u8g2.setFont(u8g2_font_ncenB10_tr);
  char hrStr[20];
  if (fingerDetected) {
    snprintf(hrStr, sizeof(hrStr), "HR:%d BPM", heartRate);
  } else {
    snprintf(hrStr, sizeof(hrStr), "NO finger");
  }
  u8g2.drawStr(0, 15, hrStr);
  
  // 第二行：距离数据
  char distStr[20];
  snprintf(distStr, sizeof(distStr), "Dist:%dcm", distance);
  u8g2.drawStr(0, 30, distStr);
  
  // 第三行：肌肉电数据
  char ecgStr[25];
  snprintf(ecgStr, sizeof(ecgStr), "ECG:%d (%.2fV)", ecgValue, ecgVoltage);
  u8g2.drawStr(0, 45, ecgStr);
  
  // 第四行：网络状态
  u8g2.setFont(u8g2_font_ncenB08_tr);
  if (WiFi.status() == WL_CONNECTED) {
    if (mqttClient.connected()) {
      char statusStr[30];
      snprintf(statusStr, sizeof(statusStr), "MQTT OK #%lu", messageCount);
      u8g2.drawStr(0, 60, statusStr);
    } else {
      u8g2.drawStr(0, 60, "MQTT Disconnected");
    }
  } else {
    u8g2.drawStr(0, 60, "No Network");
  }
  
  u8g2.sendBuffer();
}

// ============= 串口输出 =============
void printSensorData() {
  static unsigned long lastPrint = 0;
  if (millis() - lastPrint < 1000) 
    return;
  
  lastPrint = millis();
  
  Serial.println("\n--- 传感器数据 ---");
  Serial.print("心率: ");
  if (fingerDetected) {
    Serial.print(heartRate);
    Serial.println(" BPM");
  } else {
    Serial.println("未检测到手指");
  }
  
  Serial.print("距离: ");
  Serial.print(distance);
  Serial.println(" cm");
  
  Serial.print("肌肉电: ");
  Serial.print(ecgValue);
  Serial.print(" (");
  Serial.print(ecgVoltage, 3);
  Serial.println("V)");
  
  Serial.print("MQTT状态: ");
  Serial.println(mqttClient.connected() ? "已连接" : "未连接");
  Serial.println("-------------------");
}

// ============= 错误显示 =============
void showError(const char *message) {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_ncenB08_tr);
  u8g2.drawStr(0, 20, "ERROR:");
  u8g2.drawStr(0, 35, message);
  u8g2.drawStr(0, 50, "Check connection");
  u8g2.sendBuffer();
  
  Serial.print("错误: ");
  Serial.println(message);
}

// ============= Ticker回调函数 =============
void tickerCount() {
  count++;
}