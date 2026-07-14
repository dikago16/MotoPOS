import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/services/app_localizations.dart';

const Color _kAccent = Color(0xFF00B0FF);

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDisposed) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _isDisposed = true; // Prevent multiple pops
        Navigator.pop(context, code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          AppLocalizations.get('scanner'),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          // Scanner overlay box
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: _kAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.get('align_barcode'),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A custom shape for the scanner overlay
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.blue,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  }) : assert(
         borderLength <= cutOutSize / 2 + borderWidth * 2,
         "Border can't be larger than ${cutOutSize / 2 + borderWidth * 2}",
       );

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final adjustedBorderLength = borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : borderLength;
    final adjustedCutOutSize = cutOutSize < width
        ? cutOutSize
        : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - adjustedCutOutSize / 2 + borderOffset,
      -cutOutBottomOffset +
          rect.top +
          height / 2 -
          adjustedCutOutSize / 2 +
          borderOffset,
      adjustedCutOutSize - borderOffset * 2,
      adjustedCutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    canvas
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.top + adjustedBorderLength)
          ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.left + borderRadius, cutOutRect.top),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(cutOutRect.left + adjustedBorderLength, cutOutRect.top),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.top + adjustedBorderLength)
          ..lineTo(cutOutRect.right, cutOutRect.top + borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.right - borderRadius, cutOutRect.top),
            radius: Radius.circular(borderRadius),
            clockwise: false,
          )
          ..lineTo(cutOutRect.right - adjustedBorderLength, cutOutRect.top),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.bottom - adjustedBorderLength)
          ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.left + borderRadius, cutOutRect.bottom),
            radius: Radius.circular(borderRadius),
            clockwise: false,
          )
          ..lineTo(cutOutRect.left + adjustedBorderLength, cutOutRect.bottom),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.bottom - adjustedBorderLength)
          ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(cutOutRect.right - adjustedBorderLength, cutOutRect.bottom),
        borderPaint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
