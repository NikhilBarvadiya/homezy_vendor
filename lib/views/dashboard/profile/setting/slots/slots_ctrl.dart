import 'package:get/get.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/views/auth/auth_service.dart';

class SlotsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var weeklySlots = <String, dynamic>{}.obs;
  var isLoading = false.obs, isSaving = false.obs;

  final List<String> days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

  String getDayName(String day) {
    switch (day) {
      case 'sunday':
        return 'Sunday';
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      default:
        return day;
    }
  }

  String getShortDayName(String day) {
    switch (day) {
      case 'sunday':
        return 'Sun';
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      default:
        return day;
    }
  }

  Future<void> getWeeklySlots() async {
    try {
      isLoading(true);
      final response = await _authService.weeklySlots();
      if (response != null) {
        weeklySlots.value = response ?? {};
        _initializeEmptySlots();
      }
    } catch (e) {
      toaster.error('Error fetching slots: ${e.toString()}');
      _initializeEmptySlots();
    } finally {
      isLoading(false);
    }
  }

  void _initializeEmptySlots() {
    for (final day in days) {
      if (!weeklySlots.containsKey(day) || weeklySlots[day] == null) {
        weeklySlots[day] = [];
      }
    }
  }

  void addSlot(String day) {
    if (!weeklySlots.containsKey(day)) {
      weeklySlots[day] = [];
    }
    final newSlot = {'startTime': '09:00', 'endTime': '10:00', 'isAvailable': true};
    weeklySlots[day] = [...weeklySlots[day], newSlot];
    update();
  }

  void updateSlotTime(String day, int index, String field, String time) {
    weeklySlots[day][index][field] = time;
    update();
  }

  void updateSlotAvailability(String day, int index, bool isAvailable) async {
    if (isSaving.value == true) return;
    isSaving(true);
    if (weeklySlots.containsKey(day) && index < weeklySlots[day].length) {
      try {
        final response = await _authService.updateAvailability(day, index, isAvailable);
        if (response != null) {
          weeklySlots[day][index]['isAvailable'] = isAvailable;
        }
      } catch (e) {
        weeklySlots[day][index]['isAvailable'] = !isAvailable;
      }
    }
    isSaving(false);
    update();
  }

  void removeSlot(String day, int index) {
    if (weeklySlots.containsKey(day) && weeklySlots[day].length > 1) {
      weeklySlots[day].removeAt(index);
      update();
    } else if (weeklySlots[day].length == 1) {
      weeklySlots[day][0]['isAvailable'] = false;
      update();
    }
  }

  Future<void> saveWeeklySlots() async {
    try {
      if (isSaving.value == true) return;
      isSaving(true);
      for (final day in days) {
        for (final slot in weeklySlots[day]) {
          if (!_isValidTimeSlot(slot['startTime'], slot['endTime'])) {
            toaster.error('Invalid time slot in ${getDayName(day)}');
            return;
          }
        }
      }
      await _authService.setWeeklySlots(weeklySlots);
    } catch (e) {
      toaster.error('Error saving slots: ${e.toString()}');
    } finally {
      isSaving(false);
    }
  }

  bool _isValidTimeSlot(String startTime, String endTime) {
    try {
      final start = _timeToMinutes(startTime);
      final end = _timeToMinutes(endTime);
      return end > start;
    } catch (e) {
      return false;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  bool hasAvailableSlots(String day) {
    if (!weeklySlots.containsKey(day)) return false;
    return weeklySlots[day].any((slot) => slot['isAvailable'] == true);
  }

  int getAvailableSlotsCount(String day) {
    if (!weeklySlots.containsKey(day)) return 0;
    return weeklySlots[day].where((slot) => slot['isAvailable'] == true).length;
  }

  void setupWeekdays() {
    const defaultSlots = [
      {'startTime': '09:00', 'endTime': '12:00', 'isAvailable': true},
      {'startTime': '14:00', 'endTime': '18:00', 'isAvailable': true},
    ];
    final weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    for (final day in weekdays) {
      weeklySlots[day] = List.from(defaultSlots);
    }
    update();
    toaster.success('Weekday slots configured');
  }

  void clearAllSlots() {
    for (final day in days) {
      weeklySlots[day] = [
        {'startTime': '09:00', 'endTime': '10:00', 'isAvailable': false},
      ];
    }
    update();
    toaster.info('All slots cleared');
  }

  @override
  void onInit() {
    super.onInit();
    getWeeklySlots();
  }
}
