import 'package:cheguei/app/app_router.dart';
import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/cheguei_logo.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                  const ChegueiLogo(
                    iconSize: 60,
                    titleSize: 28,
                    showSubtitle: false,
                  ),

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

                      /*ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login realizado com sucesso!'),
                        ),
                      );*/

                      // A navegação será implementada na próxima etapa.
                    },
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
