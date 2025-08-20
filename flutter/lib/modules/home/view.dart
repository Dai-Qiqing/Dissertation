import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../GlobalDataController.dart';
import '../../constants/color_value.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // 数据卡片组件
  Widget _buildDataCard(String title, String value, Color color, {bool showIcon = false}) {
    return Expanded(
      child: Container(
        height: 110.h,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (showIcon) ...[
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/cnt_icon.png',
                    fit: BoxFit.cover,
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用全局数据 Controller
    final g = Get.put(GlobalDataController());

    return Scaffold(
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorValue.gradientStart,
                ColorValue.gradientCenter,
                ColorValue.gradientEnd,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  // 顶部栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello,', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Derek Doyle', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20.w,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // 仪表盘
                  Center(
                    child: SizedBox(
                      width: 190.w,
                      height: 190.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 外圈
                          Container(
                            width: 190.w,
                            height: 190.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorValue.progressOutRingBg, width: 5.w),
                            ),
                          ),
                          // 背景圈
                          Container(
                            width: 153.w,
                            height: 153.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorValue.progressRingBg, width: 12.w),
                            ),
                          ),
                          // 动态进度
                          CustomPaint(
                            size: Size(153.w, 153.w),
                            painter: ProgressRingPainter(
                              progress: g.dangerProgress,
                              ringColor: ColorValue.progressRingValue,
                              strokeWidth: 12.w,
                            ),
                          ),
                          // 中心文字
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${g.currentDistance.value.toStringAsFixed(1)}m',
                                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text('Safe Dist', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 数据卡片行
                  Row(
                    children: [
                      _buildDataCard('Total', '${g.totalCount.value}', ColorValue.cardPink, showIcon: true),
                      SizedBox(width: 15.w),
                      _buildDataCard('Avg Dist', '${g.avgDistance.value.toStringAsFixed(2)}m', ColorValue.cardGray),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // 区间计数（保留原有舒适距离样式）
                  Text('Distance Zones', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _buildDataCard('Danger', '${g.dangerCount.value}', Colors.redAccent),
                      SizedBox(width: 10.w),
                      _buildDataCard('Alert', '${g.alertCount.value}', Colors.orangeAccent),
                      SizedBox(width: 10.w),
                      _buildDataCard('Comfort', '${g.comfortableCount.value}', ColorValue.cardGray),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final double strokeWidth;

  ProgressRingPainter({required this.progress, required this.ringColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return progress != oldDelegate.progress || ringColor != oldDelegate.ringColor || strokeWidth != oldDelegate.strokeWidth;
  }
}