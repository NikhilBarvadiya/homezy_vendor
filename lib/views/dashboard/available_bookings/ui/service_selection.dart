import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/utils/network/api_config.dart';
import 'package:homenest_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ServiceSelection extends StatefulWidget {
  const ServiceSelection({super.key});

  @override
  State<ServiceSelection> createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection> {
  final AvailableBookingsCtrl _bookingsCtrl = Get.find<AvailableBookingsCtrl>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _bookingsCtrl.loadMoreServices();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Select Services',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          Obx(() {
            final selectedCount = _bookingsCtrl.selectedServices.length;
            return selectedCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$selectedCount',
                          style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.surface),
                      ],
                    ),
                  )
                : const SizedBox();
          }),
          SizedBox(width: 10.0),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildServicesGrid()),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _bookingsCtrl.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                suffixIcon: Obx(() {
                  return _bookingsCtrl.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            _searchController.clear();
                            _bookingsCtrl.clearSearch();
                          },
                        )
                      : const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          Obx(() {
            final totalSubcategories = _bookingsCtrl.selectedServices.fold(0, (sum, service) {
              final selectedSubs = _bookingsCtrl.getSelectedSubcategories(service);
              return sum + selectedSubs.length;
            });
            return totalSubcategories > 0
                ? Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$totalSubcategories sub-services selected',
                            style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: _bookingsCtrl.clearSelectedServices,
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Obx(() {
      if (_bookingsCtrl.isServicesLoading.value && _bookingsCtrl.allServices.isEmpty) {
        return _buildLoadingState();
      }
      final services = _bookingsCtrl.allServices;
      if (services.isEmpty) {
        return _buildEmptyState();
      }
      return RefreshIndicator(
        onRefresh: () async {
          await _bookingsCtrl.getServices(loadMore: true);
        },
        color: Theme.of(context).colorScheme.primary,
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.9),
          itemCount: services.length + 1,
          itemBuilder: (context, index) {
            if (index == services.length) {
              return _buildLoadMoreIndicator();
            }
            return _buildServiceCard(services[index]);
          },
        ),
      );
    });
  }

  Widget _buildServiceCard(dynamic service) {
    return Obx(() {
      final isSelected = _bookingsCtrl.selectedServices.any((s) => s['_id'] == service['_id']);
      final subCategories = List<dynamic>.from(service['subCategories'] ?? []);
      final selectedSubs = _bookingsCtrl.getSelectedSubcategories(service);
      final hasSelectedSubs = selectedSubs.isNotEmpty;
      final images = _getServiceImages(service);
      return GestureDetector(
        onTap: () => _showServiceDetails(service),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected || hasSelectedSubs ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected || hasSelectedSubs ? 1 : .6,
            ),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(images, service),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? 'Service',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(Icons.settings, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text('${subCategories.length} sub-services', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                            const Spacer(),
                            if (service['rating'] != null)
                              Row(
                                children: [
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${service['rating']}',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (hasSelectedSubs)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Text('${selectedSubs.length} selected', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected || hasSelectedSubs)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Icon(Icons.check, color: Theme.of(context).colorScheme.surface, size: 18),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImageCarousel(List<String> images, dynamic service) {
    if (images.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_repair_service, size: 40, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 4),
              Text('No Image', style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: images.length,
            options: CarouselOptions(
              height: 100,
              viewportFraction: 1.0,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              aspectRatio: 16 / 9,
              enableInfiniteScroll: images.length > 1,
            ),
            itemBuilder: (context, index, realIndex) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  image: DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + images[index]), fit: BoxFit.cover),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.photo_library, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${images.length}',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _getServiceImages(dynamic service) {
    final List<String> images = [];
    if (service['image'] != null && service['image'].toString().isNotEmpty) {
      images.add(service['image'].toString());
    }
    if (service['additionalImages'] != null) {
      final additional = List<dynamic>.from(service['additionalImages'] ?? []);
      for (var img in additional) {
        if (img.toString().isNotEmpty) {
          images.add(img.toString());
        }
      }
    }
    final subCategories = List<dynamic>.from(service['subCategories'] ?? []);
    for (var sub in subCategories) {
      if (sub['image'] != null && sub['image'].toString().isNotEmpty) {
        images.add(sub['image'].toString());
      }
    }
    return images.toSet().toList();
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_bookingsCtrl.hasMoreServices.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                Text('Loading more...', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.close(1),
              icon: Icon(Icons.close, size: 18),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              label: Text('Cancel', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: _bookingsCtrl.selectedServices.isNotEmpty && !_bookingsCtrl.isUpdating.value ? () async => await _bookingsCtrl.updateProfile() : null,
                icon: _bookingsCtrl.isUpdating.value
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface))
                    : Icon(Icons.check, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                label: Text(_bookingsCtrl.isUpdating.value ? 'Applying...' : 'Apply Filters', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 6, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary))),
            const SizedBox(height: 20),
            Text('Loading Services...', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please wait while we fetch available services',
                style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text('👷‍♂️', style: TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              _bookingsCtrl.searchQuery.isEmpty ? 'No Services Available' : 'No services found',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _bookingsCtrl.searchQuery.isEmpty ? 'Services will appear here when available. Contact admin to add services.' : 'Try searching with different keywords',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            if (_bookingsCtrl.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _bookingsCtrl.clearSearch,
                icon: Icon(Icons.clear, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                label: const Text('Clear Search'),
              ),
            ] else ...[
              const SizedBox(height: 30),
              OutlinedButton.icon(
                onPressed: () => _bookingsCtrl.getServices(loadMore: true),
                icon: Icon(Icons.refresh, size: 18),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(dynamic service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ServiceDetailSheet(service: service, bookingsCtrl: _bookingsCtrl, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class ServiceDetailSheet extends StatefulWidget {
  final dynamic service;
  final AvailableBookingsCtrl bookingsCtrl;
  final ScrollController scrollController;

  const ServiceDetailSheet({super.key, required this.service, required this.bookingsCtrl, required this.scrollController});

  @override
  State<ServiceDetailSheet> createState() => _ServiceDetailSheetState();
}

class _ServiceDetailSheetState extends State<ServiceDetailSheet> with SingleTickerProviderStateMixin {
  final List<String> _serviceImages = [];
  late TabController _tabController;
  String _selectedSubcategoryView = 'grid';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadImages() {
    final service = widget.service;
    if (service['image'] != null && service['image'].toString().isNotEmpty) {
      _serviceImages.add(service['image'].toString());
    }
    if (service['additionalImages'] != null) {
      final additional = List<dynamic>.from(service['additionalImages'] ?? []);
      for (var img in additional) {
        if (img.toString().isNotEmpty) {
          _serviceImages.add(img.toString());
        }
      }
    }
    setState(() {});
  }

  void _showFullScreenGallery(List<dynamic> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return FullScreenGallery(images: images, initialIndex: initialIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = widget.service;
      final subCategories = List<dynamic>.from(service['subCategories'] ?? []);
      final isServiceSelected = widget.bookingsCtrl.selectedServices.any((s) => s['_id'] == service['_id']);
      final selectedSubs = widget.bookingsCtrl.getSelectedSubcategories(service);
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              _buildCustomHeader(service, isServiceSelected, selectedSubs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_checkout, size: 20, color: selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Services',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                          ),
                          Text(
                            selectedSubs.isNotEmpty ? '${selectedSubs.length} sub-services selected • ₹${_calculateTotalPrice(widget.service)} total' : 'No services selected',
                            style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    if (selectedSubs.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          widget.bookingsCtrl.unselectService(widget.service);
                          setState(() {});
                        },
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ).paddingOnly(left: 15, right: 15, top: 10),
              Expanded(child: _buildServicesTab(service, subCategories)),
              _buildBottomActionBar(selectedSubs),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCustomHeader(dynamic service, bool isServiceSelected, List selectedSubs) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_serviceImages.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFullScreenGallery(_serviceImages, 0),
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: CachedNetworkImageProvider(APIConfig.resourceBaseURL + _serviceImages.first), fit: BoxFit.cover),
                      ),
                      child: _serviceImages.length > 1
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
                                ),
                                child: Text(
                                  '+${_serviceImages.length - 1}',
                                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service['name'] ?? 'Service',
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            onPressed: () => Get.close(1),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      if (service['category'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.category, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                              const SizedBox(width: 6),
                              Text(service['category'] ?? 'General', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isServiceSelected || selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: isServiceSelected || selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${selectedSubs.length} selected',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isServiceSelected || selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubcategoryView = 'grid';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: _selectedSubcategoryView == 'grid' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  child: Icon(Icons.grid_view, size: 16, color: _selectedSubcategoryView == 'grid' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubcategoryView = 'list';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: _selectedSubcategoryView == 'list' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  child: Icon(Icons.view_list, size: 16, color: _selectedSubcategoryView == 'list' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ],
          ).paddingOnly(left: 15, right: 15),
        ],
      ),
    );
  }

  Widget _buildServicesTab(dynamic service, List subCategories) {
    return _selectedSubcategoryView == 'grid' ? _buildGridView(subCategories) : _buildListView(subCategories);
  }

  Widget _buildGridView(List subCategories) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subcategory = subCategories[index];
        return _buildGridSubcategoryCard(subcategory);
      },
    );
  }

  Widget _buildGridSubcategoryCard(dynamic subcategory) {
    final isSelected = widget.bookingsCtrl.isSubcategorySelected(widget.service, subcategory);
    final isActive = subcategory['isActive'] == true;
    final images = subcategory["images"] ?? [];
    return GestureDetector(
      onTap: isActive
          ? () {
              widget.bookingsCtrl.toggleSubcategorySelection(widget.service, subcategory);
              widget.bookingsCtrl.update();
              setState(() {});
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant, width: 1),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubcategoryImageCarousel(images, subcategory),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcategory['name'] ?? 'Sub-service',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '₹${subcategory['basePrice'] ?? '0'}',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.access_time, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 2),
                          Text('${subcategory['duration'] ?? '60'} min', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (subcategory['description'] != null)
                        Text(
                          subcategory['description'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(.3),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Icon(isSelected ? Icons.check : Icons.radio_button_off_rounded, size: 16, color: Theme.of(context).colorScheme.surface),
              ),
            ),
            if (!isActive)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    'Inactive',
                    style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryImageCarousel(List<dynamic> images, dynamic subcategory) {
    if (images.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(15)),
        child: Center(child: Icon(Icons.construction, size: 30, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3))),
      );
    }

    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: images.length,
            options: CarouselOptions(
              height: 100,
              viewportFraction: 1.0,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              enableInfiniteScroll: images.length > 1,
              onPageChanged: (index, reason) {},
            ),
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () => _showFullScreenGallery(images, index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    image: DecorationImage(image: CachedNetworkImageProvider(APIConfig.resourceBaseURL + images[index]), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.photo_library, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${images.length}',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List subCategories) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: subCategories.length,
      itemBuilder: (context, index) {
        final subcategory = subCategories[index];
        return _buildListSubcategoryCard(subcategory);
      },
    );
  }

  Widget _buildListSubcategoryCard(dynamic subcategory) {
    final isSelected = widget.bookingsCtrl.isSubcategorySelected(widget.service, subcategory);
    final isActive = subcategory['isActive'] == true;
    final images = subcategory["images"] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.1), width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outline.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          if (images.isNotEmpty) SizedBox(width: 15),
          SizedBox(width: 100, child: _buildSubcategoryImageCarousel(images, subcategory)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subcategory['name'] ?? 'Sub-service',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'Inactive',
                            style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '₹${subcategory['basePrice'] ?? '0'}',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text('${subcategory['duration'] ?? '60'} mins', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (subcategory['description'] != null)
                    Text(
                      subcategory['description'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    size: 24,
                  ),
                  onPressed: isActive
                      ? () {
                          widget.bookingsCtrl.toggleSubcategorySelection(widget.service, subcategory);
                          widget.bookingsCtrl.update();
                          setState(() {});
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                if (images.length > 1) Text('${images.length} photos', style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(List selectedSubs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.close(1),
              icon: Icon(Icons.close, size: 18),
              label: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedSubs.isNotEmpty ? () => Get.close(1) : null,
              icon: selectedSubs.isNotEmpty ? Icon(Icons.check_circle, size: 18) : Icon(Icons.remove_circle, size: 18),
              label: Text(selectedSubs.isNotEmpty ? 'Apply (${selectedSubs.length})' : 'Select', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                foregroundColor: selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalPrice(dynamic service) {
    final selectedSubs = widget.bookingsCtrl.getSelectedSubcategories(service);
    if (selectedSubs.isEmpty) return 0;
    return selectedSubs.fold(0, (sum, sub) => sum + (int.tryParse(sub['basePrice'].toString()) ?? 0));
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.images, this.initialIndex = 0});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: APIConfig.resourceBaseURL + widget.images[index],
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 60),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.3)),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
