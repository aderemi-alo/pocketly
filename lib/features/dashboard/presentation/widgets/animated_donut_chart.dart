import 'dart:math';
import 'package:flutter/material.dart';

class CategoryChartData {
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final IconData icon;

  CategoryChartData({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class AnimatedDonutChart extends StatefulWidget {
  final List<CategoryChartData> data;
  final double size;
  final double strokeWidth;

  const AnimatedDonutChart({
    super.key,
    required this.data,
    this.size = 160,
    this.strokeWidth = 20,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: DonutChartPainter(
            data: widget.data,
            strokeWidth: widget.strokeWidth,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryChartData> data;
  final double strokeWidth;
  final double progress;

  DonutChartPainter({
    required this.data,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Calculate total value
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    // Start angle at top (270 degrees = -90 degrees = top of circle)
    // For anti-clockwise, we'll draw in reverse order
    double startAngle = -pi / 2; // Start at top

    for (final category in data) {
      final sweepAngle = (category.value / total) * 2 * pi * progress;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Draw arc (negative sweep for anti-clockwise)
      canvas.drawArc(
        rect,
        startAngle,
        -sweepAngle, // Negative for anti-clockwise
        false,
        paint,
      );

      startAngle -= sweepAngle; // Subtract for anti-clockwise direction
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
