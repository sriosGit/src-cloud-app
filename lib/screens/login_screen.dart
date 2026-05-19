import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().login(_emailCtrl.text.trim(), _passCtrl.text);
    } catch (_) {
      setState(() => _error = 'Email o contraseña incorrectos');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.bg;
    final surface = context.surface;
    final ink = context.ink;
    final inkSoft = context.inkSoft;
    final border = context.borderColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Brand mark
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: ink,
                  borderRadius: BorderRadius.circular(16),
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.6),
                    radius: 1.2,
                    colors: [SrcColors.accent, Colors.transparent],
                  ),
                ),
                alignment: Alignment.center,
                child: Text('S',
                    style: TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              ),
              const SizedBox(height: 12),
              Text('SRC Cloud',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text('personal cloud',
                  style: GoogleFonts.nunitoSans(fontSize: 11, color: inkSoft, letterSpacing: 1.5)),
              const SizedBox(height: 40),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bienvenido',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ink)),
                    const SizedBox(height: 4),
                    Text('Ingresa a tu nube personal',
                        style: TextStyle(fontSize: 12.5, color: inkSoft)),
                    const SizedBox(height: 22),

                    _label('Email'),
                    const SizedBox(height: 6),
                    _input(
                      controller: _emailCtrl,
                      hint: 'sebas@src-cloud.online',
                      type: TextInputType.emailAddress,
                      context: context,
                    ),
                    const SizedBox(height: 14),

                    _label('Contraseña'),
                    const SizedBox(height: 6),
                    _input(
                      controller: _passCtrl,
                      hint: '••••••••',
                      obscure: true,
                      context: context,
                      onSubmit: _submit,
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: SrcColors.err, fontSize: 12.5)),
                    ],

                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SrcColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Entrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.nunitoSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: context.ink2, letterSpacing: 0.8),
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required BuildContext context,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    VoidCallback? onSubmit,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        style: TextStyle(fontSize: 14, color: context.ink),
        onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.inkFaint, fontSize: 14),
          filled: true,
          fillColor: context.bgGrain,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.borderStrong),
          ),
          constraints: const BoxConstraints(minHeight: 42, maxHeight: 42),
        ),
      );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
