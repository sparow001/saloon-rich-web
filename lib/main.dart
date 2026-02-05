import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart'; // Supabase යතුරු ඇති ෆයිල් එක
import 'screens/login_screen.dart'; // අපි හැදූ Login පිටුව

Future<void> main() async {
  // 1. Flutter එන්ජිම හරියට පණ ගන්වන්න
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Supabase ඩේටාබේස් එක සම්බන්ධ කරන්න
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // 3. ඇප් එක රන් කරන්න
  runApp(const SaloonRichApp());
}

class SaloonRichApp extends StatelessWidget {
  const SaloonRichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saloon Rich',
      debugShowCheckedModeBanner: false, // දකුණු පැත්තේ එන රතු පටිය අයින් කිරීම
      // --- THEME SETUP (සැලෝන් එකේ පෙනුම) ---
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700), // ප්‍රධාන වර්ණය (Gold)
        scaffoldBackgroundColor: const Color(
          0xFF121212,
        ), // පසුබිම් වර්ණය (Deep Black)
        // වර්ණ පද්ධතිය (Color Scheme)
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700), // Gold
          secondary: Color(0xFFD4AF37), // Darker Gold
          surface: Color(0xFF1E1E1E), // කාඩ්පත් වල පාට (Dark Grey)
        ),

        // අකුරු මෝස්තර (Fonts) - Montserrat
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: const Color(0xFFFFD700)),

        // Button Styles (බොත්තම් වල පෙනුම)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700), // බොත්තම Gold පාටයි
            foregroundColor: Colors.black, // අකුරු කළු පාටයි
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // Input Fields (ටයිප් කරන තැන් වල පෙනුම)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          prefixIconColor: const Color(0xFFFFD700),
          labelStyle: const TextStyle(color: Colors.white60),
        ),

        useMaterial3: true,
      ),

      // --- HOME SCREEN ---
      // ඇප් එක පටන් ගද්දිම Login Screen එකට යන්න
      home: const LoginScreen(),
    );
  }
}
