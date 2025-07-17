import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../GlobalDataController.dart';
import '../../constants/color_value.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final g = Get.put(GlobalDataController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorValue.gradientStart,
              ColorValue.gradientCenter,
              ColorValue.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Device Settings',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                _buildDeviceInfo(),
                SizedBox(height: 40.h),

                // Danger Threshold
                Text(
                  'Danger Threshold (m)',
                  style: TextStyle(fontSize: 18.sp, color: Colors.white),
                ),
                Obx(() {
                  return Slider(
                    min: 0.5,
                    max: 2.0,
                    activeColor: Colors.redAccent,
                    inactiveColor: Colors.white24,
                    label: g.dangerThreshold.value.toStringAsFixed(1),
                    value: g.dangerThreshold.value,
                    onChanged: (v) {
                      // 设置 danger
                      g.dangerThreshold.value = v;
                      // 如果 danger 超过 alert，就同步提升 alert
                      if (v > g.alertThreshold.value) {
                        g.alertThreshold.value = v;
                      }
                    },
                  );
                }),
                Obx(() => Text(
                  '${g.dangerThreshold.value.toStringAsFixed(1)} m',
                  style: TextStyle(color: Colors.white70),
                )),

                SizedBox(height: 30.h),

                // Alert Threshold
                Text(
                  'Alert Threshold (m)',
                  style: TextStyle(fontSize: 18.sp, color: Colors.white),
                ),
                Obx(() {
                  return Slider(
                    min: 0.5,
                    max: 3.0,
                    activeColor: Colors.orangeAccent,
                    inactiveColor: Colors.white24,
                    label: g.alertThreshold.value.toStringAsFixed(1),
                    value: g.alertThreshold.value,
                    onChanged: (v) {
                      // 设置 alert
                      g.alertThreshold.value = v;
                      // 如果 alert 低于 danger，就同步降低 danger
                      if (v < g.dangerThreshold.value) {
                        g.dangerThreshold.value = v;
                      }
                    },
                  );
                }),
                Obx(() => Text(
                  '${g.alertThreshold.value.toStringAsFixed(1)} m',
                  style: TextStyle(color: Colors.white70),
                )),

                Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 1. 发布阈值
                      g.publishThresholds();
                      Get.snackbar(
                        'Saved',
                        'Threshold settings updated',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorValue.gradientEnd,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Save Threshold Settings',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8A5EFF), Color(0xFFEA48EF), Color(0xFF8A5EFF)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.sensors, size: 40.w, color: Colors.white),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SDM-2025-01',
                  style: TextStyle(color: Colors.white, fontSize: 20.sp)),
              SizedBox(height: 4.h),
              Text('Connected',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 14.sp)),
            ],
          ),
        ],
      ),
    );
  }
}
