import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests location, photo library, and camera permissions.
class PermissionsService {
  PermissionsService._();

  static final PermissionsService instance = PermissionsService._();

  static const location = AppPermission.location;
  static const photos = AppPermission.photos;
  static const camera = AppPermission.camera;

  /// Permissions shown on the onboarding screen, in request order.
  static const onboardingPermissions = [
    AppPermission.location,
    AppPermission.photos,
    AppPermission.camera,
  ];

  Future<PermissionStatus> status(AppPermission permission) async {
    return (await _map(permission)).status;
  }

  Future<Map<AppPermission, PermissionStatus>> statuses() async {
    final result = <AppPermission, PermissionStatus>{};
    for (final p in onboardingPermissions) {
      result[p] = await status(p);
    }
    return result;
  }

  Future<PermissionStatus> request(AppPermission permission) async {
    return (await _map(permission)).request();
  }

  /// Request all onboarding permissions. Returns the latest status for each.
  Future<Map<AppPermission, PermissionStatus>> requestAll() async {
    final result = <AppPermission, PermissionStatus>{};
    for (final p in onboardingPermissions) {
      result[p] = await request(p);
    }
    return result;
  }

  Future<bool> openSettings() => openAppSettings();

  Future<Permission> _photoPermission() async {
    if (!Platform.isAndroid) return Permission.photos;

    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    return sdk >= 33 ? Permission.photos : Permission.storage;
  }

  Future<Permission> _map(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        return Permission.locationWhenInUse;
      case AppPermission.photos:
        return _photoPermission();
      case AppPermission.camera:
        return Permission.camera;
    }
  }
}

enum AppPermission { location, photos, camera }

extension AppPermissionCopy on AppPermission {
  String get title {
    switch (this) {
      case AppPermission.location:
        return 'Location';
      case AppPermission.photos:
        return 'Photos';
      case AppPermission.camera:
        return 'Camera';
    }
  }

  String get description {
    switch (this) {
      case AppPermission.location:
        return 'Find runs and clubs near you on the map.';
      case AppPermission.photos:
        return 'Choose a profile photo from your library.';
      case AppPermission.camera:
        return 'Take a profile photo or share run moments.';
    }
  }
}
