import 'package:flutter/material.dart';
import 'package:pixora/core/utils/provider_binding.dart';
import 'package:pixora/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviderBinding.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
