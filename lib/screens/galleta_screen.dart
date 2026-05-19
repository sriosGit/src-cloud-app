import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api.dart';
import '../theme.dart';
import '../widgets/galleta_mark.dart';

class GalletaScreen extends StatefulWidget {
  final VoidCallback onBack;
  const GalletaScreen({super.key, required this.onBack});

  @override
  State<GalletaScreen> createState() => _GalletaScreenState();
}

class _GalletaScreenState extends State<GalletaScreen> {
  final _msgs = <_Msg>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;
  String? _modelName;

  static const _suggestions = ['/reporte-finanzas', '/album oaxaca', '/backup-now', '/resumen-semana'];

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(from: 'bot', text: '¡Hola! 🐾 Soy Galleta. ¿En qué te ayudo hoy?', t: _now()));
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final r = await dio.get('/api/galleta/status');
      if (mounted) setState(() => _modelName = r.data['model'] as String?);
    } catch (_) {
      if (mounted) setState(() => _modelName = 'qwen2.5:14b');
    }
  }

  String _now() {
    final d = DateTime.now();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _send([String? text]) async {
    final v = (text ?? _inputCtrl.text).trim();
    if (v.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(from: 'user', text: v, t: _now()));
      _inputCtrl.clear();
      _typing = true;
    });
    _scrollToBottom();

    try {
      final r = await dio.post('/api/galleta/chat', data: {'message': v});
      final reply = (r.data['response'] ?? r.data['message'] ?? '…') as String;
      if (mounted) setState(() { _msgs.add(_Msg(from: 'bot', text: reply, t: _now())); _typing = false; });
    } catch (_) {
      if (mounted) setState(() {
        _msgs.add(_Msg(from: 'bot', text: 'Error al conectar con Galleta. ¿Ollama está corriendo?', t: _now()));
        _typing = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(bottom: BorderSide(color: context.borderColor)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.chevron_left_rounded, size: 22, color: context.inkSoft),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: SrcColors.accent, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: GalletaMark(size: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Galleta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink, letterSpacing: -0.2)),
              Text(_modelName ?? 'conectando…',
                  style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkSoft)),
            ]),
          ),
          GestureDetector(
            onTap: () => setState(() { _msgs.clear(); _msgs.add(_Msg(from: 'bot', text: '¡Hola de nuevo!  🐾', t: _now())); }),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.refresh_rounded, size: 17, color: context.inkSoft),
            ),
          ),
        ]),
      ),

      // Messages
      Expanded(
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          children: [
            ..._msgs.map((m) => _Bubble(msg: m)),
            if (_typing) _TypingBubble(),
          ],
        ),
      ),

      // Suggestions
      SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _send(_suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.borderColor),
              ),
              alignment: Alignment.center,
              child: Text(_suggestions[i],
                  style: GoogleFonts.nunitoSans(fontSize: 11, color: context.ink2)),
            ),
          ),
        ),
      ),

      // Input
      Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(top: BorderSide(color: context.borderColor)),
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: context.borderColor),
              ),
              child: TextField(
                controller: _inputCtrl,
                style: TextStyle(fontSize: 13.5, color: context.ink),
                decoration: InputDecoration(
                  hintText: 'Pregúntale a Galleta…',
                  hintStyle: TextStyle(color: context.inkFaint, fontSize: 13.5),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: SrcColors.accent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    ]);
  }

  @override
  void dispose() { _inputCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }
}

class _Msg {
  final String from;
  final String text;
  final String t;
  _Msg({required this.from, required this.text, required this.t});
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isBot = msg.from == 'bot';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isBot ? [_avatar(isBot), const SizedBox(width: 8), _body(context, isBot)]
            : [_body(context, isBot), const SizedBox(width: 8), _avatar(isBot)],
      ),
    );
  }

  Widget _avatar(bool isBot) => Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isBot ? SrcColors.accent : const Color(0xFF38342D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isBot
            ? const Center(child: GalletaMark(size: 18))
            : Center(
                child: Text('SR',
                    style: GoogleFonts.nunitoSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
      );

  Widget _body(BuildContext context, bool isBot) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? context.surface : SrcColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isBot ? 4 : 14),
                  bottomRight: Radius.circular(isBot ? 14 : 4),
                ),
                border: isBot ? Border.all(color: context.borderColor) : null,
              ),
              child: Text(msg.text,
                  style: TextStyle(fontSize: 13.5, color: isBot ? context.ink : Colors.white, height: 1.5)),
            ),
            const SizedBox(height: 3),
            Text(msg.t,
                style: GoogleFonts.nunitoSans(fontSize: 9.5, color: context.inkFaint)),
          ],
        ),
      );
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: SrcColors.accent, borderRadius: BorderRadius.circular(8)),
        child: const Center(child: GalletaMark(size: 18)),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14), topRight: Radius.circular(14),
            bottomLeft: Radius.circular(4), bottomRight: Radius.circular(14),
          ),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0),
          const SizedBox(width: 4),
          _Dot(delay: 200),
          const SizedBox(width: 4),
          _Dot(delay: 400),
        ]),
      ),
    ]);
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _a = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _c,
        curve: Interval(widget.delay / 1200, (widget.delay + 600) / 1200, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: context.inkFaint, shape: BoxShape.circle),
        ),
      );

  @override
  void dispose() { _c.dispose(); super.dispose(); }
}
