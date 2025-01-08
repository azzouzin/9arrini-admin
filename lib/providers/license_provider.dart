import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

enum LicenseType { none, regular, extended }

final licenseProvider = FutureProvider<LicenseType>((ref) async {
  LicenseType license = LicenseType.none;
  final String? licenseValue = await FirebaseService().getLicense();
  if (licenseValue != null) {
    license = licenseValue == 'extended'
        ? LicenseType.extended
        : licenseValue == 'regular'
            ? LicenseType.regular
            : LicenseType.none;
  }

  return license;
});
