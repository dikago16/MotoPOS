import 'package:flutter/material.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';

class CircuitImageScreen extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CircuitImageScreen({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 10.0, // Allow huge zoom
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: const AppLoading(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  AppLocalizations.get('failed_to_load_image'),
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
