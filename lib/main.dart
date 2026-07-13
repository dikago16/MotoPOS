import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Tambahkan 3 baris import Firebase ini
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart'; // File ini dihasilkan oleh flutterfire configure

import 'providers/selling_provider.dart';
import 'providers/printer_provider.dart';
import 'providers/circuits_provider.dart';
import 'core/constants/app_colors.dart';
import 'ui/screens/splash/splash_screen.dart';

// Ubah main menjadi async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tambahkan blok inisialisasi Firebase ini
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SellingProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
        ChangeNotifierProvider(create: (_) => CircuitsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // (Opsional) Buat instance Analytics di sini agar mudah diakses
  // jika Anda ingin melemparnya ke widget lain atau untuk NavigatorObserver nanti.
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto POS',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SplashScreen(),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
