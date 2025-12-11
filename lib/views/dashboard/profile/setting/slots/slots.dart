import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/views/dashboard/profile/setting/slots/slots_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class SlotManagement extends StatefulWidget {
  const SlotManagement({super.key});

  @override
  State<SlotManagement> createState() => _SlotManagementState();
}

class _SlotManagementState extends State<SlotManagement> {
  final SlotsCtrl _slotController = Get.put(SlotsCtrl());
  final ScrollController _scrollController = ScrollController();
  final List<String> _expandedDays = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text('Slot Managed', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          Obx(
            () => _slotController.isSaving.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary)),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton.icon(
                      onPressed: _slotController.saveWeeklySlots,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      icon: Icon(Icons.save_outlined, size: 18),
                      label: Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (_slotController.isLoading.value) {
          return _buildShimmerLoadingState(context);
        }
        return Column(
          children: [
            _buildStatsHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _slotController.getWeeklySlots(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildInfoCard(context),
                      const SizedBox(height: 20),
                      _buildDaysSlotsSection(),
                      const SizedBox(height: 20),
                      _buildQuickActionsSection(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildShimmerStatsHeader(context),
            const SizedBox(height: 16),
            _buildShimmerInfoCard(context),
            const SizedBox(height: 20),
            _buildShimmerDaysSlotsSection(context),
            const SizedBox(height: 20),
            _buildShimmerQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStatsHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(children: [_buildShimmerStatItem(context), const SizedBox(width: 20), _buildShimmerStatItem(context), const SizedBox(width: 20), _buildShimmerStatItem(context)]),
    );
  }

  Widget _buildShimmerStatItem(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 18, height: 18, color: Colors.white),
                const SizedBox(width: 6),
                Container(width: 30, height: 20, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 60, height: 12, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 24, height: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, color: Colors.white),
                const SizedBox(height: 6),
                Column(
                  children: [
                    Container(width: 200, height: 12, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 180, height: 12, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 160, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDaysSlotsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 100, height: 16, color: Colors.white),
            const Spacer(),
            Container(width: 120, height: 12, color: Colors.white),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(7, (index) => _buildShimmerDayCard(context)),
      ],
    );
  }

  Widget _buildShimmerDayCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(width: 36, height: 36, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 80, height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 100, height: 12, color: Colors.white),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(width: 50, height: 30, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 20, height: 20, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(width: 80, height: 16, color: Colors.white),
                const SizedBox(height: 12),
                ...List.generate(2, (i) => _buildShimmerSlotItem(context)),
                const SizedBox(height: 16),
                Container(width: 120, height: 40, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSlotItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildShimmerTimePicker(context)),
                const SizedBox(width: 8),
                Expanded(child: _buildShimmerTimePicker(context)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(width: double.infinity, height: 36, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(width: double.infinity, height: 36, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 60, height: 10, color: Colors.white),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 20, height: 20, color: Colors.white),
              const SizedBox(width: 8),
              Container(width: 100, height: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(4, (index) => _buildShimmerQuickActionButton(context)),
        ],
      ),
    );
  }

  Widget _buildShimmerQuickActionButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(width: 40, height: 40, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 80, height: 14, color: Colors.white),
                const SizedBox(height: 2),
                Container(width: 100, height: 12, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Obx(() {
        final availableSlots = _slotController.getTotalAvailableSlots();
        final busyDays = _slotController.getBusyDaysCount();
        return Row(
          children: [
            _buildStatItem(context, icon: Icons.calendar_today_outlined, value: availableSlots.toString(), label: 'Total Slots'),
            const SizedBox(width: 20),
            _buildStatItem(context, icon: Icons.check_circle_outline, value: busyDays.toString(), label: 'Active Days'),
            const SizedBox(width: 20),
            _buildStatItem(context, icon: Icons.access_time, value: _slotController.getAverageSlotsPerDay().toStringAsFixed(1), label: 'Avg/Day'),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String value, required String label}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Availability',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set time slots when you\'re available for appointments. '
                  'Customers can only book during these time slots. '
                  'Add multiple slots per day to increase booking opportunities.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 12, color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSlotsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Weekly Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Obx(() {
              return Text(
                '${_slotController.getTotalAvailableSlots()} slots across ${_slotController.getBusyDaysCount()} days',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        ..._slotController.days.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(String day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayName = _slotController.getDayName(day);
    final hasAvailableSlots = _slotController.hasAvailableSlots(day);
    final slotsCount = _slotController.getAvailableSlotsCount(day);
    final isExpanded = _expandedDays.contains(day);
    final dayColor = colorScheme.primary.withOpacity(0.9);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDays.remove(day);
                } else {
                  _expandedDays.add(day);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasAvailableSlots ? dayColor.withOpacity(0.05) : colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: !isExpanded ? const Radius.circular(16) : Radius.zero,
                  bottomRight: !isExpanded ? const Radius.circular(16) : Radius.zero,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: hasAvailableSlots ? dayColor : colorScheme.surfaceVariant, shape: BoxShape.circle),
                    child: Icon(_getDayIcon(day), color: hasAvailableSlots ? colorScheme.onPrimary : colorScheme.onSurfaceVariant, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: hasAvailableSlots ? dayColor : colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasAvailableSlots ? '$slotsCount ${slotsCount == 1 ? 'slot' : 'slots'} available' : 'No slots set',
                          style: theme.textTheme.labelSmall?.copyWith(color: hasAvailableSlots ? colorScheme.primary : colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: hasAvailableSlots,
                        activeColor: dayColor,
                        onChanged: (value) {
                          if (value) {
                            _slotController.addSlot(day);
                            if (!_expandedDays.contains(day)) {
                              _expandedDays.add(day);
                            }
                          } else {
                            _slotController.clearDaySlots(day);
                            if (_expandedDays.contains(day)) {
                              _expandedDays.remove(day);
                            }
                          }
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && hasAvailableSlots) _buildSlotsList(day, dayColor),
        ],
      ),
    );
  }

  Widget _buildSlotsList(String day, Color dayColor) {
    final slots = _slotController.weeklySlots[day];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time Slots', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (slots!.isEmpty) _buildEmptySlotsState(day, dayColor) else ..._buildSlotItems(day, slots, dayColor),
          const SizedBox(height: 16),
          _buildAddSlotButton(day, dayColor),
        ],
      ),
    );
  }

  Widget _buildEmptySlotsState(String day, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('No time slots added', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Add your first time slot for this day',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlotItems(String day, List<dynamic> slots, Color dayColor) {
    return List.generate(slots.length, (index) {
      final slot = slots[index];
      return _buildSlotItem(day, index, slot, dayColor);
    });
  }

  Widget _buildSlotItem(String day, int index, Map<String, dynamic> slot, Color dayColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAvailable = slot['isAvailable'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable ? dayColor.withOpacity(0.08) : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isAvailable ? dayColor.withOpacity(0.3) : colorScheme.outlineVariant),
            ),
            child: Column(
              spacing: 8.0,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTimePicker(day, index, 'startTime', slot['startTime'], dayColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTimePicker(day, index, 'endTime', slot['endTime'], dayColor)),
                  ],
                ),
                Row(
                  spacing: 10.0,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final newValue = !isAvailable;
                          _slotController.updateSlotAvailability(day, index, newValue);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dayColor,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.toggle_off_rounded, size: 20),
                        label: Text('Remove', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _slotController.removeSlot(day, index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.delete_outline, size: 20),
                        label: Text('Remove', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String day, int index, String field, String currentTime, Color dayColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = field == 'startTime' ? 'START TIME' : 'END TIME';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _parseTime(currentTime),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: colorScheme.surface,
                      hourMinuteTextColor: colorScheme.onSurface,
                      hourMinuteColor: colorScheme.primary.withOpacity(0.1),
                      dayPeriodTextColor: colorScheme.onSurface,
                      dayPeriodColor: colorScheme.primary.withOpacity(0.1),
                      dialHandColor: colorScheme.primary,
                      dialBackgroundColor: colorScheme.surfaceVariant,
                      hourMinuteTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      dayPeriodTextStyle: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                    ),
                    colorScheme: ColorScheme.light(primary: colorScheme.primary, onPrimary: colorScheme.onPrimary),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && mounted) {
              final newTime = _formatTime(picked);
              _slotController.updateSlotTime(day, index, field, newTime);
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTime,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                Icon(Icons.access_time, size: 14, color: dayColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlotButton(String day, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _slotController.addSlot(day);
          setState(() {});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(Icons.add, size: 20),
        label: Text('Add Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(context, icon: Icons.weekend_outlined, label: 'Setup Weekdays', description: '9 AM - 6 PM', onTap: _slotController.setupWeekdays),
          const SizedBox(height: 10),
          _buildQuickActionButton(context, icon: Icons.weekend, label: 'Setup Weekend', description: '10 AM - 4 PM', onTap: () => _slotController.setupWeekend()),
          const SizedBox(height: 10),
          _buildQuickActionButton(context, icon: Icons.repeat, label: 'Copy Monday', description: 'Copy to weekdays', onTap: () => _slotController.copyMondayToAll()),
          const SizedBox(height: 10),
          _buildQuickActionButton(context, icon: Icons.clear_all, label: 'Clear All', description: 'Remove all slots', onTap: _showClearAllConfirmation),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required String description, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllConfirmation() {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Clear All Slots?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        content: Text(
          'This will remove all time slots from all days. '
          'This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _slotController.clearAllSlots();
              Get.back();
              Get.snackbar('Cleared', 'All slots have been cleared', backgroundColor: colorScheme.error, colorText: colorScheme.onError, snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'monday':
        return Icons.calendar_view_week;
      case 'tuesday':
        return Icons.view_week;
      case 'wednesday':
        return Icons.calendar_month;
      case 'thursday':
        return Icons.today;
      case 'friday':
        return Icons.weekend;
      case 'saturday':
        return Icons.weekend;
      case 'sunday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
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
