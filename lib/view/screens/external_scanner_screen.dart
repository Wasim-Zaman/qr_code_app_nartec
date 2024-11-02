import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalScannerScreen extends StatefulWidget {
  const ExternalScannerScreen({super.key});

  @override
  State<ExternalScannerScreen> createState() => _ExternalScannerScreenState();
}

class _ExternalScannerScreenState extends State<ExternalScannerScreen> {
  String _scannedData = '';
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleKeyEvent(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Handle the complete scan
        if (_scannedData.isNotEmpty) {
          try {
            final uri = Uri.parse(_scannedData);
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
      } else if (event.character != null) {
        setState(() {
          _scannedData += event.character!;
          _controller.text = _scannedData;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('External Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _scannedData = '';
                _controller.clear();
              });
            },
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ready to receive scan data',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scanned Result:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      readOnly: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'No data scanned yet',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_scannedData.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _scannedData));
                        AppSnackbar.showSnackbar(
                          context,
                          message: 'Copied to clipboard',
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _scannedData = '';
                        _controller.clear();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
