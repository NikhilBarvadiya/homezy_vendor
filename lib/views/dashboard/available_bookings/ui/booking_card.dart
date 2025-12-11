import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';

class BookingCard extends StatefulWidget {
  final dynamic booking;
  final AvailableBookingsCtrl bookingsCtrl;

  const BookingCard({super.key, this.booking, required this.bookingsCtrl});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  @override
  Widget build(BuildContext context) {
    final customer = widget.booking['customer'] ?? {};
    final subcategory = widget.booking['subcategory'] ?? {};
    final slot = widget.booking['slot'] ?? {};
    final payment = widget.booking['payment'] ?? {};
    final bool isDisabled = widget.booking['isDisabled'] == true;
    final isExpanded = widget.booking['isExpanded'] ?? false;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: AbsorbPointer(
        absorbing: isDisabled,
        child: Card(
          elevation: isDisabled ? 0 : 1,
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDisabled ? Theme.of(context).colorScheme.outline.withOpacity(0.2) : Theme.of(context).colorScheme.outline.withOpacity(0.1), width: 1.5),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.05) : Theme.of(context).colorScheme.primary.withOpacity(0.03),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: MaterialButton(
                        onPressed: () => widget.bookingsCtrl.toggleFullDetails(widget.booking['_id']),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.ac_unit, size: 22, color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subcategory['name'] ?? 'AC Service',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          spacing: 6.0,
                                          children: [
                                            if (isDisabled) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  'DISABLED',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700, fontSize: 10),
                                                ),
                                              ),
                                            ],
                                            Text(
                                              'Fixed Price',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Icon(
                                              isExpanded ? Icons.expand_less : Icons.expand_more,
                                              size: 18,
                                              color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${widget.booking['totalPrice'] ?? subcategory['basePrice'] ?? '0'}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildQuickInfoRow(context, customer, slot, isDisabled),
                          if (isExpanded) ...[
                            const SizedBox(height: 16),
                            _buildExpandableSection(
                              context,
                              title: 'Booking Details',
                              isDisabled: isDisabled,
                              children: [
                                _buildDetailItem(context, icon: Icons.person_outline, label: 'Customer Name', value: customer['name'] ?? 'N/A', isDisabled: isDisabled),
                                _buildDetailItem(context, icon: Icons.phone_iphone, label: 'Mobile Number', value: customer['mobileNo'] ?? 'N/A', isPhone: true, isDisabled: isDisabled),
                                _buildDetailItem(context, icon: Icons.calendar_today, label: 'Service Date', value: _formatServiceDate(slot['date'] ?? ''), isDisabled: isDisabled),
                                _buildDetailItem(
                                  context,
                                  icon: Icons.access_time,
                                  label: 'Time Slot',
                                  value: '${_formatTime(slot['startTime'] ?? '')} - ${_formatTime(slot['endTime'] ?? '')}',
                                  isDisabled: isDisabled,
                                ),
                                _buildDetailItem(context, icon: Icons.engineering, label: 'Service Type', value: subcategory['name'] ?? 'AC Service', isDisabled: isDisabled),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentStatus(
                              context,
                              status: payment['status'] ?? 'pending',
                              amount: payment['amount'] ?? widget.booking['totalPrice'] ?? 0,
                              mode: payment['mode'] ?? 'online',
                              isDisabled: isDisabled,
                            ),
                          ],
                          if (!isDisabled) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showRejectDialog(widget.booking),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.error,
                                      side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close, size: 18),
                                        SizedBox(width: 8),
                                        Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _showAcceptDialog(widget.booking),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, size: 18),
                                        SizedBox(width: 8),
                                        Text('Accept Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This booking is currently unavailable',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDisabled)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatServiceDate(String dateString) {
    try {
      if (dateString.contains('T')) {
        final date = DateTime.parse(dateString);
        return '${date.day}/${date.month}/${date.year}';
      } else {
        final now = DateTime.now();
        return '${now.day}/${now.month}/${now.year}';
      }
    } catch (e) {
      return 'Date not specified';
    }
  }

  String _formatTime(String timeString) {
    try {
      if (timeString.contains('T')) {
        final time = DateTime.parse(timeString);
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
        return timeString;
      }
    } catch (e) {
      return 'Invalid time';
    }
  }

  Widget _buildPaymentStatus(BuildContext context, {required String status, required dynamic amount, required String mode, bool isDisabled = false}) {
    final statusColor = isDisabled ? Colors.grey : _getPaymentColor(status);
    final statusText = _getPaymentStatusText(status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_getPaymentIcon(status), size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment $statusText',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: statusColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹$amount • ${mode.toUpperCase()}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              status.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(dynamic booking) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Accept Booking'),
        content: Text('Are you sure you want to accept this booking?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              widget.bookingsCtrl.acceptBooking(booking['_id']);
            },
            style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5))),
            child: Text('Accept', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(dynamic booking) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Reject Booking'),
        content: Text('Are you sure you want to reject this booking?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              widget.bookingsCtrl.rejectBooking(booking['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5)),
            child: Text('Reject', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, {required IconData icon, required String label, required String value, bool isPhone = false, bool isDisabled = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.03) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1) : Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                if (isPhone && !isDisabled)
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  )
                else
                  Text(
                    value.capitalizeFirst.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(BuildContext context, dynamic customer, dynamic slot, bool isDisabled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  customer['name']?.toString().capitalizeFirst.toString() ?? 'N/A',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Time', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  _formatTime(slot['startTime'] ?? ''),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: isDisabled ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, {required String title, required bool isDisabled, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(children: children),
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
