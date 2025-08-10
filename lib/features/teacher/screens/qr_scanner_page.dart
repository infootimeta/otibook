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
    // hot-reload için güvenli yeniden başlat
    _controller.stop();
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_handled) return;
              final codes = capture.barcodes;
              final value = codes.isNotEmpty ? (codes.first.rawValue ?? '') : '';
              if (value.isEmpty) return;

              _handled = true;
              final navigator = Navigator.of(context); // context’i await öncesi al
              await _controller.stop();
              if (!mounted) return;
              navigator.pop(value);
            },
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(102),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Lütfen öğrenci QR kodunu tarayın',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          IgnorePointer(
            child: _ScannerOverlay(
              cutOutSize: scanArea,
              borderColor: Theme.of(context).primaryColor,
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
  });

  final double cutOutSize;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final left = (w - cutOutSize) / 2;
      final top = (h - cutOutSize) / 2;

      return Stack(children: [
        Container(color: Colors.black45),
        Positioned(
          left: left,
          top: top,
          width: cutOutSize,
          height: cutOutSize,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
          ),
        ),
      ]);
    });
  }
}
