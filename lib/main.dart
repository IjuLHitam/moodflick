import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/auth_screen.dart';
import 'screens/main_nav.dart';
import 'screens/onboarding_screen.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MoodFlickApp(),
    ),
  );
}

class MoodFlickApp extends StatelessWidget {
  const MoodFlickApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoodFlick',
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        primaryColor: const Color(0xFFE92D35),
        textTheme: GoogleFonts.notoSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE92D35),
          brightness: Brightness.light,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 76,
          elevation: 0,
          backgroundColor: const Color(0xFFFFECEC),
          indicatorColor: const Color(0xFFE92D35).withOpacity(0.16),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        primaryColor: const Color(0xFFE92D35),
        textTheme: GoogleFonts.notoSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE92D35),
          brightness: Brightness.dark,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 76,
          elevation: 0,
          backgroundColor: const Color(0xFF17171F),
          indicatorColor: const Color(0xFFE92D35).withOpacity(0.18),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const StartGate(),
    );
  }
}

class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  bool loading = true;
  bool seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    checkStartPage();
  }

  Future<void> checkStartPage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050509),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE92D35),
          ),
        ),
      );
    }

    if (!seenOnboarding) {
      return const OnboardingScreen();
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const AuthScreen();
    }

    return const MainNav();
  }
}