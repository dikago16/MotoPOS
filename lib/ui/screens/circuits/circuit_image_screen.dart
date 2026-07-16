import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/app_localizations.dart';
import '../../widgets/app_loading.dart';

class CircuitImageScreen extends StatefulWidget {
  final String title;
  final String imageUrl;

  const CircuitImageScreen({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<CircuitImageScreen> createState() => _CircuitImageScreenState();
}

class _CircuitImageScreenState extends State<CircuitImageScreen> {
  bool _showUi = true;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _toggleUi() {
    setState(() {
      _showUi = !_showUi;
      if (_showUi) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showUi
          ? AppBar(
              title: Text(widget.title, style: const TextStyle(fontSize: 16)),
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              elevation: 0,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: GestureDetector(
        onTap: _toggleUi,
        child: Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 10.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: AppLoading());
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
        ),
      ),
    );
  }
}
