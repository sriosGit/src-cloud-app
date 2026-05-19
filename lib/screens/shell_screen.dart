import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/galleta_mark.dart';
import 'dashboard_screen.dart';
import 'archivos_screen.dart';
import 'fotos_screen.dart';
import 'compartidos_screen.dart';
import 'galleta_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;
  bool _galletaOpen = false;
  bool _peekVisible = true;
  int _peekIdx = 0;

  static const _peekLines = [
    '🐾 ¿Te hago un álbum con las fotos nuevas?',
    '🐶 Backup próximo en 4 h. ¿Lo adelanto?',
    '🐾 Tu portafolio cripto subió 1.4% hoy.',
    '🐶 Tienes 3 enlaces compartidos activos.',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = context.watch<ThemeProvider>();

    if (_galletaOpen) {
      return Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: GalletaScreen(onBack: () => setState(() => _galletaOpen = false)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(children: [
          // Topbar
          _Topbar(
            username: user?.displayName ?? 'Sebas',
            isDark: theme.isDark,
            onGalleta: () => setState(() { _galletaOpen = true; _peekVisible = false; }),
            onToggleTheme: theme.toggle,
          ),

          // Page title
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: Row(children: [
              Text(_titles[_tab],
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700, color: context.ink, letterSpacing: -0.5)),
            ]),
          ),

          // Content
          Expanded(
            child: Stack(children: [
              IndexedStack(
                index: _tab,
                children: [
                  DashboardScreen(onAskGalleta: () => setState(() { _galletaOpen = true; _peekVisible = false; })),
                  const ArchivosScreen(),
                  const FotosScreen(),
                  const CompartidosScreen(),
                ],
              ),

              // Galleta peek bubble (dashboard only)
              if (_tab == 0 && _peekVisible)
                Positioned(
                  right: 14, bottom: 78,
                  child: _GalletaPeek(
                    text: _peekLines[_peekIdx],
                    onTap: () => setState(() { _galletaOpen = true; _peekVisible = false; }),
                    onDismiss: () => setState(() {
                      _peekVisible = false;
                      _peekIdx = (_peekIdx + 1) % _peekLines.length;
                    }),
                  ),
                ),

              // FAB (archivos tab)
              if (_tab == 1)
                Positioned(
                  right: 18, bottom: 18,
                  child: _Fab(onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selector de archivos…')))),
                ),
            ]),
          ),

          // Bottom nav
          _BottomNav(current: _tab, onTap: (i) => setState(() => _tab = i)),
        ]),
      ),
    );
  }

  static const _titles = ['Panel', 'Archivos', 'Fotos', 'Compartidos'];
}

// ── Topbar ────────────────────────────────────────────────────────────────────

class _Topbar extends StatelessWidget {
  final String username;
  final bool isDark;
  final VoidCallback onGalleta;
  final VoidCallback onToggleTheme;

  const _Topbar({required this.username, required this.isDark, required this.onGalleta, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 14, 4),
      child: Row(children: [
        // Brand
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: context.ink,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Stack(children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const RadialGradient(
                    center: Alignment(-0.4, -0.6),
                    radius: 1.0,
                    colors: [SrcColors.accent, Colors.transparent],
                  ),
                ),
              ),
            ),
            Center(child: Text('S',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SRC Cloud',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink, letterSpacing: -0.2)),
            Text('cloud · $username',
                style: GoogleFonts.nunitoSans(
                    fontSize: 9.5, color: context.inkSoft, letterSpacing: 0.8, fontWeight: FontWeight.w500)),
          ]),
        ),
        _TopBtn(onTap: onGalleta, child: const GalletaMark(size: 18)),
        _TopBtn(
          onTap: onToggleTheme,
          child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 16, color: context.inkSoft),
        ),
      ]),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TopBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Center(child: child),
        ),
      );
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  static const _items = [
    (icon: Icons.speed_rounded, label: 'Panel'),
    (icon: Icons.folder_rounded, label: 'Archivos'),
    (icon: Icons.photo_library_rounded, label: 'Fotos'),
    (icon: Icons.share_rounded, label: 'Shared'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgGrain,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Row(
        children: _items.asMap().entries.map((e) {
          final active = e.key == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  AnimatedSlide(
                    offset: active ? const Offset(0, -0.08) : Offset.zero,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(e.value.icon, size: 22,
                        color: active ? SrcColors.accent : context.inkSoft),
                  ),
                  const SizedBox(height: 3),
                  Text(e.value.label,
                      style: GoogleFonts.nunitoSans(
                          fontSize: 10, color: active ? SrcColors.accent : context.inkSoft,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          letterSpacing: 0.4)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Galleta Peek Bubble ───────────────────────────────────────────────────────

class _GalletaPeek extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _GalletaPeek({required this.text, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: SrcColors.accent, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: GalletaMark(size: 22)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text,
                  style: TextStyle(fontSize: 12.5, color: context.ink2, height: 1.35)),
              Text('galleta · qwen2.5:14b',
                  style: GoogleFonts.nunitoSans(fontSize: 9.5, color: context.inkFaint)),
            ]),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 14, color: context.inkFaint),
          ),
        ]),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: SrcColors.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: SrcColors.accent.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.upload_rounded, size: 22, color: Colors.white),
        ),
      );
}
