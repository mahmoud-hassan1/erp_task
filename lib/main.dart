import 'package:erp_task/core/utils/di.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:erp_task/core/theme/app_theme.dart';
import 'package:erp_task/core/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setup() ;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Document Manager',
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router,
    );
  }
}
