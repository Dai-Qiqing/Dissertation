import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../GlobalDataController.dart';
import '../../constants/color_value.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final g = Get.find<GlobalDataController>();

    return Scaffold(
      body: Container(
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
          child: Obx(() {

            // 从 distanceDurations 构造列表项
            final items = g.distanceDurations.entries.map((e) {
              final dist = e.key;
              final dur  = e.value;

              // 红色 = 危险距离；黄色 = 紧张距离；绿色 = 舒适距离
              final isDanger   = dist < g.dangerThreshold.value;
              final isAlert    = dist >= g.dangerThreshold.value && dist < g.alertThreshold.value;
              final dotColor   = isDanger   ? Colors.redAccent
                  : isAlert    ? Colors.orangeAccent
                  : Colors.greenAccent;
              final title = isDanger   ? "Personal Space Intrusion"
                  : isAlert    ? "Approaching comfort limits"
                  : "Approaching comfort";
              final textColor  = dotColor; // 同色
              final riskLabel  = isDanger   ? 'Hi Risk'
                  : isAlert    ? 'Med Risk'
                  : 'Comfort';

              return {
                'title': '$title\n${dist.toStringAsFixed(1)}m @ ${dur}s',
                'risk': riskLabel,
                'dotColor': dotColor,
                'riskTextColor': textColor,
              };
            }).toList();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildDataCards(g),
                  SizedBox(height: 24.h),
                  Text(
                    "Distance Over Time",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildLegend(),
                  SizedBox(height: 8.h),
                  _buildChartSection(g),
                  SizedBox(height: 24.h),
                  // 最后，用警报日志样式显示每条 distance/duration
                  ...items.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _buildAlertCard(
                      title: item['title'] as String,
                      riskLabel: item['risk'] as String,
                      dotColor: item['dotColor'] as Color,
                      riskTextColor: item['riskTextColor'] as Color,
                    ),
                  )),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Historical Data Analysis',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDataCards(GlobalDataController g) {
    return SizedBox(
      height: 260.h,
      child: Column(
        children: [
          _buildDataCard(
            'Danger',
            '${g.dangerCount.value}',
            Colors.redAccent,
            Icons.warning,
            g.dangerCount.value / g.totalCount.value,
            true,
          ),
          SizedBox(height: 15.w),
          Row(
            children: [
              _buildDataCard(
                'Alert',
                '${g.alertCount.value}',
                Colors.orangeAccent,
                Icons.warning_amber,
                g.alertCount.value / g.totalCount.value,
                false,
              ),
              SizedBox(width: 16.w),
              _buildDataCard(
                'Comfort',
                '${g.comfortableCount.value}',
                Color(0xFF81C784),
                Icons.sentiment_satisfied,
                g.comfortableCount.value / g.totalCount.value,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, Color color, IconData icon,
      double progress, bool isRowCard) {
    return Expanded(
      child: Container(
        height: isRowCard ? 30.h : 150.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Color(0xFF372545),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRowCard)
              Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRowCard)
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18.w),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      width: isRowCard ? 210.w : 85.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('Danger', Colors.redAccent),
        SizedBox(width: 16.w),
        _legendItem('Alert', Colors.orangeAccent),
        SizedBox(width: 16.w),
        _legendItem('Comfort', Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildChartSection(GlobalDataController g) {
    final history = g.distanceHistory;
    if (history.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: Colors.white70)));
    }

    final maxDist = history
        .map((e) => e['distance'] as double)
        .fold<double>(0.0, (prev, d) => d > prev ? d : prev);

    return SizedBox(
      height: 200.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: history.asMap().entries.map((entry) {
            final e = entry.value;
            final d = (e['distance'] as double).clamp(0.0, maxDist);
            final ratio = maxDist > 0 ? d / maxDist : 0.0;
            final barColor = d < g.dangerThreshold.value
                ? Colors.redAccent
                : (d < g.alertThreshold.value ? Colors.orangeAccent : Color(0xFF4CAF50));

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 10.w,
                    height: (ratio * 150).h,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 警报日志样式卡片，用于展示 distance/duration/risk
  Widget _buildAlertCard({
    required String title,
    required String riskLabel,
    required Color dotColor,
    required Color riskTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorValue.alertItemBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: const SizedBox.shrink(),
        trailing: Text(
          riskLabel,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: riskTextColor),
        ),
      ),
    );
  }
}
