import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/booking_card.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/booking_details.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/service_selection.dart';

class AvailableBookings extends StatefulWidget {
  const AvailableBookings({super.key});

  @override
  State<AvailableBookings> createState() => _AvailableBookingsState();
}

class _AvailableBookingsState extends State<AvailableBookings> {
  final AvailableBookingsCtrl _bookingsCtrl = Get.put(AvailableBookingsCtrl());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _bookingsCtrl.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          _buildHeaderSection(context),
          Expanded(child: _buildBookingsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => ServiceSelection()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        elevation: 4,
        child: const Icon(Icons.filter_alt_outlined),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Bookings',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.surface),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        return Text(
                          '${_bookingsCtrl.availableBookings.length} bookings available',
                          style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.surface.withOpacity(0.9)),
                        );
                      }),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.2), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.surface),
                      onPressed: _bookingsCtrl.refreshBookings,
                      tooltip: 'Refresh',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              _searchController.clear();
                              _bookingsCtrl.searchQuery.value = '';
                            },
                          )
                        : SizedBox.shrink(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      if (_bookingsCtrl.isBookingsLoading.value && _bookingsCtrl.availableBookings.isEmpty) {
        return _buildLoadingState();
      }
      final filteredBookings = _bookingsCtrl.filteredBookings;
      if (filteredBookings.isEmpty) {
        return _buildEmptyState();
      }
      if (_bookingsCtrl.availableBookings.isNotEmpty && (_bookingsCtrl.isRejected.value || _bookingsCtrl.isAccepted.value)) {
        return _buildFullScreenLoading();
      }
      return RefreshIndicator.adaptive(
        onRefresh: _bookingsCtrl.refreshBookings,
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.primary,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filteredBookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => BookingDetails(booking: filteredBookings[index], bookingsCtrl: _bookingsCtrl));
              },
              child: BookingCard(booking: filteredBookings[index], bookingsCtrl: _bookingsCtrl),
            );
          },
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 6, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary))),
          const SizedBox(height: 20),
          Text(
            'Loading Bookings...',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch available bookings',
            style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenLoading() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 60, height: 60, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), strokeWidth: 3)),
                  Icon(_bookingsCtrl.isRejected.value ? Icons.close : Icons.check, size: 30, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _bookingsCtrl.isRejected.value ? 'Rejecting...' : 'Accepting...',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 20),
            Text(
              'No Bookings Available',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(height: 12),
            Text(
              _bookingsCtrl.selectedServices.isEmpty
                  ? 'You don\'t have any bookings yet.\nTry adjusting your service filters.'
                  : 'No bookings match your selected services.\nTry updating your service preferences.',
              style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
