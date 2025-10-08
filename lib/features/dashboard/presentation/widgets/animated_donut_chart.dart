import 'dart:math';
import 'package:flutter/material.dart';

class CategoryChartData {
  final String categoryId;
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final IconData icon;

  CategoryChartData({
    required this.categoryId,
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
  final Function(String categoryId)? onCategoryTap;

  const AnimatedDonutChart({
    super.key,
    required this.data,
    this.size = 160,
    this.strokeWidth = 20,
    this.onCategoryTap,
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
        return GestureDetector(
          onTapUp: (details) {
            if (widget.onCategoryTap == null) return;

            final categoryId = _getCategoryAtPosition(
              details.localPosition,
              Size(widget.size, widget.size),
            );

            if (categoryId != null) {
              widget.onCategoryTap!(categoryId);
            }
          },
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: DonutChartPainter(
              data: widget.data,
              strokeWidth: widget.strokeWidth,
              progress: _animation.value,
            ),
          ),
        );
      },
    );
  }

  String? _getCategoryAtPosition(Offset position, Size size) {
    if (widget.data.isEmpty) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - widget.strokeWidth) / 2;

    // Calculate distance from center
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // Check if tap is within the donut ring
    final outerRadius = radius + widget.strokeWidth / 2;
    final innerRadius = radius - widget.strokeWidth / 2;

    if (distance < innerRadius || distance > outerRadius) {
      return null; // Tap is outside the donut ring
    }

    // Calculate angle of tap (-π to π, 0 is right)
    var angle = atan2(dy, dx);

    // Convert to start from top (-π/2) and go counter-clockwise
    angle = angle + pi / 2;
    if (angle < 0) angle += 2 * pi;

    // Convert to counter-clockwise by subtracting from 2π
    angle = 2 * pi - angle;

    // Calculate total value
    final total = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    // Calculate gap angle
    final gapAngle = 5.0 / radius;
    final totalGapSpace = widget.data.length * gapAngle;
    final availableAngle = 2 * pi - totalGapSpace;

    // Find which segment was tapped (going counter-clockwise from top)
    double startAngle = 0;

    for (int i = 0; i < widget.data.length; i++) {
      final category = widget.data[i];
      final sweepAngle = (category.value / total) * availableAngle;
      final endAngle = startAngle + sweepAngle;

      if (angle >= startAngle && angle < endAngle) {
        return category.categoryId;
      }

      startAngle = endAngle + gapAngle;
    }

    return null;
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
