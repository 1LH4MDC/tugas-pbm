// lib/main.dart

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/submit_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false, 
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ilham Dwi Cahya',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C344D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/submit': (context) => const SubmitScreen(),
      },
    );
  }
}

// ─── Splash: cek token, langsung ke login atau home ──────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: Constants.tokenKey);
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C344D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A6B9A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tugas PBM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pemograman Berbasis Mobile',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF1A6B9A)),
          ],
        ),
      ),
    );
  }
}