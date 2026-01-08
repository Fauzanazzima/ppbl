import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'CardTheme.dart';
import 'login.dart';
import 'registrasi.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'anggaran.dart';
import 'transaksi.dart';
import 'tabungan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // SQFLITE DESKTOP
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //  THEME NOTIFIER
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aplikasi Keuangan',

          // MODE GELAP
          themeMode: currentMode,

          // MODE TERANG
          theme: AppTheme.light,

          darkTheme: AppTheme.dark,

          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/registrasi': (context) => const RegistrasiPage(),
            '/dashboard': (context) => const MainScreen(),
            '/profile': (context) => const ProfilePage(),
            '/anggaran': (context) => const BudgetPage(),
            '/transaksi': (context) => const TransaksiPage(),
            '/tabungan': (context) => const TabunganScreen(),
          },
        );
      },
    );
  }
}
