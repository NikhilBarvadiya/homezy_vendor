import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/config/app_assets.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/chat/chat.dart';
import 'package:homenest_vendor/views/dashboard/home/home_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/home/ui/all_reviews.dart';
import 'package:homenest_vendor/views/dashboard/notifications/notifications.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeCtrl ctrl = Get.put(HomeCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          spacing: 10.0,
          children: [
            _buildAppBar(context),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.vendorData.isEmpty) {
                  return _buildFullPageShimmer(context);
                }
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () => ctrl.loadDashboardData(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: _buildStatsGrid(context)),
                      SliverToBoxAdapter(child: _buildPerformanceMetrics(context)),
                      SliverToBoxAdapter(child: _buildReviewsHeader(context)),
                      if (ctrl.recentReviews.isEmpty)
                        SliverToBoxAdapter(child: _buildEmptyReviews(context))
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildReviewCard(context, ctrl.recentReviews[index]),
                            childCount: ctrl.recentReviews.length > 3 ? 3 : ctrl.recentReviews.length,
                          ),
                        ),
                      if (ctrl.recentReviews.isNotEmpty) SliverToBoxAdapter(child: _buildViewAllReviewsButton(context)),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  image: ctrl.profileImage.isNotEmpty ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + ctrl.profileImage), fit: BoxFit.cover) : null,
                ),
                child: ctrl.profileImage.isEmpty ? Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, shape: BoxShape.circle),
                  child: _buildVerificationBadge(context),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return Container(
                    width: 100,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  );
                }
                return Text(
                  ctrl.vendorName.toString().capitalizeFirst.toString(),
                  style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: () => Get.to(() => const Notifications()),
                icon: Image.asset(AppAssets.notificationIcon, width: 24, color: Theme.of(context).colorScheme.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Get.to(() => const Chat(partnerName: "Admin")),
            icon: Image.asset(AppAssets.messageIcon, width: 24, color: Theme.of(context).colorScheme.onSurface),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          _buildStatCard(context, icon: Icons.shopping_bag_outlined, title: 'Total Orders', value: ctrl.totalOrders.toString(), color: Colors.blue, subtitle: '${ctrl.acceptedOrders} accepted'),
          _buildStatCard(
            context,
            icon: Icons.work_outline,
            title: 'Completed Jobs',
            value: ctrl.completedJobs.toString(),
            color: Colors.green,
            subtitle: '${ctrl.completionRate.toStringAsFixed(0)}% rate',
          ),
          _buildStatCard(context, icon: Icons.pending_actions_outlined, title: 'Pending Orders', value: ctrl.pendingOrders.toString(), color: Colors.orange, subtitle: 'Need attention'),
          _buildStatCard(context, icon: Icons.currency_rupee, title: 'Today\'s Earnings', value: '₹${ctrl.totalEarnings.toStringAsFixed(0)}', color: Colors.purple, subtitle: 'All time earnings'),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String title, required String value, required Color color, String subtitle = ''}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        spacing: 6.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Metrics',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'This Month',
                  style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(context, title: 'Completion Rate', value: '${ctrl.completionRate.toStringAsFixed(0)}%', progress: ctrl.completionRate / 100, color: Colors.green),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMetricItem(context, title: 'Response Rate', value: '${ctrl.responseRate.toStringAsFixed(0)}%', progress: ctrl.responseRate / 100, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(context, title: 'Customer Rating', value: ctrl.rating.toStringAsFixed(1), progress: ctrl.rating / 5, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, {required String title, required String value, required double progress, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${(progress * 100).toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ),
      ],
    );
  }

  Widget _buildReviewsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Reviews',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          Obx(() {
            if (ctrl.recentReviews.isEmpty) return const SizedBox();
            return Text('${ctrl.recentReviews.length} reviews', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)));
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic review) {
    final customerName = review['customerId']['name']?.toString() ?? 'Customer';
    final comment = review['review']?.toString() ?? '';
    final rating = double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
    final date = _formatReviewDate(review['createdAt']);
    final serviceName = review['subcategoryId']['name']?.toString() ?? 'Service';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                  child: Center(
                    child: Text(
                      customerName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
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
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
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
            if (comment.isNotEmpty)
              Text(
                comment,
                style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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

  Widget _buildEmptyReviews(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(Icons.reviews_outlined, size: 60, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer reviews will appear here\nonce they rate your services',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllReviewsButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => Get.to(() => AllReviews()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('View All Reviews', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPageShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    2,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade100),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 150,
                          height: 16,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: List.generate(4, (index) => _buildStatCardShimmer(context)),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(2, (index) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildMetricItemShimmer(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildMetricItemShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 16,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
          ),
        ),
      ],
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

  Widget _buildVerificationBadge(BuildContext context) {
    final isVerified = ctrl.isApproved;
    return Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, size: 10, color: isVerified ? Colors.green : Colors.orange);
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
