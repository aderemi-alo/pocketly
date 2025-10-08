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

    // Start animation with 1 second delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset animation when data changes
    if (oldWidget.data != widget.data) {
      _controller.reset();
      if (mounted) {
        _controller.forward();
      }
    }
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
    // Don't render anything if progress is 0 or data is empty
    if (progress <= 0 || data.isEmpty) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Calculate total value
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    // Calculate gap angle in radians (5 pixels converted to radians)
    final gapAngle = 5.0 / radius; // 5 pixel gap converted to radians

    // Calculate total gap space needed (number of gaps = number of sections)
    final totalGapSpace = data.length * gapAngle;

    // Calculate the total available angle minus gaps
    final availableAngle = (2 * pi * progress) - totalGapSpace;

    // Don't render if available angle is too small
    if (availableAngle <= 0) {
      return;
    }

    // Start angle at top (270 degrees = -90 degrees = top of circle)
    // For anti-clockwise, we'll draw in reverse order
    double startAngle = -pi / 2; // Start at top

    for (int i = 0; i < data.length; i++) {
      final category = data[i];

      // Calculate proportional sweep angle based on available space
      final proportionalSweepAngle = (category.value / total) * availableAngle;

      // Skip sections that are too small to render
      if (proportionalSweepAngle <= 0) {
        continue;
      }

      final paint = Paint()
        ..color = category.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Draw arc (negative sweep for anti-clockwise)
      canvas.drawArc(
        rect,
        startAngle,
        -proportionalSweepAngle, // Negative for anti-clockwise
        false,
        paint,
      );

      // Move to next section position (subtract sweep angle and gap)
      startAngle -=
          (proportionalSweepAngle +
          gapAngle); // Subtract for anti-clockwise direction
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
