import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts

// --- APP COLOR PALETTE ---
const Color kRichBlack = Color(0xFF1D1F24); // Dark black
const Color kBrown = Color(0xFF8B5E3C);     // Main "coffee" brown
const Color kLightBrown = Color(0xFFD2B48C);// Lighter tan/beige
const Color kOffWhite = Color(0xFFF8F4F0);  // Warm off-white

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();

  runApp(
    ChangeNotifierProvider.value(
      value: cartProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      debugShowCheckedModeBanner: false,

      // --- NEW THEME ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrown,
          brightness: Brightness.light,
          primary: kBrown,
          onPrimary: Colors.white,
          secondary: kLightBrown,
          background: kOffWhite,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kOffWhite,

        // Google Fonts applied globally
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),

        // Global button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Global text field style
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          labelStyle: TextStyle(color: kBrown.withOpacity(0.8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrown, width: 2.0),
          ),
        ),

        // Global card style (Material 3 compatible)
        cardTheme: const CardThemeData(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        // Global AppBar style
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kRichBlack,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const AuthWrapper(),
    );
  }
}
