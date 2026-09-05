import 'package:cheguei/app/app_router.dart';
import 'package:cheguei/core/widgets/cheguei_button.dart';
//import 'package:cheguei/core/widgets/cheguei_logo.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:cheguei/services/auth/biometric_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginWithBiometrics() async {
    final user = StorageService.getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário cadastrado.')),
      );
      return;
    }

    final canAuthenticate = await BiometricService.canAuthenticate();

    if (!canAuthenticate) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometria não disponível neste dispositivo.'),
        ),
      );
      return;
    }

    final authenticated = await BiometricService.authenticate();

    if (!mounted) return;

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível autenticar pela biometria.'),
        ),
      );
      return;
    }

    if (user.firstAccess) {
      context.go(AppRoutes.profile);
    } else {
      context.go(AppRoutes.assistant);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/images/logo_cheguei.png', width: 220),

                  const SizedBox(height: 24),

                  const Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Entre para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 40),

                  const SizedBox(height: 40),

                  ChegueiTextField(
                    controller: emailController,
                    label: 'E-mail',
                    hint: 'Digite seu e-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  ChegueiTextField(
                    controller: passwordController,
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 30),

                  ChegueiButton(
                    text: 'Entrar',
                    onPressed: () {
                      final user = StorageService.getUser();

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nenhum usuário cadastrado.'),
                          ),
                        );
                        return;
                      }

                      if (emailController.text.trim() != user.email ||
                          passwordController.text != user.password) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-mail ou senha inválidos.'),
                          ),
                        );
                        return;
                      }

                      //context.go(AppRoutes.profile);

                      if (user.firstAccess) {
                        context.go(AppRoutes.profile);
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: loginWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Entrar com biometria'),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      context.push(AppRoutes.register);
                    },
                    child: const Text('Cadastrar-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
