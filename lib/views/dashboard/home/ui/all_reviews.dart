import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/home/home_ctrl.dart';

class AllReviews extends StatefulWidget {
  const AllReviews({super.key});

  @override
  State<AllReviews> createState() => _AllReviewsState();
}

class _AllReviewsState extends State<AllReviews> {
  final HomeCtrl ctrl = Get.find<HomeCtrl>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && ctrl.hasMoreReviews.value && !_isLoadingMore) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadInitialReviews() async {
    await ctrl.refreshReviews();
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMore || !ctrl.hasMoreReviews.value) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      await ctrl.loadMoreReviews();
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshReviews() async {
    await ctrl.refreshReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final total = ctrl.totalReviews.value;
          return Row(
            children: [
              Text('All Reviews', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              if (total > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    total.toString(),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ],
          );
        }),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshReviews, tooltip: 'Refresh'),
          SizedBox(width: 8.0),
        ],
      ),
      body: Obx(() {
        if (ctrl.recentReviews.isEmpty && !ctrl.isLoading.value) {
          return _buildEmptyState(context);
        }
        return RefreshIndicator(
          onRefresh: _refreshReviews,
          color: Theme.of(context).colorScheme.primary,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.recentReviews.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == ctrl.recentReviews.length) {
                return _buildLoadMoreIndicator();
              }
              return _buildReviewCard(context, ctrl.recentReviews[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic review) {
    final customerName = review['customerId']?['name']?.toString() ?? 'Customer';
    final comment = review['review']?.toString() ?? '';
    final rating = double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
    final date = _formatReviewDate(review['createdAt']);
    final serviceName = review['subcategoryId']?['name']?.toString() ?? 'Service';
    final reviewId = review['_id']?.toString() ?? '';
    final hasReply = review['vendorResponse'] != null && review['vendorResponse']?['responseText'] != null && review['vendorResponse']!['responseText'].toString().isNotEmpty;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: _getRatingColor(rating).withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      customerName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(color: _getRatingColor(rating), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        serviceName,
                        style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(starIndex < rating.floor() ? Icons.star : Icons.star_border, size: 16, color: Theme.of(context).colorScheme.primary);
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(date, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getRatingColor(rating).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: _getRatingColor(rating)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (comment.isNotEmpty) Text(comment, style: GoogleFonts.poppins(fontSize: 14, height: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
            if (hasReply)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.reply, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Your Reply',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                            ),
                            const Spacer(),
                            Text(_formatReviewDate(review['vendorResponse']['respondedAt']), style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review['vendorResponse']['responseText'].toString(), style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              )
            else if (!hasReply)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showReplyDialog(context, reviewId),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!ctrl.hasMoreReviews.value) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: _isLoadingMore
            ? Column(
                children: [
                  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary))),
                  const SizedBox(height: 12),
                  Text('Loading more reviews...', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Scroll for more', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.reviews_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text('No Reviews Yet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              'Customer reviews will appear here\nonce they rate your services',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Refresh', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
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

  void _showReplyDialog(BuildContext context, dynamic review) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to Review', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: replyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () async {
                await ctrl.reviewsRespond(responseText: replyController.text, reviewId: review["_id"]);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Send Reply', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}
