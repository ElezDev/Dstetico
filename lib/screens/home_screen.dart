import 'package:Dstetico/screens/login_screen.dart';
import 'package:Dstetico/screens/scanner_screen.dart';
import 'package:Dstetico/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Scanner')),
    const Center(child: Text('Historial')),
    ScannerScreen(),
    const Center(child: Text('Perfil')),
    const Center(child: Text('Ajustes')),
  ];

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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.color5,
      appBar: AppBar(
        backgroundColor: AppColors.color2,
        title: const Text('D-Stetico', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/fondo_qr.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.color5.withOpacity(0.3),
                      AppColors.color1.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            IndexedStack(index: _currentIndex, children: _screens),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 0,
          ), 
          child: Container(
            height: 60,
            color: AppColors.color1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Inicio', 0),
                _buildNavItem(Icons.history, 'Historial', 1),
                _buildNavItem(Icons.qr_code_scanner, 'QR', 2),
                _buildNavItem(Icons.person, 'Perfil', 3),
                _buildNavItem(Icons.settings, 'Ajustes', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppColors.color3 : Colors.white;
    final double activeSize = 30;
    final double inactiveSize = 24;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.color10.withAlpha(64),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeOutBack,
              margin: EdgeInsets.only(bottom: isActive ? 4 : 0),
              child: Icon(
                icon,
                color: color,
                size: isActive ? activeSize : inactiveSize,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: 300.ms,
              style: TextStyle(
                color: color,
                fontSize: isActive ? 13 : 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.color2, AppColors.color3],
              ),
            ),
            accountName: Text(
              _userData?['nombre'] ?? 'Usuario no identificado',
              style: const TextStyle(fontSize: 18),
            ),
            accountEmail: Text(
              _userData?['login'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.color4,
              child: Text(
                _userData?['nombre']?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.person_outline, 'Perfil', () {}),
                _buildDrawerItem(Icons.history, 'Historial de Escaneos', () {}),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Código de sesión'),
                  subtitle: Text('Código: ${_userData?['codigo'] ?? 'N/A'}'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDrawerItem(Icons.logout, 'Cerrar Sesión', _logout),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.color3),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}
