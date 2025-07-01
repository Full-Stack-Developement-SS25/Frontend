import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_colors.dart';
import '../widgets/section_header.dart';

class JoinEventQRScreen extends StatefulWidget {
  const JoinEventQRScreen({super.key});

  @override
  State<JoinEventQRScreen> createState() => _JoinEventQRScreenState();
}

class _JoinEventQRScreenState extends State<JoinEventQRScreen> {
  bool _scanned = false;
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SectionHeader("QR-Code scannen"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: (capture) {
              if (_scanned) return;
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  setState(() {
                    scannedCode = code;
                    _scanned = true;
                  });

                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Beigetreten zu: $code")),
                    );
                  });
                }
              }
            },
          ),

          // Optionaler Text
          if (!_scanned)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black45,
                child: const Text(
                  "Halte den QR-Code vor die Kamera",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
