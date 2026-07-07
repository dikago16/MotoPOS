import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/selling_provider.dart';
import 'providers/printer_provider.dart';
import 'ui/screens/selling/selling_screen.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SellingProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto POS',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SellingScreen(),
    );
  }
}
