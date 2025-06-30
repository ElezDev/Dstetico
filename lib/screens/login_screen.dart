import 'package:Dstetico/services/alert_service.dart';
import 'package:Dstetico/services/api_service.dart';
import 'package:Dstetico/widgets/custom_button.dart';
import 'package:Dstetico/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _showPassword = false; // Nuevo estado para mostrar/ocultar contraseña

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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset('assets/fondo_login.png', fit: BoxFit.cover),
              ),

              Center(
                child: Container(
                  width: isSmall ? double.infinity : 400,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1886E4).withAlpha(70),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withAlpha(77)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF053B99).withAlpha(51),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FlutterLogo(size: 80)
                            .animate()
                            .fadeIn(duration: 700.ms)
                            .slideY(begin: -0.3),
                        const SizedBox(height: 24),
                        Text(
                          'Bienvenido',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11D6F8),
                            letterSpacing: 1.2,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                        const SizedBox(height: 24),
                        CustomTextField(
                              controller: _usuarioController,
                              label: 'Usuario',
                              validator: (value) =>
                                  value!.isEmpty ? 'Ingrese su usuario' : null,
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 400.ms)
                            .slideX(begin: -0.2),
                        const SizedBox(height: 20),
                        TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              validator: (value) => value!.isEmpty
                                  ? 'Ingrese su contraseña'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withAlpha(150),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF11D6F8),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 500.ms)
                            .slideX(begin: 0.2),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              activeColor: Color(0xFF1886E4),
                            ),
                            Text(
                              'Recuérdame',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ).animate().fadeIn(delay: 550.ms),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: _isLoading ? null : _login,
                          isLoading: _isLoading,
                          text: 'Iniciar Sesión',
                          backgroundColor: Color(0xFF1886E4),
                          textColor: Colors.white,
                        ).animate().fadeIn(delay: 600.ms),
                      ],
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
