import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motopos/ui/widgets/app_loading.dart';
import 'package:motopos/core/services/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.init();
  });

  testWidgets('AppLoading smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AppLoading(message: 'Tunggu sebentar...'),
      ),
    ));

    // Verify that the CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify that our custom message is displayed
    expect(find.text('Tunggu sebentar...'), findsOneWidget);
  });

  testWidgets('AppLoading full screen mode shows default text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AppLoading(isFullScreen: true),
      ),
    ));

    // Verify that the CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // It should display the default 'loading' text from AppLocalizations
    expect(find.text('Loading...'), findsOneWidget);
  });
}
