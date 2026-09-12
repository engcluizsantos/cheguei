import 'package:cheguei/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:cheguei/services/notifications/notification_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: ChegueiApp(),
    ),
  );
}
