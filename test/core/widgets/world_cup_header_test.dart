import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/core/app_info/app_info.dart';
import 'package:world_cup_schedule_app/core/widgets/world_cup_header.dart';
import 'package:world_cup_schedule_app/core/widgets/app_version_badge.dart';

void main() {
  group('WorldCupHeader Widget Tests', () {
    final testAppInfo = AppInfo(
      appName: 'Test World Cup',
      version: '0.8.2',
      buildNumber: '15',
      versionLabel: 'v0.8.2',
    );

    Widget buildTestableHeader(Widget header) {
      return MaterialApp(
        home: Scaffold(
          body: AppInfoScope(
            appInfo: testAppInfo,
            child: header,
          ),
        ),
      );
    }

    testWidgets('should render title and subtitle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableHeader(
          const WorldCupHeader(
            title: 'Test Title',
            subtitle: 'Test Subtitle',
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.text('FIFA WORLD CUP'), findsOneWidget);
    });

    testWidgets('should display version badge if showVersion is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableHeader(
          const WorldCupHeader(
            title: 'Test Title',
            showVersion: true,
          ),
        ),
      );

      expect(find.byType(AppVersionBadge), findsOneWidget);
      expect(find.text('v0.8.2'), findsOneWidget);
    });

    testWidgets('should not display version badge if showVersion is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableHeader(
          const WorldCupHeader(
            title: 'Test Title',
            showVersion: false,
          ),
        ),
      );

      expect(find.byType(AppVersionBadge), findsNothing);
    });

    testWidgets('should trigger onBrandingTap callback when branding tapped', (WidgetTester tester) async {
      bool brandingTapped = false;

      await tester.pumpWidget(
        buildTestableHeader(
          WorldCupHeader(
            title: 'Test Title',
            onBrandingTap: () {
              brandingTapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('FIFA WORLD CUP'));
      await tester.pump();

      expect(brandingTapped, isTrue);
    });

    testWidgets('should display actions if provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableHeader(
          const WorldCupHeader(
            title: 'Test Title',
            actions: [
              Text('Action 1'),
              Text('Action 2'),
            ],
          ),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });
  });
}
