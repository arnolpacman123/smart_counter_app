import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smart_counter_app/app/bindings/global_binding.dart';
import 'package:smart_counter_app/app/utils/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _color = Color(0xFF0F9300);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      
      title: 'Smart Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          onPrimaryContainer: Colors.white,
          primaryContainer: _color,
        ),
        appBarTheme: const AppBarTheme(
          color: _color,
          iconTheme: IconThemeData(
            color: _color,
          ),
        ),
        useMaterial3: true,
      ),
      initialBinding: GlobalBinding(),
      initialRoute: Routes.groups,
      routes: Routes.routes,
    );
  }
}
