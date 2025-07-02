import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/home/home_page.dart';
import 'package:folder_authenticator/services/config_service.dart';
import 'package:folder_authenticator/services/encryption_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a container to initialize services before the app starts
  final container = ProviderContainer();
  
  // Initialize services
  await container.read(configServiceProvider).initialize();
  await container.read(encryptionServiceProvider).initialize();
  
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folder Authenticator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Respect system theme
      home: const HomePage(),
    );
  }
}
