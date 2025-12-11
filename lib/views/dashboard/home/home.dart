import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/config/app_assets.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/chat/chat.dart';
import 'package:homenest_vendor/views/dashboard/dashboard_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/home/home_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/notifications/notifications.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeCtrl ctrl = Get.put(HomeCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.vendorData.isEmpty) {
                  return _buildLoadingState(context);
                }
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () => ctrl.loadDashboardData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileCard(context),
                        const SizedBox(height: 20),
                        _buildStatsGrid(context),
                        const SizedBox(height: 20),
                        _buildPerformanceMetrics(context),
                        const SizedBox(height: 20),
                        _buildRecentReviews(context),
                        const SizedBox(height: 20),
                      ],
                    ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
              ),
              Obx(() => Text(ctrl.businessName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ],
          ),
          const Spacer(),
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            ),
            icon: Image.asset(AppAssets.messageIcon, width: 24),
            onPressed: () => Get.to(() => const Chat(partnerName: "Admin")),
            tooltip: 'Notification',
          ),
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            ),
            icon: Image.asset(AppAssets.notificationIcon, width: 24),
            onPressed: () => Get.to(() => const Notifications()),
            tooltip: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Loading Dashboard...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.05), Theme.of(context).colorScheme.secondary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    image: ctrl.profileImage.isNotEmpty ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + ctrl.profileImage), fit: BoxFit.cover) : null,
                  ),
                  child: ctrl.profileImage.isEmpty ? Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimaryContainer) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, shape: BoxShape.circle),
                    child: _buildStatusIndicator(context),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.vendorName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.businessName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [_buildRatingBadge(context), const Spacer(), _buildViewProfileButton(context)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Obx(() {
      final isApproved = ctrl.isApproved;
      final status = ctrl.verificationStatus;
      Color color;
      IconData icon;
      if (isApproved) {
        color = Colors.green;
        icon = Icons.verified;
      } else if (status == 'pending') {
        color = Colors.orange;
        icon = Icons.pending;
      } else {
        color = Colors.red;
        icon = Icons.cancel;
      }
      return Icon(icon, size: 12, color: color);
    });
  }

  Widget _buildRatingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            ctrl.rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildViewProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<DashboardCtrl>().onTabChange(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 14, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.8),
      children: [
        _buildStatCard(context, title: 'Total Orders', value: ctrl.totalOrders.toString(), icon: Icons.shopping_bag_outlined, color: Colors.blue),
        _buildStatCard(context, title: 'Completed Jobs', value: ctrl.completedJobs.toString(), icon: Icons.work_history_outlined, color: Colors.green),
        _buildStatCard(context, title: 'Pending Orders', value: ctrl.pendingOrders.toString(), icon: Icons.pending_actions_outlined, color: Colors.orange),
        _buildStatCard(context, title: 'Total Earnings', value: '₹${ctrl.totalEarnings.toStringAsFixed(0)}', icon: Icons.currency_rupee_outlined, color: Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Metrics', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(context, title: 'Completion Rate', value: '${ctrl.completionRate.toStringAsFixed(0)}%', icon: Icons.check_circle_outline, color: Colors.green),
              ),
              Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              Expanded(
                child: _buildMetricItem(context, title: 'Response Rate', value: '${ctrl.responseRate.toStringAsFixed(0)}%', icon: Icons.quickreply_outlined, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentReviews(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Recent Reviews', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (ctrl.recentReviews.isNotEmpty)
                  TextButton(
                    onPressed: () => Get.toNamed('/reviews'),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (ctrl.recentReviews.isEmpty) _buildEmptyReviews(context) else Column(children: ctrl.recentReviews.take(3).map((review) => _buildReviewItem(context, review)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviews(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.reviews_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text('No Reviews Yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text('Your reviews will appear here', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, dynamic review) {
    final rating = double.tryParse((review['rating'] ?? '0').toString()) ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review['customerName'] ?? 'Customer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStarRating(rating, context),
            ],
          ),
          const SizedBox(height: 6),
          Text(review['comment']?.toString().trim() ?? 'No comment provided', style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(_formatDate(review['createdAt']), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < rating.floor() ? Icons.star : Icons.star_border, size: 14, color: Theme.of(context).colorScheme.primary);
      }),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Recently';
    try {
      final parsedDate = DateTime.tryParse(date.toString());
      if (parsedDate == null) return 'Recently';
      final now = DateTime.now();
      final difference = now.difference(parsedDate);
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
