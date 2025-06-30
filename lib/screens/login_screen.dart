import 'package:Dstetico/services/api_service.dart';
import 'package:Dstetico/widgets/custom_button.dart';
import 'package:Dstetico/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ApiService.login(
        _usuarioController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                    color: const Color(0xFF1886E4).withAlpha(70), // color5
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withAlpha(77)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          0xFF053B99,
                        ).withAlpha(51),
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
                            color: Color(0xFF11D6F8), // color4
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
                        CustomTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              obscureText: true,
                              validator: (value) => value!.isEmpty
                                  ? 'Ingrese su contraseña'
                                  : null,
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 500.ms)
                            .slideX(begin: 0.2),
                        const SizedBox(height: 30),
                        CustomButton(
                          onPressed: _isLoading ? null : _login,
                          isLoading: _isLoading,
                          text: 'Iniciar Sesión',
                          backgroundColor: Color(0xFF1886E4), // color2
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
