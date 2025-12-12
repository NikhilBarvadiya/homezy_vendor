import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:intl/intl.dart';

class BookingDetails extends StatelessWidget {
  final dynamic booking;
  final AvailableBookingsCtrl bookingsCtrl;

  const BookingDetails({super.key, required this.booking, required this.bookingsCtrl});

  @override
  Widget build(BuildContext context) {
    final customer = booking['customer'] ?? {};
    final subcategory = booking['subcategory'] ?? {};
    final slot = booking['slot'] ?? {};
    final payment = booking['payment'] ?? {};
    final isDisabled = booking['isDisabled'] == true;
    final urgency = booking['urgency'] ?? 'normal';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(context, subcategory),
              title: Text('Booking Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
              onPressed: () => Get.close(1),
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface.withOpacity(0.2))),
            ),
            actions: [
              if (urgency == 'high')
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'URGENT',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceCard(context, subcategory, booking),
                  const SizedBox(height: 20),
                  _buildCustomerCard(context, customer),
                  const SizedBox(height: 20),
                  _buildBookingDetailsCard(context, slot, subcategory),
                  const SizedBox(height: 20),
                  if (payment.isNotEmpty) _buildPaymentCard(context, payment),
                  const SizedBox(height: 20),
                  if (!isDisabled) _buildActionButtons(context, booking),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, dynamic subcategory) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.9), Theme.of(context).colorScheme.primary.withOpacity(0.7)],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: subcategory['image'] != null
          ? Image.network(APIConfig.resourceBaseURL + subcategory['image'], fit: BoxFit.cover)
          : Center(child: Icon(Icons.home_repair_service, size: 80, color: Theme.of(context).colorScheme.surface.withOpacity(0.8))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic subcategory, dynamic booking) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                image: subcategory['image'] != null ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + subcategory['image']), fit: BoxFit.cover) : null,
              ),
              child: subcategory['image'] == null ? Center(child: Icon(Icons.home_repair_service, size: 40, color: Theme.of(context).colorScheme.primary)) : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subcategory['name'] ?? 'Service', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subcategory['category']?['name'] ?? 'Category', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 2),
                  Text(
                    '₹${booking['totalPrice'] ?? subcategory['basePrice'] ?? '0'}',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, dynamic customer) {
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
            _buildSectionTitle('Customer Information'),
            _buildDetailRow(context: context, icon: Icons.person_outline, label: 'Name', value: customer['name'] ?? 'N/A'),
            const SizedBox(height: 15),
            _buildDetailRow(context: context, icon: Icons.phone, label: 'Phone', value: customer['mobileNo'] ?? 'N/A', isPhone: true),
            if (customer['email'] != null && customer['email'].isNotEmpty) ...[
              const SizedBox(height: 15),
              _buildDetailRow(context: context, icon: Icons.email, label: 'Email', value: customer['email']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context, dynamic slot, dynamic subcategory) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Booking Details'),
            _buildDetailRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: slot['date'] != null ? DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(slot['date'])) : 'Not scheduled',
            ),
            const SizedBox(height: 15),
            _buildDetailRow(context: context, icon: Icons.access_time, label: 'Time Slot', value: slot['displayTime'] ?? 'Not scheduled'),
            const SizedBox(height: 15),
            _buildDetailRow(context: context, icon: Icons.schedule, label: 'Duration', value: subcategory['duration'] != null ? '${subcategory['duration']} minutes' : 'Standard'),
            if (subcategory['description'] != null && subcategory['description'].isNotEmpty) ...[
              const SizedBox(height: 15),
              _buildDetailRow(context: context, icon: Icons.description, label: 'Description', value: subcategory['description'], isMultiLine: true),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Payment Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    statusText.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(_getPaymentIcon(status), size: 26, color: statusColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${payment['amount'] ?? '0'}',
                        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                      ),
                      Text(payment['mode'] == 'online' ? 'Online Payment' : 'Cash Payment', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
              ],
            ),
            if (payment['transactionId'] != null && payment['transactionId'].isNotEmpty) ...[
              const SizedBox(height: 15),
              _buildDetailRow(context: context, icon: Icons.receipt, label: 'Transaction ID', value: payment['transactionId']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(booking),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.3), width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close, size: 18),
                const SizedBox(width: 10),
                Text('Reject', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showAcceptDialog(booking),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 18),
                const SizedBox(width: 10),
                Text('Accept', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({required BuildContext context, required IconData icon, required String label, required String value, bool isPhone = false, bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isPhone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
                maxLines: isMultiLine ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog(dynamic booking) {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, size: 40, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text('Accept Booking', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to accept this booking?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OutlinedButton(
                        onPressed: () => Get.close(1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.close(1);
                        bookingsCtrl.acceptBooking(booking['_id']);
                        Get.close(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(dynamic booking) {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.close, size: 40, color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 20),
              Text('Reject Booking', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to reject this booking?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OutlinedButton(
                        onPressed: () => Get.close(1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.close(1);
                        bookingsCtrl.rejectBooking(booking['_id']);
                        Get.close(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
