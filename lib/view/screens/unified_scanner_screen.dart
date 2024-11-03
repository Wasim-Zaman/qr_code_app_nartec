import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class UnifiedScannerScreen extends StatefulWidget {
  const UnifiedScannerScreen({super.key});

  @override
  State<UnifiedScannerScreen> createState() => _UnifiedScannerScreenState();
}

class _UnifiedScannerScreenState extends State<UnifiedScannerScreen> {
  MobileScannerController? cameraController;
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String scannedData = '';
  bool isCameraActive = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameraController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          message: 'Failed to initialize camera',
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void toggleCamera() async {
    setState(() {
      isCameraActive = !isCameraActive;
    });

    if (isCameraActive) {
      await _initializeCamera();
    } else {
      cameraController?.dispose();
      cameraController = null;
    }
  }

  Future<void> _handleScan(String? scanData) async {
    if (scanData == null) return;

    try {
      final uri = Uri.parse(scanData);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          message: 'Invalid QR code format',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleKeyEvent(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (scannedData.isNotEmpty) {
          await _handleScan(scannedData);
        }
      } else if (event.character != null) {
        setState(() {
          scannedData += event.character!;
          textController.text = scannedData;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        });
      }
    }
  }

  Widget _buildCameraSection() {
    if (!isCameraActive || cameraController == null) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: cameraController!,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              _handleScan(barcodes.first.rawValue);
            }
          },
        ),
        CustomPaint(
          painter: ScannerOverlay(),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner Pro'),
        actions: [
          if (isCameraActive && cameraController != null) ...[
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController?.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: () => cameraController?.switchCamera(),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Camera Section (Top 60% of screen)
          Expanded(
            flex: 60,
            child: _buildCameraSection(),
          ),

          // Camera Toggle Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: toggleCamera,
              icon: Icon(isCameraActive
                  ? Icons.camera_alt_outlined
                  : Icons.camera_alt),
              label: Text(isCameraActive ? 'Disable Camera' : 'Enable Camera'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // External Scanner Section (Bottom 35% of screen)
          Expanded(
            flex: 35,
            child: RawKeyboardListener(
              focusNode: focusNode,
              onKey: _handleKeyEvent,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'External Scanner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              scannedData = '';
                              textController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: textController,
                          readOnly: true,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Waiting for external scanner input...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            scanArea,
            const Radius.circular(12),
          )),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
