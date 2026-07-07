import 'dart:async';

import 'package:cheguei/app/app_router.dart';
import 'package:cheguei/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cheguei/core/widgets/cheguei_logo.dart';
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
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ChegueiLogo(
                iconSize: 60,
                titleSize: 28,
                showSubtitle: false,
              ),

              const SizedBox(height: 24),

              const ChegueiLogo(),

              const SizedBox(height: 12),

              const ChegueiLogo(),

              const SizedBox(height: 40),

              const LoadingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
