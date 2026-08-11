import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecipeCardSkeleton extends StatelessWidget {
  final int count;
  const RecipeCardSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF16213E) : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? const Color(0xFF1A2744) : const Color(0xFFF5F5F5);

    final columns = MediaQuery.of(context).size.width >= 1024
        ? 3
        : MediaQuery.of(context).size.width >= 640
            ? 2
            : 1;
    final aspectRatio = switch (columns) {
      1 => 1.7,
      2 => 1.35,
      _ => 1.15,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: count,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(color: baseColor),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinearSkeleton extends StatelessWidget {
  final double width;
  final double height;
  const LinearSkeleton(
      {super.key, this.width = double.infinity, this.height = 16});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF16213E) : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? const Color(0xFF1A2744) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class PageSkeleton extends StatelessWidget {
  const PageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF16213E)
          : const Color(0xFFE8E8E8),
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A2744)
          : const Color(0xFFF5F5F5),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFE8E8E8),
      ),
    );
  }
}
