import 'package:cheguei/app/app_router.dart';
import 'package:cheguei/app/app_theme.dart';
import 'package:flutter/material.dart';

class ChegueiApp extends StatelessWidget {
  const ChegueiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Cheguei',

      theme: AppTheme.lightTheme,

      routerConfig: AppRouter.router,
    );
  }
}