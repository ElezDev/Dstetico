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
  Map<String, dynamic>? _userData;
  bool _isScanning = true;

  bool _showFlashButton = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await ApiService.loadSession();
    setState(() {
      _userData = data;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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

    // La clave del cambio está aquí: `response['codigo'] != 0` (sin comillas)
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
              ? Column( // Contenido para CÓDIGO VÁLIDO
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre: ${response['nombre']}'),
                    Text('Apellidos: ${response['apellidos']}'),
                    Text('Documento: ${response['documentoidentidad']}'),
                    Text('Sexo: ${response['sexo']}'),
                  ],
                )
              : Column( // Contenido para CÓDIGO INVÁLIDO
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
      appBar: AppBar(
        title: const Text('Escanear Código'),
        actions: [
          // Eliminamos el botón de flash del AppBar
        ],
      ),
      drawer: _buildDrawer(),
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

          // Marco de escaneo personalizado
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green.withOpacity(0.8),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Botón de flash grande en la esquina inferior derecha
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
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isTorchOn.value
                            ? Colors.yellow.withOpacity(0.8)
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

          // Indicador de estado del flash
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
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.yellow.withOpacity(0.5),
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

          // Botón de pausa/play del escaneo
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
              color: Colors.black.withOpacity(0.4),
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userData?['nombre'] ?? 'Usuario no identificado',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _userData?['login'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _userData?['nombre']?.substring(0, 1) ?? '?',
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.green),
            title: const Text('Escanear Código'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blueGrey),
            title: const Text('Información de Sesión'),
            subtitle: Text('Código: ${_userData?['codigo'] ?? 'N/A'}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Información de Sesión'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuario: ${_userData?['nombre'] ?? 'N/A'}'),
                      Text('Login: ${_userData?['login'] ?? 'N/A'}'),
                      Text('Código: ${_userData?['codigo'] ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
