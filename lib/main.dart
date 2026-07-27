import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'package:UangKu/theme/app_theme.dart';

void main(){

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: router,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    // theme: ThemeData(
    //   colorScheme: ColorScheme.fromSeed(
    //     seedColor:  Colors.blue
    //   ),
    //   useMaterial3: true,
    //   ),

    );
  }
}