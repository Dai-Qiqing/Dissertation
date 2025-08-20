import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../GlobalDataController.dart';
import '../../constants/color_value.dart';

class RealTimeInteractionPage extends StatefulWidget {
  const RealTimeInteractionPage({super.key});

  @override
  State<RealTimeInteractionPage> createState() =>
      _RealTimeInteractionPageState();
}

class _RealTimeInteractionPageState extends State<RealTimeInteractionPage> {
  final g = Get.put(GlobalDataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
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
          child: SafeArea(child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildAppBar(),
        const SizedBox(height: 10),
        _buildDistanceIndicator(),
        const SizedBox(height: 10),
        _buildRadarSection(),
        const SizedBox(height: 10),

        // 六边形雷达图（含历史数据）
        Obx(() {
          // 防止除零导致 NaN
          double normalize(double cur, double low, double high) {
            final range = high - low;
            if (range <= 0) return 0.0;
            return ((cur - low).clamp(0.0, range)) / range;
          }

          // 取出历史距离值
          final distances = g.distanceHistory
              .map((e) => (e['distance'] as double))
              .toList();
          // 取最新 10 条记录
          final history = distances.length <= 10
              ? distances
              : distances.sublist(distances.length - 10);

          final dThr = g.dangerThreshold.value;
          final aThr = g.alertThreshold.value;
          const maxDist = 2.0;

          // 构造历史三元组
          final historyTriples = history.map((d) {
            final c = normalize(d, aThr, maxDist);
            final w = normalize(d, dThr, aThr);
            final dg = normalize(dThr - d, 0.0, dThr);
            return Tuple3(c, w, dg);
          }).toList();

          // 最新值三元组
          final cur = g.currentDistance.value;
          final latestTriple = Tuple3(
            normalize(cur, aThr, maxDist),
            normalize(cur, dThr, aThr),
            normalize(dThr - cur, 0.0, dThr),
          );

          return Container(
            width: 370.w,
            height: 430.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white12, Colors.white12, Colors.white12],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  width: 240.w,
                  height: 240.h,
                  child: CustomPaint(
                    painter: HexagonHistoryPainter(
                      history: historyTriples,
                      latest: latestTriple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildRadarLegend(),
              ],
            ),
          );
        }),

        const SizedBox(height: 10),
        Row(
          children: const [
            SizedBox(width: 15),
            Text(
              'Recent Interactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Obx(() {
          final interactions = g.recentInteractions.value;
          return SizedBox(
            width: 360.w,
            child: Column(
              children: interactions
                  .map((i) =>
                  _buildAlertItem(i.title, i.count.toString(), i.type))
                  .toList(),
            ),
          );
        }),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    centerTitle: true,
    title: const Text(
      'Real-time Interaction',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevation: 0,
  );

  Widget _buildDistanceIndicator() {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB23051),
            Color(0xFFDB3E58),
            Color(0xFFE65387),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          CustomPaint(
            painter: RingProgressPainter(
              progress: g.dangerProgress,
              distance: g.currentDistance.value,
            ),
            size: const Size(150, 150),
          ),
          SizedBox(height: 20.h),
          _buildDistanceLabels(),
        ],
      ),
    );
  }

  Widget _buildDistanceLabels() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDistanceLabel(
              '>${g.alertThreshold.value.toStringAsFixed(2)}m',
              'Comfort',
              Colors.green),
          _buildDistanceLabel(
              '${g.dangerThreshold.value.toStringAsFixed(2)}-${g.alertThreshold.value.toStringAsFixed(2)}m',
              'Warn',
              Colors.yellow),
          _buildDistanceLabel(
              '<${g.dangerThreshold.value.toStringAsFixed(2)}m',
              'Discomfort',
              Colors.red),
        ],
      ),
    );
  }

  Widget _buildRadarSection() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0x00212121),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Text(
          'People Around You',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildRadarLegend() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    children: [
      _legendItem('Comfort', Colors.green),
      _legendItem('Warn', Colors.yellow),
      _legendItem('Danger', Colors.red),
    ],
  );

  Widget _legendItem(String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.white)),
    ],
  );

  Widget _buildDistanceLabel(String dist, String label, Color color) =>
      Column(
        children: [
          Text(dist,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white60)),
        ],
      );

  Widget _buildAlertItem(String title, String time, String type) {
    final isComfort = type == 'comfort';
    return Container(
      height: 85.h,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
          color: ColorValue.alertItemBg,
          borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Image.asset(
            isComfort ? 'assets/alert_icon1.png' : 'assets/alert_icon2.png'),
        title: Text(title,
            style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isComfort
                        ? const Color(0xFF9FC708)
                        : const Color(0xFFEF88ED))),
            SizedBox(width: 5.w),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

/// 简单三元组类
class Tuple3<A, B, C> {
  final A item1;
  final B item2;
  final C item3;
  Tuple3(this.item1, this.item2, this.item3);
}

/// 环形进度 Painter
class RingProgressPainter extends CustomPainter {
  final double progress;
  final double distance;

  RingProgressPainter({
    required this.progress,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final basePaint = Paint()
      ..color = const Color(0xFFCE5871).withOpacity(0.8)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, basePaint);

    final progPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progPaint,
    );

    final tp = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    final main = TextSpan(
        text: "${distance.toStringAsFixed(1)}m",
        style: const TextStyle(
            color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold));
    final status = distance > 1.5
        ? "Comfort Dist"
        : (distance > 1.0 ? "Warn Dist" : "Danger Dist");
    final sub = TextSpan(
        text: status,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600));
    tp.text = TextSpan(children: [main, const TextSpan(text: "\n"), sub]);
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter old) => true;
}

