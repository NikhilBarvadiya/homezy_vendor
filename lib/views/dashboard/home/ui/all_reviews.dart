import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/home/home_ctrl.dart';

class AllReviews extends StatelessWidget {
  AllReviews({super.key});

  final HomeCtrl ctrl = Get.find<HomeCtrl>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Reviews', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Obx(() {
        if (ctrl.recentReviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.reviews_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                const SizedBox(height: 20),
                Text('No Reviews Yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Your reviews will appear here', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.recentReviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildReviewCard(context, ctrl.recentReviews[index]);
          },
        );
      }),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic review) {
    final customerName = review['customerId']['name']?.toString() ?? 'Customer';
    final comment = review['review']?.toString() ?? '';
    final rating = double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
    final date = _formatReviewDate(review['createdAt']);
    final serviceName = review['subcategoryId']['name']?.toString() ?? 'Service';
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    customerName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      Text(serviceName, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getRatingColor(rating).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 14, color: _getRatingColor(rating)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: _getRatingColor(rating)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return Icon(index < rating.floor() ? Icons.star : Icons.star_border, size: 16, color: Theme.of(context).colorScheme.primary);
              }),
            ),
            const SizedBox(height: 12),
            if (comment.isNotEmpty) Text(comment, style: GoogleFonts.poppins(height: 1.5)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                if (review['vendorResponse'] == null || review['vendorResponse']['responseText'].toString().isEmpty)
                  GestureDetector(
                    onTap: () {
                      _showReplyDialog(context, review);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 12, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (review['vendorResponse'] != null && review['vendorResponse']['responseText'] != null && review['vendorResponse']['responseText'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.reply, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Your Reply',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                review['vendorResponse']["responseText"].toString(),
                                style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                              ),
                            ),
                            Text(
                              _formatReviewDate(review['vendorResponse']["respondedAt"].toString()),
                              style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _formatReviewDate(dynamic date) {
    if (date == null) return 'Recently';
    try {
      final parsedDate = DateTime.tryParse(date.toString());
      if (parsedDate == null) return 'Recently';
      final now = DateTime.now();
      final difference = now.difference(parsedDate);
      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _showReplyDialog(BuildContext context, dynamic review) {}
}
