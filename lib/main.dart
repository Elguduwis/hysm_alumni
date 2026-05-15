import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'services/directory_service.dart';
import 'services/dues_service.dart';
import 'services/announcement_service.dart';
import 'services/meeting_service.dart';
import 'screens/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => DuesService()),
        ChangeNotifierProvider(create: (_) => AnnouncementService()),
        ChangeNotifierProvider(create: (_) => MeetingService()),
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
          secondary: const Color(0xFFFFC107), // Gold accent
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