class HexagonHistoryPainter extends CustomPainter {
  final List<Tuple3<double, double, double>> history;
  final Tuple3<double, double, double> latest;

  HexagonHistoryPainter({
    required this.history,
    required this.latest,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2 * 0.8;
    const sides = 6, levels = 5;

    // 1. 六边形网格 - 不变
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white24;
    for (int i = 1; i <= levels; i++) {
      _drawPolygon(canvas, center, maxR * i / levels, sides, gridPaint);
    }

    // 2. 轴线 - 不变
    final axisColors = [
      Colors.green, // Comfort
      Colors.yellow, // Warn
      Colors.red,    // Danger
      Colors.green,
      Colors.yellow,
      Colors.red,
    ];
    for (int i = 0; i < sides; i++) {
      final ang = 2 * pi * i / sides - pi / 2;
      final p = Offset(center.dx + cos(ang) * maxR, center.dy + sin(ang) * maxR);
      final axisPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = axisColors[i].withOpacity(0.7);
      canvas.drawLine(center, p, axisPaint);
    }

    // 3. 历史记录 - 修改为折线形式
    for (int idx = 0; idx < history.length; idx++) {
      final t = history[idx];
      final vals = [t.item1, t.item2, t.item3, t.item1, t.item2, t.item3];
      final path = Path();

      // 为每条历史数据设置不同透明度
      double opacity = 0.1 + 0.1 * (history.length - idx) / history.length;
      final lineColor = Colors.purple.withOpacity(opacity);
      final dotColor = Colors.purple.withOpacity(opacity * 2);

      for (int i = 0; i <= sides; i++) {
        int index = i % sides;
        double ang = 2 * pi * index / sides - pi / 2;
        double r = maxR * vals[index];
        double x = center.dx + cos(ang) * r;
        double y = center.dy + sin(ang) * r;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        // 画每个数据点
        canvas.drawCircle(
          Offset(x, y),
          2.0,
          Paint()
            ..style = PaintingStyle.fill
            ..color = dotColor,
        );
      }

      // 描边连线
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = lineColor,
      );
    }

    // 4. 最新值 - 保持不变
    final l = latest;
    final lvals = [l.item1, l.item2, l.item3, l.item1, l.item2, l.item3];
    final lpath = Path()
      ..moveTo(center.dx + cos(-pi / 2) * maxR * lvals[0],
          center.dy + sin(-pi / 2) * maxR * lvals[0]);
    for (int i = 1; i < sides; i++) {
      final ang = 2 * pi * i / sides - pi / 2;
      lpath.lineTo(center.dx + cos(ang) * maxR * lvals[i],
          center.dy + sin(ang) * maxR * lvals[i]);
    }
    lpath.close();

    // 填充最新区域
    canvas.drawPath(
      lpath,
      Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.3),
    );

    // 描边最新区域
    canvas.drawPath(
      lpath,
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.white,
    );

    // 5. 最新数据点 - 保持不变
    final dotPaint = Paint()..style = PaintingStyle.fill..color = Colors.white;
    for (int i = 0; i < sides; i++) {
      final ang = 2 * pi * i / sides - pi / 2;
      final pt = Offset(center.dx + cos(ang) * maxR * lvals[i],
          center.dy + sin(ang) * maxR * lvals[i]);
      canvas.drawCircle(pt, 4, dotPaint);
    }

    // 6. 标签 - 保持不变
    final lbl = TextPainter(textDirection: TextDirection.ltr);
    const names = ['Comfort', 'Warn', 'Danger'];
    for (int i = 0; i < 3; i++) {
      final ang = 2 * pi * i / sides - pi / 2;
      final pos = Offset(center.dx + cos(ang) * maxR, center.dy + sin(ang) * maxR);
      lbl.text = TextSpan(
          text: names[i], style: const TextStyle(color: Colors.white70, fontSize: 12));
      lbl.layout();
      lbl.paint(canvas,
          pos + Offset(cos(ang) * 10 - lbl.width / 2, sin(ang) * 10 - lbl.height / 2));
    }
  }

  // 绘制多边形的辅助方法 - 保持不变
  void _drawPolygon(Canvas c, Offset ctr, double r, int sides, Paint p) {
    final path = Path();
    for (int i = 0; i <= sides; i++) {
      final ang = 2 * pi * i / sides - pi / 2;
      final x = ctr.dx + cos(ang) * r, y = ctr.dy + sin(ang) * r;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant HexagonHistoryPainter old) =>
      old.history != history || old.latest != latest;
}