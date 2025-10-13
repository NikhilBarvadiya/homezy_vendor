import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/available_bookings/available_bookings_ctrl.dart';

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
    _searchController.addListener(_onSearchChanged);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _bookingsCtrl.loadMoreServices();
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _bookingsCtrl.clearSearch();
    }
  }

  void _performSearch() {
    _bookingsCtrl.searchServices(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text('Select Services', style: Theme.of(context).textTheme.titleLarge),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            actions: [
              Obx(() {
                return _bookingsCtrl.selectedServices.isNotEmpty
                    ? IconButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                        ),
                        icon: Icon(Icons.clear_all),
                        onPressed: _bookingsCtrl.clearSelectedServices,
                        tooltip: 'Clear All',
                      )
                    : const SizedBox.shrink();
              }),
              SizedBox(width: 8.0),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(context),
                _buildSelectedServicesSummary(),
                Expanded(
                  child: Obx(() {
                    if (_bookingsCtrl.isServicesLoading.value && _bookingsCtrl.allServices.isEmpty) {
                      return _buildLoadingState();
                    }
                    final services = _bookingsCtrl.allServices;
                    if (services.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: services.length + 1,
                      itemBuilder: (context, index) {
                        if (index == services.length) {
                          return _buildLoadMoreIndicator();
                        }
                        return _buildServiceItem(context, services[index]);
                      },
                    );
                  }),
                ),
                if (!isKeyboardVisible) _buildApplyButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _bookingsCtrl.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search services...',
            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
            suffixIcon: Obx(
              () => _bookingsCtrl.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        _bookingsCtrl.clearSearch();
                      },
                    )
                  : SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
      ),
    );
  }

  Widget _buildSelectedServicesSummary() {
    return Obx(() {
      if (_bookingsCtrl.selectedServices.isEmpty) {
        return const SizedBox.shrink();
      }
      final selectedCount = _bookingsCtrl.selectedServices.length;
      final totalSubcategories = _bookingsCtrl.selectedServices.fold(0, (sum, service) {
        final selectedSubs = _bookingsCtrl.getSelectedSubcategories(service);
        return sum + selectedSubs.length;
      });
      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCount service${selectedCount > 1 ? 's' : ''} selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                  if (totalSubcategories > 0)
                    Text(
                      '$totalSubcategories sub-service${totalSubcategories > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildServiceItem(BuildContext context, dynamic service) {
    final isSelected = _bookingsCtrl.isServiceSelected(service);
    final subCategories = List<dynamic>.from(service['subCategories'] ?? []);
    final hasSubcategories = subCategories.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: isSelected ? 1.2 : .8),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: service['image'] != null && service['image'].toString().isNotEmpty ? DecorationImage(image: NetworkImage(service['image'].toString()), fit: BoxFit.cover) : null,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: service['image'] == null || service['image'].toString().isEmpty ? Icon(Icons.home_repair_service, size: 20, color: Theme.of(context).colorScheme.primary) : null,
            ),
            title: Text(service['name'] ?? 'Service', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service['description'] != null) ...[
                  Text(
                    service['description'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  hasSubcategories ? '${subCategories.length} sub-services available' : 'No sub-services available',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: hasSubcategories ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                ),
              ],
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                if (value == true) {
                  _bookingsCtrl.selectService(service);
                } else {
                  _bookingsCtrl.unselectService(service);
                }
                setState(() {});
              },
            ),
            onTap: () {
              if (isSelected) {
                _bookingsCtrl.unselectService(service);
              } else {
                _bookingsCtrl.selectService(service);
              }
              setState(() {});
            },
          ),
          if (isSelected && hasSubcategories)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(children: [const Divider(), const SizedBox(height: 8), ...subCategories.map((subcategory) => _buildSubcategoryItem(context, service, subcategory))]),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryItem(BuildContext context, dynamic service, dynamic subcategory) {
    final isSelected = _bookingsCtrl.isSubcategorySelected(service, subcategory);
    final isActive = subcategory['isActive'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.onSurface.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        title: Text(
          subcategory['name'] ?? 'Sub-service',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subcategory['description'] != null) ...[
              Text(
                subcategory['description'] ?? '',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Text(
                  '₹${subcategory['basePrice'] ?? '0'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('• ${subcategory['duration'] ?? '60'} mins', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('Inactive', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.error)),
                  ),
              ],
            ),
          ],
        ),
        onTap: isActive
            ? () {
                _bookingsCtrl.toggleSubcategorySelection(service, subcategory);
                setState(() {});
              }
            : null,
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_bookingsCtrl.hasMoreServices.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (_bookingsCtrl.allServices.isNotEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('No more services')),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed: _bookingsCtrl.selectedServices.isNotEmpty && _bookingsCtrl.isUpdating.value != true
                    ? () async {
                        await _bookingsCtrl.updateProfile();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _bookingsCtrl.isUpdating.value
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                    : Text(
                        'Apply Filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading services...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_repair_service_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            _bookingsCtrl.searchQuery.isEmpty ? 'No Services Available' : 'No services found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            _bookingsCtrl.searchQuery.isEmpty ? 'Services will appear here when available' : 'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          if (_bookingsCtrl.searchQuery.isNotEmpty) ...[const SizedBox(height: 16), ElevatedButton(onPressed: _bookingsCtrl.clearSearch, child: Text('Clear Search'))],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
