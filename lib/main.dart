import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SrcCloudApp());
}

class SrcCloudApp extends StatelessWidget {
  const SrcCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => MaterialApp(
          title: 'SRC Cloud',
          debugShowCheckedModeBanner: false,
          themeMode: theme.mode,
          theme: buildTheme(false),
          darkTheme: buildTheme(true),
          home: Consumer<AuthProvider>(
            builder: (_, auth, __) {
              if (auth.status == AuthStatus.loading) return const _Splash();
              return auth.status == AuthStatus.authenticated
                  ? const ShellScreen()
                  : const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrcColors.bg,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SrcColors.ink,
              borderRadius: BorderRadius.circular(16),
              gradient: const RadialGradient(
                center: Alignment(-0.4, -0.6),
                radius: 1.2,
                colors: [SrcColors.accent, Colors.transparent],
              ),
            ),
            alignment: Alignment.center,
            child: const Text('S',
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: SrcColors.accent),
          ),
        ]),
      ),
    );
  }
}
