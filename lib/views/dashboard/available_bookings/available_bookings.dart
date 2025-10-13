import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homezy_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:homezy_vendor/views/dashboard/available_bookings/ui/booking_card.dart';
import 'package:homezy_vendor/views/dashboard/available_bookings/ui/service_selection.dart';

class AvailableBookings extends StatefulWidget {
  const AvailableBookings({super.key});

  @override
  State<AvailableBookings> createState() => _AvailableBookingsState();
}

class _AvailableBookingsState extends State<AvailableBookings> {
  final AvailableBookingsCtrl _bookingsCtrl = Get.put(AvailableBookingsCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Available Bookings', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            ),
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: () => Get.to(() => ServiceSelection()),
            tooltip: 'Filters',
          ),
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            ),
            icon: Icon(Icons.refresh),
            onPressed: _bookingsCtrl.refreshBookings,
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8.0),
        ],
      ),
      body: Obx(() {
        if (_bookingsCtrl.isBookingsLoading.value && _bookingsCtrl.availableBookings.isEmpty) {
          return _buildLoadingState();
        }
        final filteredBookings = _bookingsCtrl.filteredBookings;
        if (filteredBookings.isEmpty) {
          return _buildEmptyState();
        }
        if (_bookingsCtrl.availableBookings.isNotEmpty && (_bookingsCtrl.isRejected.value || _bookingsCtrl.isAccepted.value)) {
          return _buildFullScreenLoading(_bookingsCtrl.isRejected.value ? 'Reject Booking...' : 'Accept Booking...', _bookingsCtrl.isRejected.value ? Icons.cancel_outlined : Icons.star_outlined);
        }
        return RefreshIndicator(
          onRefresh: _bookingsCtrl.refreshBookings,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bookingsCtrl.filteredBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return BookingCard(booking: filteredBookings[index], bookingsCtrl: _bookingsCtrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), const SizedBox(height: 16), Text('Loading available bookings...')]),
    );
  }

  Widget _buildFullScreenLoading(String message, IconData icon) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), strokeWidth: 3),
                  ),
                  Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'No Available Bookings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            'New bookings will appear here when available',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
