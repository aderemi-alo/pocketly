import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class WeeklySpendingData {
  final String date;
  final double amount;

  const WeeklySpendingData({required this.date, required this.amount});
}

class AnimatedBarChart extends StatefulWidget {
  final List<WeeklySpendingData> data;
  final double height;

  const AnimatedBarChart({super.key, required this.data, this.height = 200});

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Start animation with slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedBarChart oldWidget) {
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
    if (widget.data.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        child: const TextWidget(
          text: 'No data yet',
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      );
    }

    // Find max value for scaling
    final maxAmount = widget.data
        .map((d) => d.amount)
        .reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.data.map((dayData) {
                    return Expanded(
                      child: _buildBar(
                        dayData.amount,
                        maxAmount,
                        _animation.value,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.data.map((dayData) {
                  return Expanded(
                    child: Center(
                      child: TextWidget(
                        text: dayData.date,
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(double amount, double maxAmount, double progress) {
    final normalizedHeight = maxAmount > 0 ? amount / maxAmount : 0.0;
    final animatedHeight = normalizedHeight * progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Amount label above bar
          context.verticalSpace(10),
          // Bar container
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: constraints.maxHeight * animatedHeight,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
