import 'package:Dstetico/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dstetico/services/api_service.dart';
import 'package:Dstetico/services/alert_service.dart';
import 'package:Dstetico/widgets/custom_button.dart';
import 'package:Dstetico/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _usuarioController.text = prefs.getString('savedUsername') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedUsername', _usuarioController.text.trim());
      await prefs.setString('savedPassword', _passwordController.text.trim());
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('savedUsername');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.login(
        _usuarioController.text.trim(),
        _passwordController.text.trim(),
      );
      await _saveCredentials();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        AlertService.showErrorDialog(context: context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/fondo_login.png'),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(153),
                        Colors.blue.shade900.withAlpha(153),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: isSmall ? double.infinity : 420,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.color5.withAlpha(77),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.color1.withAlpha(128),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.color3.withAlpha(51),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Image.asset(
                        'assets/icons/icon.png',
                        width: 80,
                        height: 80,
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.7, 0.7)),
  
                          const SizedBox(height: 20),
                          Text(
                                'Bienvenido',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.color2,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .slideY(begin: -0.2),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _usuarioController,
                            label: 'Usuario',
                            validator: (value) =>
                                value!.isEmpty ? 'Ingrese su usuario' : null,
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            obscureText: !_showPassword,
                            showToggleVisibility: true,
                            isPasswordVisible: _showPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            validator: (value) =>
                                value!.isEmpty ? 'Ingrese su contraseña' : null,
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),

                          const SizedBox(height: 12),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) =>
                                      setState(() => _rememberMe = value!),
                                  activeColor: AppColors.color4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(color: Colors.white54),
                                  visualDensity:
                                      VisualDensity.compact, // más limpio
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Recuérdame',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 500.ms),

                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: _isLoading ? null : _login,
                            isLoading: _isLoading,
                            text: 'Iniciar Sesión',
                            backgroundColor: AppColors.color2,
                            textColor: Colors.white,
                          ).animate().fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
