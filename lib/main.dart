import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/menu_home_page.dart';
import 'widgets/error_state_view.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
const kPrimary = Color(0xFFFF6D2E); // vibrant food-orange
const kPrimaryDark = Color(0xFFCC5520);
const kAccentGold = Color(0xFFFFB547); // star / badge gold
const kBg = Color(0xFF0D0C0B); // near-black warm
const kSurface = Color(0xFF1E1B19); // card / bottom-sheet surface
const kSurfaceHigh = Color(0xFF2A2522); // elevated surface
const kTextPrimary = Color(0xFFF5F0EB); // warm white
const kTextSecondary = Color(0xFF9A9186); // warm grey
const kDivider = Color(0xFF332E2A);
const kOutline = Color(0xFF4A4440);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MenuApp());
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: kPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF5A2200),
      onPrimaryContainer: Color(0xFFFFDBCC),
      secondary: kAccentGold,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF3D2B00),
      onSecondaryContainer: Color(0xFFFFE0A0),
      tertiary: Color(0xFF88CCA0),
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF00391B),
      onTertiaryContainer: Color(0xFFA4F2BB),
      error: Color(0xFFFF5252),
      onError: Colors.white,
      errorContainer: Color(0xFF7A1E1E),
      onErrorContainer: Color(0xFFFFBBBB),
      surface: kSurface,
      onSurface: kTextPrimary,
      onSurfaceVariant: kTextSecondary,
      outline: kOutline,
      outlineVariant: kDivider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: kTextPrimary,
      onInverseSurface: kBg,
      inversePrimary: kPrimaryDark,
      surfaceTint: kPrimary,
      surfaceContainerLowest: Color(0xFF0A0908),
      surfaceContainerLow: kBg,
      surfaceContainer: kSurface,
      surfaceContainerHigh: kSurfaceHigh,
      surfaceContainerHighest: Color(0xFF332E2A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu Ẩm Thực',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: kBg,
        // ── AppBar ─────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: kTextPrimary),
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        // ── Cards ──────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          color: kSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // ── Chips ──────────────────────────────────────────────────────────
        chipTheme: const ChipThemeData(
          backgroundColor: kSurface,
          selectedColor: kPrimary,
          disabledColor: kSurface,
          labelStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          secondaryLabelStyle: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: StadiumBorder(),
          side: BorderSide.none,
          showCheckmark: false,
        ),
        // ── Search bar ─────────────────────────────────────────────────────
        searchBarTheme: SearchBarThemeData(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: const WidgetStatePropertyAll(kSurface),
          hintStyle: const WidgetStatePropertyAll(
            TextStyle(color: kTextSecondary, fontSize: 15),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(color: kTextPrimary, fontSize: 15),
          ),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        // ── Bottom sheet ───────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        // ── Buttons ────────────────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        // ── Snackbar ───────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kSurfaceHigh,
          contentTextStyle: const TextStyle(color: kTextPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        // ── Divider ────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(color: kDivider, thickness: 1),
        // ── Typography ─────────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 40,
          ),
          displayMedium: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w900,
          ),
          displaySmall: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w800,
          ),
          headlineLarge: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
          headlineMedium: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
          headlineSmall: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
          titleLarge: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          titleMedium: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          titleSmall: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(color: kTextPrimary, fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(
            color: kTextSecondary,
            fontSize: 14,
            height: 1.5,
          ),
          bodySmall: TextStyle(color: kTextSecondary, fontSize: 12),
          labelLarge: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          labelMedium: TextStyle(
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          labelSmall: TextStyle(
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        // ── Icon ───────────────────────────────────────────────────────────
        iconTheme: const IconThemeData(color: kTextSecondary),
        // ── ListTile ───────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          iconColor: kTextSecondary,
          textColor: kTextPrimary,
        ),
      ),
      home: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _initialize();
  }

  Future<void> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: kBg,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      color: kPrimary,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Đang khởi tạo ứng dụng...',
                    style: TextStyle(color: kTextSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: kBg,
            body: ErrorStateView(
              message:
                  'Không thể kết nối dịch vụ. Vui lòng kiểm tra mạng và thử lại.',
              onRetry: () {
                setState(() {
                  _bootstrapFuture = _initialize();
                });
              },
            ),
          );
        }

        return const MenuHomePage();
      },
    );
  }
}
