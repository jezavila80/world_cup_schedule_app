import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:world_cup_schedule_app/core/app_info/app_info.dart';
import 'package:world_cup_schedule_app/core/app_info/app_version_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppVersionService Tests', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'Test World Cup',
        packageName: 'com.example.world_cup_schedule_app',
        version: '1.2.3',
        buildNumber: '45',
        buildSignature: 'signature',
      );
    });

    test('should initialize and cache AppInfo successfully', () async {
      final service = AppVersionService();

      await service.initialize();

      // Test sync accessor
      final appInfo = service.getAppInfoSync();
      expect(appInfo.appName, equals('World Cup Schedule'));
      expect(appInfo.version, equals('1.2.3'));
      expect(appInfo.buildNumber, equals('45'));
      expect(appInfo.versionLabel, equals('v1.2.3'));
    });

    test('should support mock values in constructor', () async {
      final service = AppVersionService(mockVersion: '9.9.9', mockBuildNumber: '99');
      
      await service.initialize();

      final appInfo = service.getAppInfoSync();
      expect(appInfo.version, equals('9.9.9'));
      expect(appInfo.buildNumber, equals('99'));
    });

    test('should return correct labels', () async {
      final service = AppVersionService();
      
      await service.initialize();

      expect(await service.getVersion(), equals('1.2.3'));
      expect(await service.getBuildNumber(), equals('45'));
      expect(await service.getVersionLabel(), equals('v1.2.3'));
      expect(await service.getFullVersionLabel(), equals('v1.2.3+45'));
    });
  });
}
