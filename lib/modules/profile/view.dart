import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../GlobalDataController.dart';
import '../../constants/color_value.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 只使用全局数据
    final g = Get.put(GlobalDataController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 标题
                Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),

                // 头像
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF18032F), width: 3.w),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/default_avatar.png', fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 12.h),

                // 用户名（静态示例）
                Text(
                  'Derek Doyle',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20.h),

                // 两个统计卡片：使用全局数据 comfort 和 alert 比例
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Obx(() {
                    final total = g.totalCount.value == 0 ? 1 : g.totalCount.value;
                    final comfortPct = (g.comfortableCount.value / total * 100).toStringAsFixed(0) + '%';
                    final alertPct   = (g.alertCount.value    / total * 100).toStringAsFixed(0) + '%';
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Comfort Zone',
                            value: comfortPct,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Alert Zone',
                            value: alertPct,
                            color: const Color(0xFFF44336),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 20.h),

                // 反馈提醒（静态示例，开关不绑定）
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.white24, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white70),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          'Feedback Reminder',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      Obx(() => Switch(
                        value: g.feedbackReminder.value,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (v) => g.feedbackReminder.value = v,
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 个人信息入口（静态示例）
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.white24, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.white70),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          'Personal Information',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ],
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white24, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
          SizedBox(height: 5.h),
          Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
