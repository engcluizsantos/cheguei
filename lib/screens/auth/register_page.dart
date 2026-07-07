import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/cheguei_logo.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar conta")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const ChegueiLogo(
                iconSize: 60,
                titleSize: 28,
                showSubtitle: false,
              ),

              const SizedBox(height: 32),

              ChegueiTextField(
                controller: nameController,
                label: "Nome",
                hint: "Digite seu nome",
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: emailController,
                label: "E-mail",
                hint: "Digite seu e-mail",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: passwordController,
                label: "Senha",
                hint: "Digite sua senha",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: confirmPasswordController,
                label: "Confirmar senha",
                hint: "Digite novamente sua senha",
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
              ),

              const SizedBox(height: 32),

              ChegueiButton(
                text: "Criar conta",
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preencha todos os campos.'),
                      ),
                    );
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('As senhas não coincidem.')),
                    );
                    return;
                  }

                  final user = UserModel(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );

                  await StorageService.saveUser(user);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conta criada com sucesso!')),
                  );

                  context.pop();
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Voltar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
