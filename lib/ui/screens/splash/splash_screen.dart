import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../activation/activation_screen.dart';
import '../selling/selling_screen.dart';

// ─── Enterprise Design Tokens ─────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B2A);
const _kAccent = Color(0xFF2563EB);
const _kTxtLow = Color(0xFF94A3B8);
// ──────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    // Memberikan jeda waktu agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 2));

    final result = await ActivationService.validateLicense();

    if (!mounted) return;

    if (result['success'] == true) {
      // Jika lisensi valid ATAU offline (sesuai logika di service)
      if (result['is_offline'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SellingScreen()),
      );
    } else {
      // Jika lisensi invalid (403/404) atau tidak ada lisensi
      if (result['is_invalid'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ActivationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.two_wheeler, size: 72, color: _kAccent),
            ),
            const SizedBox(height: 32),
            const Text(
              "MotoPOS",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Motorcycle Service Point of Sales",
              style: TextStyle(
                fontSize: 14,
                color: _kTxtLow,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 64),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(color: _kAccent, strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            const Text(
              "Validating License...",
              style: TextStyle(
                color: _kTxtLow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
