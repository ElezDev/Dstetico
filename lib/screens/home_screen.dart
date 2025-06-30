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
    const Center(child: Text('Inicio')),
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
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color5,
      appBar: AppBar(
        backgroundColor: AppColors.color2,
        title: const Text('Inicio', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_qr.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(77),
            ),
          ),

  
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),

      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        
        onPressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        backgroundColor: AppColors.color2,
        child: const Icon(Icons.qr_code_scanner),
      ).animate().scale(duration: 400.ms).fadeIn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: AppColors.color1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 'Inicio', 0),
            _buildNavItem(Icons.history, 'Historial', 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.person, 'Perfil', 3),
            _buildNavItem(Icons.settings, 'Ajustes', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.color3 : AppColors.color9),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.color3 : AppColors.color9,
              fontSize: 12,
            ),
          ),
        ],
      ).animate().fadeIn(delay: (index * 100).ms),
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
          _buildDrawerItem(Icons.person, 'Perfil', () {}),
          _buildDrawerItem(Icons.history, 'Historial de Escaneos', () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Información de Sesión'),
            subtitle: Text('Código: ${_userData?['codigo'] ?? 'N/A'}'),
          ),
          const Spacer(),
          _buildDrawerItem(Icons.exit_to_app, 'Cerrar Sesión', _logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.color3),
      title: Text(title, style: TextStyle(color: AppColors.color3)),
      onTap: onTap,
    );
  }
}
