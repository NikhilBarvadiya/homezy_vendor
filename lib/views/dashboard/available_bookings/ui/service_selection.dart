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
                onPressed: _bookingsCtrl.selectedServices.isNotEmpty && !_bookingsCtrl.isUpdating.value
                    ? () async {
                        await _bookingsCtrl.updateProfile();
                        Get.close(1);
                      }
                    : null,
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

class _ServiceDetailSheetState extends State<ServiceDetailSheet> {
  int _currentImageIndex = 0;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    final service = widget.service;
    if (service['image'] != null && service['image'].toString().isNotEmpty) {
      _images.add(service['image'].toString());
    }
    if (service['additionalImages'] != null) {
      final additional = List<dynamic>.from(service['additionalImages'] ?? []);
      for (var img in additional) {
        if (img.toString().isNotEmpty) {
          _images.add(img.toString());
        }
      }
    }
    final subCategories = List<dynamic>.from(service['subCategories'] ?? []);
    for (var sub in subCategories) {
      if (sub['image'] != null && sub['image'].toString().isNotEmpty) {
        _images.add(sub['image'].toString());
      }
    }
    setState(() {});
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'] ?? 'Service', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                          if (service['category'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.category, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                  const SizedBox(width: 4),
                                  Text(service['category'] ?? 'General', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              if (_images.isNotEmpty) ...[_buildImageCarousel(), const SizedBox(height: 15)],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isServiceSelected || selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isServiceSelected || selectedSubs.isNotEmpty ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Status',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                              ),
                              Text(
                                isServiceSelected || selectedSubs.isNotEmpty ? '${selectedSubs.length} sub-services selected' : 'Not selected',
                                style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: isServiceSelected || selectedSubs.isNotEmpty,
                            onChanged: (value) {
                              if (value) {
                                widget.bookingsCtrl.selectService(service);
                              } else {
                                widget.bookingsCtrl.unselectService(service);
                              }
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Sub-services', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        if (selectedSubs.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              widget.bookingsCtrl.unselectService(service);
                              setState(() {});
                            },
                            icon: Icon(Icons.clear_all, size: 16, color: Theme.of(context).colorScheme.error),
                            label: Text(
                              'Clear All',
                              style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('Select individual sub-services below', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = subCategories[index];
                    final isSelected = widget.bookingsCtrl.isSubcategorySelected(service, subcategory);
                    final isActive = subcategory['isActive'] == true;
                    final hasImage = subcategory['image'] != null && subcategory['image'].toString().isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            image: hasImage && subcategory['image'] != null ? DecorationImage(image: NetworkImage(subcategory['image'].toString()), fit: BoxFit.cover) : null,
                          ),
                          child: hasImage
                              ? null
                              : Center(
                                  child: Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                    size: 24,
                                  ),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                subcategory['name'] ?? 'Sub-service',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ),
                            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subcategory['description'] != null)
                              Text(
                                subcategory['description'] ?? '',
                                style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    '₹${subcategory['basePrice'] ?? '0'}',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text('${subcategory['duration'] ?? '60'} mins', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                const Spacer(),
                                if (!isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Inactive',
                                      style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        onTap: isActive
                            ? () {
                                widget.bookingsCtrl.toggleSubcategorySelection(service, subcategory);
                                widget.bookingsCtrl.update();
                                setState(() {});
                              }
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(selectedSubs.isNotEmpty ? Icons.check_circle : Icons.done, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                  ),
                  label: Text(selectedSubs.isNotEmpty ? '${selectedSubs.length} Sub-services Selected' : 'Done', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + _images[index]), fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        if (_images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ),
        if (_images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${_currentImageIndex + 1}/${_images.length}', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ),
      ],
    );
  }
}
