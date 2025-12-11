  import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({super.key, this.width = double.infinity, required this.height}) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({super.key, required this.width, required this.height, this.shapeBorder = const CircleBorder()});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(color: Colors.grey[400]!, shape: shapeBorder),
      ),
    );
  }
}

class ShimmerProfileHeader extends StatelessWidget {
  const ShimmerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const ShimmerWidget.circular(width: 100, height: 100),
          const SizedBox(height: 16),
          ShimmerWidget.rectangular(width: 150, height: 20),
          const SizedBox(height: 8),
          ShimmerWidget.rectangular(width: 200, height: 15),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget.rectangular(width: 80, height: 25),
              const SizedBox(width: 8),
              ShimmerWidget.rectangular(width: 60, height: 25),
              const SizedBox(width: 8),
              ShimmerWidget.rectangular(width: 100, height: 25),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerQuickStats extends StatelessWidget {
  const ShimmerQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          const ShimmerWidget.circular(width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ShimmerWidget.rectangular(width: 100, height: 15), const SizedBox(height: 8), ShimmerWidget.rectangular(width: 80, height: 20)],
            ),
          ),
          ShimmerWidget.rectangular(width: 80, height: 30),
        ],
      ),
    );
  }
}

class ShimmerExpandableCard extends StatelessWidget {
  const ShimmerExpandableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerWidget.circular(width: 24, height: 24),
              const SizedBox(width: 12),
              ShimmerWidget.rectangular(width: 150, height: 20),
              const Spacer(),
              const ShimmerWidget.circular(width: 24, height: 24),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const ShimmerWidget.circular(width: 24, height: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ShimmerWidget.rectangular(width: 120, height: 14), const SizedBox(height: 6), ShimmerWidget.rectangular(height: 12)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerActionButton extends StatelessWidget {
  const ShimmerActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ListTile(
        leading: const ShimmerWidget.circular(width: 40, height: 40),
        title: ShimmerWidget.rectangular(height: 16),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: ShimmerWidget.rectangular(height: 12)),
        trailing: const ShimmerWidget.circular(width: 24, height: 24),
      ),
    );
  }
}
