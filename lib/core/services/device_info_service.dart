import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Servicio para obtener información del dispositivo y la aplicación
class DeviceInfoService {
  static DeviceInfoService? _instance;
  static DeviceInfoService get instance => _instance ??= DeviceInfoService._();

  DeviceInfoService._();

  /// Obtener información completa del dispositivo
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      final deviceInfo = <String, dynamic>{
        'platform': _getPlatform(),
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'appName': packageInfo.appName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Agregar información específica de la plataforma
      if (Platform.isAndroid) {
        deviceInfo.addAll(await _getAndroidInfo());
      } else if (Platform.isIOS) {
        deviceInfo.addAll(await _getIOSInfo());
      }

      return deviceInfo;
    } catch (e) {
      return {
        'platform': _getPlatform(),
        'error': 'Error obteniendo información del dispositivo: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Obtener información básica del dispositivo como string
  Future<String> getDeviceInfoString() async {
    final info = await getDeviceInfo();
    return '${info['platform']} - ${info['appVersion']} (${info['buildNumber']})';
  }

  /// Obtener plataforma
  String _getPlatform() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Obtener información específica de Android
  Future<Map<String, dynamic>> _getAndroidInfo() async {
    try {
      return {
        'androidVersion': Platform.operatingSystemVersion,
        'isPhysicalDevice': true, // Asumimos que es un dispositivo físico
      };
    } catch (e) {
      return {
        'androidVersion': 'Unknown',
        'error': 'Error obteniendo información de Android: $e',
      };
    }
  }

  /// Obtener información específica de iOS
  Future<Map<String, dynamic>> _getIOSInfo() async {
    try {
      return {
        'iosVersion': Platform.operatingSystemVersion,
        'isPhysicalDevice': true, // Asumimos que es un dispositivo físico
      };
    } catch (e) {
      return {
        'iosVersion': 'Unknown',
        'error': 'Error obteniendo información de iOS: $e',
      };
    }
  }

  /// Obtener información de localización
  Map<String, dynamic> getLocalizationInfo() {
    return {
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffset': DateTime.now().timeZoneOffset.inHours,
    };
  }

  /// Obtener información de red
  Map<String, dynamic> getNetworkInfo() {
    return {
      'connectionType': 'Unknown', // Se puede mejorar con connectivity_plus
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 