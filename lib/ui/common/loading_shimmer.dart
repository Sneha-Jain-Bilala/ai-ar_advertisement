import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Shimmer loading placeholder widget for skeleton UIs
class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Card-shaped shimmer placeholder
  const LoadingShimmer.card({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = 16,
  });

  /// Circle shimmer (for avatars)
  const LoadingShimmer.circle({
    super.key,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 24,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                AppColors.surfaceSecondary,
                AppColors.border,
                AppColors.surfaceSecondary,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A column of shimmer lines that mimics text content loading
class LoadingShimmerGroup extends StatelessWidget {
  final int lineCount;
  final double spacing;

  const LoadingShimmerGroup({
    super.key,
    this.lineCount = 3,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lineCount, (index) {
        final isLast = index == lineCount - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: LoadingShimmer(
            width: isLast ? 160 : double.infinity,
            height: 14,
          ),
        );
      }),
    );
  }
}
