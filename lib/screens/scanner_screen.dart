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
  void initState() {
    super.initState();
  }


 

  @override
  void dispose() {
    cameraController.dispose();
    _isTorchOn.dispose();
    super.dispose();
  }

 // CÓDIGO CORREGIDO
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
          title: Text(
            esValido ? 'Usuario válido' : 'Código inválido',
            style: TextStyle(
              color: esValido ? Colors.green : Colors.red,
            ),
          ),
          icon: Icon(
            esValido ? Icons.check_circle : Icons.error,
            color: esValido ? Colors.green : Colors.red,
            size: 48,
          ),
          content: esValido
              ? Column( 
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre: ${response['nombre']}'),
                    Text('Apellidos: ${response['apellidos']}'),
                    Text('Documento: ${response['documentoidentidad']}'),
                    Text('Sexo: ${response['sexo']}'),
                  ],
                )
              : Column( 
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      response['mensaje'],
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Por favor, verifica el código e intenta nuevamente.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isScanning = true;
                });
              },
              child: const Text('OK'),
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isLoading || capture.barcodes.isEmpty || !_isScanning)
                return;

              final String? code = capture.barcodes.first.rawValue;
              if (code != null) {
                _processScannedCode(code);
              }
            },
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green.withAlpha(204),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await cameraController.toggleTorch();
                _isTorchOn.value = !_isTorchOn.value;

                // Feedback visual
                setState(() {
                  _showFlashButton = false;
                });
                await Future.delayed(const Duration(milliseconds: 100));
                setState(() {
                  _showFlashButton = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isTorchOn.value ? 'Flash encendido ⚡' : 'Flash apagado',
                    ),
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: AnimatedScale(
                scale: _showFlashButton ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isTorchOn.value
                            ? Colors.yellow.withAlpha(204)
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
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 130,
            right: 20,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isTorchOn,
              builder: (context, isTorchOn, child) {
                return AnimatedOpacity(
                  opacity: isTorchOn ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withAlpha(51),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.yellow.withAlpha(128),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'FLASH ACTIVO',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isScanning = !_isScanning;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isScanning ? 'Escaneo activado ▶' : 'Escaneo pausado ⏸',
                    ),
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              backgroundColor: _isScanning ? Colors.green : Colors.orange,
              child: Icon(
                _isScanning ? Icons.qr_code_scanner : Icons.pause,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(102),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando código...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

}
