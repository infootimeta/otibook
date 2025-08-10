import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void reassemble() {
    super.reassemble();
    // Hot-reload’da Android’de stop, iOS’ta start önerilir.
    if (Platform.isAndroid) {
      _controller.stop();
    } else if (Platform.isIOS) {
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanArea =
        (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) async {
              if (_handled) return;
              final codes = capture.barcodes;
              final value = codes.isNotEmpty
                  ? (codes.first.rawValue ?? '')
                  : '';
              if (value.isEmpty) return;

              _handled = true;
              final navigator = Navigator.of(context); // await öncesi referans
              await _controller.stop();
              if (!mounted) return;
              navigator.pop(value);
            },
          ),

          // Üstte kapatma, torch ve kamera değiştir butonları
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () => _controller.toggleTorch(),
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () => _controller.switchCamera(),
                ),
              ],
            ),
          ),

          // Alt bilgilendirme
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Lütfen öğrenci QR kodunu tarayın',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Delikli overlay (gerçek cut-out)
          IgnorePointer(
            child: _ScannerOverlay(
              cutOutSize: scanArea,
              borderColor: Theme.of(context).primaryColor,
              borderWidth: 4,
              borderRadius: 16, // ARTIK parametre var
              overlayOpacity: 0.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    required this.cutOutSize,
    this.borderColor = Colors.white,
    this.borderWidth = 4,
    this.borderRadius = 12,
    this.overlayOpacity = 0.45,
  });

  final double cutOutSize;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final left = (w - cutOutSize) / 2;
        final top = (h - cutOutSize) / 2;
        final rect = Rect.fromLTWH(left, top, cutOutSize, cutOutSize);

        return CustomPaint(
          size: Size(w, h),
          painter: _CutOutPainter(
            cutOutRect: RRect.fromRectAndRadius(
              rect,
              Radius.circular(borderRadius),
            ),
            overlayOpacity: overlayOpacity,
            borderColor: borderColor,
            borderWidth: borderWidth,
          ),
        );
      },
    );
  }
}

class _CutOutPainter extends CustomPainter {
  _CutOutPainter({
    required this.cutOutRect,
    required this.overlayOpacity,
    required this.borderColor,
    required this.borderWidth,
  });

  final RRect cutOutRect;
  final double overlayOpacity;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: overlayOpacity)
      ..style = PaintingStyle.fill;

    // Tüm ekranı boyayan path
    final bgPath = Path()..addRect(Offset.zero & size);
    // Delik path
    final holePath = Path()..addRRect(cutOutRect);
    // Delikli maske: bg - hole
    final cutOut = Path.combine(PathOperation.difference, bgPath, holePath);
    canvas.drawPath(cutOut, overlayPaint);

    // Kenarlık
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(cutOutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CutOutPainter oldDelegate) {
    return oldDelegate.cutOutRect != cutOutRect ||
        oldDelegate.overlayOpacity != overlayOpacity ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
