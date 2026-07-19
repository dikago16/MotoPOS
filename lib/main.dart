import 'dart:ui'; // Diperlukan untuk PlatformDispatcher
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Tambahkan ini
import 'firebase_options.dart';

import 'providers/selling_provider.dart';
import 'providers/printer_provider.dart';
import 'providers/circuits_provider.dart';
import 'core/constants/app_colors.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'core/services/app_localizations.dart';

import 'data/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await AppLocalizations.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => SellingProvider()),
        ChangeNotifierProxyProvider<DatabaseService, PrinterProvider>(
          create: (context) => PrinterProvider(context.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? PrinterProvider(db),
        ),
        ChangeNotifierProvider(create: (_) => CircuitsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto POS',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SplashScreen(),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
