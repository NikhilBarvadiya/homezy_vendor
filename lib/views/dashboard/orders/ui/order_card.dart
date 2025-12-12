import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/orders/orders_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/orders/ui/order_details.dart';

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final OrdersCtrl orderController;

  const OrderCard({super.key, required this.order, required this.orderController});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order['status'] ?? 'pending';
    final customer = order['customer'] ?? {};
    final service = order['service'] ?? {};
    final slot = order['slot'] ?? {};
    final payment = order['payment'] ?? {};
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    _getStatusText(status).toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${order['orderNumber'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                ),
                IconButton(
                  onPressed: () => Get.to(() => OrderDetails(orderController: widget.orderController, order: widget.order)),
                  icon: Icon(Icons.visibility_rounded, size: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        image: service['image'] != null ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + service['image']), fit: BoxFit.cover) : null,
                      ),
                      child: service['image'] == null ? Center(child: Icon(Icons.home_repair_service, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5))) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'] ?? 'Service',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(service['category'] ?? 'Category', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          const SizedBox(height: 8),
                          Text(
                            '₹${order['totalPrice'] ?? '0'}',
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoCard(icon: Icons.person_outline, title: 'Customer', value: customer['name'] ?? 'N/A'),
                    const SizedBox(width: 12),
                    _buildInfoCard(icon: Icons.access_time, title: 'Time', value: slot['displayTime'] ?? 'Not scheduled'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActionButtons(order, status, payment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, String status, Map<String, dynamic> payment) {
    return Row(
      spacing: 10.0,
      children: [
        if (status == 'accepted') ...[
          if (payment['mode'] == 'cash' && payment['status'] == 'pending')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCollectCashDialog(order),
                icon: const Icon(Icons.money, size: 16),
                label: const Text('Collect Cash', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showCompleteConfirmation(order),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Complete', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCollectCashDialog(Map<String, dynamic> order) {
    final payment = order['payment'] ?? {};
    final TextEditingController notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Collect Cash Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '₹${payment['amount'] ?? '0'}',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              widget.orderController.collectCashPayment(paymentId: payment['_id'], notes: notesController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Order', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text('Mark this order as completed?', style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('This action cannot be undone.', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.close(1),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              widget.orderController.completeOrder(order['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
