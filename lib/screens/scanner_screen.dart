import 'package:Dstetico/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  final ValueNotifier<bool> _isTorchOn = ValueNotifier(false);
  bool _isLoading = false;
  bool _isScanning = true;
  bool _showFlashButton = true;

  @override
  void dispose() {
    cameraController.dispose();
    _isTorchOn.dispose();
    super.dispose();
  }

  Future<void> _processScannedCode(String scannedCode) async {
    if (!mounted || _isLoading || !_isScanning) return;

    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      final tipo = scannedCode.length > 50 ? 2 : 1;
      final response = await ApiService.validateCode(scannedCode, tipo);
      final bool esValido = response['codigo'] != 0;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              esValido ? 'USUARIO VÁLIDO' : 'CÓDIGO INVÁLIDO',
              style: TextStyle(
                color: esValido ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            icon: Icon(
              esValido ? Icons.verified_user : Icons.error_outline,
              color: esValido ? Colors.green : Colors.red,
              size: 52,
            ),
            content: esValido
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.person,
                          'Nombre:',
                          response['nombre'],
                        ),
                        _buildInfoRow(
                          Icons.person_outline,
                          'Apellidos:',
                          response['apellidos'],
                        ),
                        _buildInfoRow(
                          Icons.badge,
                          'Documento:',
                          response['documentoidentidad'],
                        ),
                        _buildInfoRow(
                          Icons.transgender,
                          'Sexo:',
                          response['sexo'],
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              response['mensaje'],
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Por favor, verifica el código e intenta nuevamente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isScanning = true);
                },
                child: const Text(
                  'CONTINUAR ESCANEANDO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.color1, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ESCANEAR CÓDIGO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                await cameraController.toggleTorch();
                _isTorchOn.value = !_isTorchOn.value;
                setState(() => _showFlashButton = false);
                await Future.delayed(const Duration(milliseconds: 100));
                setState(() => _showFlashButton = true);
              },
              child: AnimatedScale(
                scale: _showFlashButton ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isTorchOn.value
                            ? Colors.yellow.withOpacity(0.4)
                            : Colors.transparent,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isTorchOn,
                    builder: (context, isTorchOn, child) {
                      return Icon(
                        isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: isTorchOn ? Colors.yellow : Colors.white,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isLoading || capture.barcodes.isEmpty || !_isScanning)
                return;
              final String? code = capture.barcodes.first.rawValue;
              if (code != null) _processScannedCode(code);
            },
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.color1, width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner borders
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCornerBorder(true, true),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCornerBorder(true, false),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCornerBorder(false, true),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCornerBorder(false, false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Enfoca el código QR dentro del marco',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() => _isScanning = !_isScanning);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isScanning ? 'Escaneo activado' : 'Escaneo pausado',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _isScanning ? Colors.green : Colors.orange,
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
              backgroundColor: _isScanning ? AppColors.color1 : Colors.orange,
              elevation: 4,
              child: Icon(
                _isScanning ? Icons.qr_code_scanner : Icons.pause,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.color1,
                      ),
                      strokeWidth: 6,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Validando código...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por favor espera',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCornerBorder(bool isTop, bool isLeft) {
    return SizedBox(width: 50, height: 50, child: CustomPaint());
  }
}
