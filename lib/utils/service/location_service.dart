import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class LocationService extends GetxService {
  Future<LocationService> init() async => this;

  Future<Map<String, dynamic>?> getCurrentAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        toaster.error('Location services are disabled. Please enable them.');
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          toaster.error('Location permissions are denied');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        toaster.error('Location permissions are permanently denied. Please enable them in app settings.');
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return {
          'address': _buildAddressString(placemark),
          'pincode': placemark.postalCode ?? '',
          'city': placemark.locality ?? placemark.subLocality ?? '',
          'state': placemark.administrativeArea ?? '',
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
      return null;
    } catch (e) {
      toaster.error('Failed to get location: ${e.toString()}');
      return null;
    }
  }

  String _buildAddressString(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }

    return addressParts.join(', ');
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }
}
