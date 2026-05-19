import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:white_tv/core/theme/colors.dart';

/// 骨架屏載入效果
/// 參照: docs/spec/UI_UX.md Section 14.1

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: _SkeletonBox(width: 150, height: 40),
          ),
          ...List.generate(3, (_) => const _CategoryRowSkeleton()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CategoryRowSkeleton extends StatelessWidget {
  const _CategoryRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _SkeletonBox(width: 100, height: 24),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const _SkeletonBox(
              width: 140,
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.cardBackground,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
