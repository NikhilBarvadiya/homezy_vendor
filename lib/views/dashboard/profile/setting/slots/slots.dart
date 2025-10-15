import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/profile/setting/slots/slots_ctrl.dart';

class SlotManagement extends StatefulWidget {
  const SlotManagement({super.key});

  @override
  State<SlotManagement> createState() => _SlotManagementState();
}

class _SlotManagementState extends State<SlotManagement> {
  final SlotsCtrl _slotController = Get.put(SlotsCtrl());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Slot Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          Obx(
            () => _slotController.isSaving.value
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                  )
                : IconButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                    ),
                    icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary, size: 20),
                    onPressed: _slotController.saveWeeklySlots,
                  ),
          ),
          SizedBox(width: 8.0),
        ],
      ),
      body: Obx(() {
        if (_slotController.isLoading.value) {
          return _buildLoadingState();
        }
        return Column(
          children: [
            _buildHeaderSection(context),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(children: [_buildDaysSlotsList(), const SizedBox(height: 20), _buildQuickActions(), const SizedBox(height: 20)]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading your slots...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Availability Slots', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Set your weekly time slots for service bookings. Customers can book appointments only in available slots.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 12),
          _buildWeekSummary(),
        ],
      ),
    );
  }

  Widget _buildWeekSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Tip: Set multiple slots per day to increase booking opportunities', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSlotsList() {
    return Column(children: _slotController.days.map((day) => _buildDaySlotCard(day)).toList());
  }

  Widget _buildDaySlotCard(String day) {
    final dayName = _slotController.getDayName(day);
    final hasAvailableSlots = _slotController.hasAvailableSlots(day);
    final slotsCount = _slotController.getAvailableSlotsCount(day);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: hasAvailableSlots ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.calendar_today, color: hasAvailableSlots ? Theme.of(context).colorScheme.primary : Colors.grey[500], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: hasAvailableSlots ? Theme.of(context).colorScheme.primary : Colors.grey[500]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAvailableSlots ? '$slotsCount ${slotsCount == 1 ? 'slot' : 'slots'} available' : 'No slots available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: hasAvailableSlots ? Colors.green : Colors.grey[500], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: hasAvailableSlots,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    if (value) {
                      _slotController.addSlot(day);
                    } else {
                      for (int i = 0; i < _slotController.weeklySlots[day].length; i++) {
                        _slotController.weeklySlots[day][i]["isAvailable"] = false;
                      }
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          if (hasAvailableSlots) _buildSlotsList(day),
        ],
      ),
    );
  }

  Widget _buildSlotsList(String day) {
    final slots = _slotController.weeklySlots[day];
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slots.isNotEmpty) ...[_buildSlotsHeader(), const SizedBox(height: 8), ..._buildSlotItems(day, slots)],
          _buildAddSlotButton(day),
        ],
      ),
    );
  }

  Widget _buildSlotsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('#', style: _headerTextStyle())),
          const SizedBox(width: 12),
          Expanded(child: Text('Start Time', style: _headerTextStyle())),
          const SizedBox(width: 8),
          Expanded(child: Text('End Time', style: _headerTextStyle())),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text('Status', style: _headerTextStyle())),
          const SizedBox(width: 8),
          SizedBox(width: 40, child: Text('Action', style: _headerTextStyle())),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle() {
    return TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600);
  }

  List<Widget> _buildSlotItems(String day, List<dynamic> slots) {
    return List.generate(slots.length, (index) {
      final slot = slots[index];
      return _buildSlotItem(day, index, slot);
    });
  }

  Widget _buildSlotItem(String day, int index, Map<String, dynamic> slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 10, top: 12, bottom: 12, right: 2),
      decoration: BoxDecoration(
        color: slot['isAvailable'] == true ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slot['isAvailable'] == true ? Colors.green[100]! : Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: slot['isAvailable'] == true ? Theme.of(context).colorScheme.onPrimary : Colors.grey[300], borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: slot['isAvailable'] == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildTimePicker(day, index, 'startTime', slot['startTime'])),
          const SizedBox(width: 8),
          Expanded(child: _buildTimePicker(day, index, 'endTime', slot['endTime'])),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Switch(
              value: slot['isAvailable'] == true,
              activeColor: Colors.green,
              onChanged: (value) {
                _slotController.updateSlotAvailability(day, index, value);
                slot['isAvailable'] = value;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String day, int index, String field, String currentTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field == 'startTime' ? 'Start' : 'End',
          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _parseTime(currentTime),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary, onPrimary: Colors.white),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && mounted) {
              final newTime = _formatTime(picked);
              _slotController.updateSlotTime(day, index, field, newTime);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(String day) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(Icons.add, size: 18),
        onPressed: () {
          _slotController.addSlot(day);
          setState(() {});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        label: Text('Add Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.weekend_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                  onPressed: _slotController.setupWeekdays,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Setup Weekdays', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.clear_all, size: 18, color: Colors.red),
                  onPressed: _showClearAllConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Clear All', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Slots?'),
        content: const Text('This will remove all time slots from all days. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _slotController.clearAllSlots();
              Get.back();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
