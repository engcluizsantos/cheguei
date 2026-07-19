import 'dart:async';

import 'package:cheguei/app/app_router.dart';
//import 'package:cheguei/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//import 'package:cheguei/core/widgets/cheguei_logo.dart';
import 'package:cheguei/core/widgets/loading_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppTheme.background,
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_cheguei.png', width: 240),

              const SizedBox(height: 32),

              const Text(
                'Mobilidade Urbana Inteligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 48),

              const LoadingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
