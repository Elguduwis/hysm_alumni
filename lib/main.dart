import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'services/directory_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://wpkqiguvhnymqopzjfej.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indwa3FpZ3V2aG55bXFvcHpqZmVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NTU2NjYsImV4cCI6MjA5NDQzMTY2Nn0.OO3DLPD6b0r0GCw4une2wDNe0uRkVtDwthvZ7XiG40Y',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DirectoryService()),
      ],
      child: const HYSMApp(),
    ),
  );
}

class HYSMApp extends StatelessWidget {
  const HYSMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HYSM Alumni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          primary: const Color(0xFF0D47A1),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const AuthScreen() : const HomeScreen();
  }
}
