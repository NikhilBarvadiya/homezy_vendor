import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/orders/orders_ctrl.dart';
import 'package:intl/intl.dart';

class OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;
  final OrdersCtrl orderController;

  const OrderDetails({super.key, required this.order, required this.orderController});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final customer = order['customer'] ?? {};
    final service = order['service'] ?? {};
    final slot = order['slot'] ?? {};
    final payment = order['payment'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('#${order['orderNumber'] ?? 'N/A'}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              _getStatusText(status).toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _getStatusColor(status)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceCard(context, service, order),
            const SizedBox(height: 20),
            _buildSectionTitle('Customer Information'),
            _buildCustomerCard(context, customer),
            const SizedBox(height: 20),
            _buildSectionTitle('Service Details'),
            _buildServiceDetailsCard(context, service, slot),
            const SizedBox(height: 20),
            if (payment.isNotEmpty) ...[_buildSectionTitle('Payment Information'), _buildPaymentCard(context, payment), const SizedBox(height: 20)],
            _buildSectionTitle('Order Summary'),
            _buildOrderSummaryCard(context, order),
            const SizedBox(height: 30),
            if (status == 'accepted') ...[_buildActionButtons(context, order, payment), const SizedBox(height: 20)],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service, Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(service['category'] ?? 'Category', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Text(
                    '₹${order['totalPrice'] ?? '0'}',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Map<String, dynamic> customer) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
            contentPadding: EdgeInsets.only(top: 2, left: 15),
            title: Text(customer['name'] ?? 'N/A', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text('Customer', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Phone', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['mobileNo'] ?? 'N/A',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Email', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['email'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(BuildContext context, Map<String, dynamic> service, Map<String, dynamic> slot) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
        child: Column(
          children: [
            _buildDetailRow(context: context, icon: Icons.access_time, label: 'Scheduled Time', value: slot['displayTime'] ?? 'Not scheduled'),
            const Divider(),
            _buildDetailRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: slot['date'] != null ? DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(slot['date'])) : 'Not scheduled',
            ),
            const Divider(),
            _buildDetailRow(context: context, icon: Icons.engineering, label: 'Service Type', value: service['name'] ?? 'Service'),
            if (service['description'] != null) ...[
              const Divider(),
              _buildDetailRow(context: context, icon: Icons.description, label: 'Description', value: service['description'] ?? '', isMultiLine: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> payment) {
    final status = payment['status'] ?? 'pending';
    final statusColor = _getPaymentColor(status);
    final statusText = _getPaymentStatusText(status);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10.0,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(_getPaymentIcon(status), color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${payment['amount'] ?? '0'}',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                      ),
                      Text(payment['mode'] == 'online' ? 'Online Payment' : 'Cash Payment', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    statusText.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            if (payment['transactionId'] != null && payment['transactionId'] != "") ...[
              const Divider(),
              _buildDetailRow(context: context, icon: Icons.receipt, label: 'Transaction ID', value: payment['transactionId'] ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          children: [
            _buildSummaryRow(context: context, label: 'Order Number', value: '#${order['orderNumber'] ?? 'N/A'}'),
            const Divider(),
            _buildSummaryRow(context: context, label: 'Order Date', value: order['createdAt'] != null ? DateFormat('MMMM dd, yyyy • hh:mm a').format(DateTime.parse(order['createdAt'])) : 'N/A'),
            const Divider(),
            _buildSummaryRow(
              context: context,
              label: 'Total Amount',
              value: '₹${order['totalPrice'] ?? '0'}',
              valueStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> order, Map<String, dynamic> payment) {
    return Column(
      children: [
        if (payment['mode'] == 'cash' && payment['status'] == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _showCollectCashDialog(order, context);
              },
              icon: const Icon(Icons.money, size: 18),
              label: const Text('Collect Cash Payment', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (payment['mode'] == 'cash' && payment['status'] == 'pending') const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _showCompleteConfirmation(order, context);
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Mark as Completed', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({required BuildContext context, required IconData icon, required String label, required String value, bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: isMultiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required BuildContext context, required String label, required String value, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          Text(value, style: valueStyle ?? GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showCollectCashDialog(Map<String, dynamic> order, BuildContext context) {
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
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              orderController.collectCashPayment(paymentId: payment['_id'], notes: notesController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(Map<String, dynamic> order, BuildContext context) {
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
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              orderController.completeOrder(order['_id']);
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

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'success':
        return 'Successful';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}
