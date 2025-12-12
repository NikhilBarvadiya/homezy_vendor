import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/booking_card.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/booking_details.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/ui/service_selection.dart';
import 'package:shimmer/shimmer.dart';

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
                      Obx(() {
                        if (_bookingsCtrl.isBookingsLoading.value) {
                          return _buildShimmerHeader();
                        }
                        return Text(
                          'Available Bookings',
                          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.surface),
                        );
                      }),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (_bookingsCtrl.isBookingsLoading.value) {
                          return Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                          );
                        }
                        return Text(
                          '${_bookingsCtrl.availableBookings.length} bookings available',
                          style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.surface.withOpacity(0.9)),
                        );
                      }),
                    ],
                  ),
                  Obx(() {
                    return _bookingsCtrl.isBookingsLoading.value
                        ? Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          )
                        : Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.2), shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.surface),
                              onPressed: _bookingsCtrl.refreshBookings,
                              tooltip: 'Refresh',
                            ),
                          );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Obx(() {
                  return _bookingsCtrl.isBookingsLoading.value
                      ? _buildShimmerSearchBar()
                      : TextField(
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
                                : const SizedBox.shrink(),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          style: GoogleFonts.poppins(fontSize: 16),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Container(
        width: 200,
        height: 28,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildShimmerSearchBar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      if (_bookingsCtrl.isBookingsLoading.value && _bookingsCtrl.availableBookings.isEmpty) {
        return _buildShimmerLoadingState();
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
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: Get.height * .1),
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

  Widget _buildShimmerLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildShimmerBookingCard();
      },
    );
  }

  Widget _buildShimmerBookingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          period: const Duration(milliseconds: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 150,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
