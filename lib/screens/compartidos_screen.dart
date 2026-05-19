import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api.dart';
import '../models/share.dart';
import '../theme.dart';

class CompartidosScreen extends StatefulWidget {
  const CompartidosScreen({super.key});

  @override
  State<CompartidosScreen> createState() => _CompartidosScreenState();
}

class _CompartidosScreenState extends State<CompartidosScreen> {
  List<Share> _shares = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await dio.get('/api/shares/');
      if (mounted) {
        setState(() {
          _shares = (r.data as List).map((j) => Share.fromJson(j as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _copy(Share s) async {
    final url = '${Uri.base.origin}/s/${s.publicLink}';
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado')));
  }

  Future<void> _delete(Share s) async {
    try {
      await dio.delete('/api/shares/${s.uuid}');
      setState(() => _shares = _shares.where((x) => x.uuid != s.uuid).toList());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace eliminado')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDownloads = _shares.fold(0, (acc, s) => acc + s.downloadCount);

    if (_isLoading) return Center(child: CircularProgressIndicator(color: SrcColors.accent));
    if (_shares.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: context.surface2, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.share_rounded, size: 26, color: context.inkFaint),
          ),
          const SizedBox(height: 14),
          Text('Sin enlaces', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink)),
          const SizedBox(height: 4),
          Text('Comparte archivos para verlos aquí',
              style: TextStyle(fontSize: 12.5, color: context.inkSoft)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: SrcColors.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('${_shares.length} enlaces · $totalDownloads descargas',
                style: GoogleFonts.nunitoSans(fontSize: 12, color: context.inkSoft)),
          ),
          ..._shares.map((s) => _ShareCard(share: s, onCopy: () => _copy(s), onDelete: () => _delete(s))),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final Share share;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _ShareCard({required this.share, required this.onCopy, required this.onDelete});

  static Color _expColor(String cls) {
    if (cls == 'err') return SrcColors.err;
    if (cls == 'ok') return SrcColors.ok;
    return SrcColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final exp = share.expiryInfo;
    final ext = share.fileName.contains('.') ? share.fileName.split('.').last.toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // File icon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(ext.length > 3 ? ext.substring(0, 3) : ext,
                style: GoogleFonts.nunitoSans(fontSize: 10, fontWeight: FontWeight.w700, color: context.inkSoft)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(share.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: context.ink)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, children: [
                if (share.hasPassword) _tag(context, Icons.lock_rounded, 'protegido', context.inkSoft),
                _tag(context, Icons.circle, exp.text, _expColor(exp.cls), dot: true),
              ]),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${Uri.base.host}/s/${share.publicLink}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(fontSize: 11, color: context.inkSoft),
                ),
              ),
            ]),
          ),
        ]),
        Divider(color: context.borderColor, height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            _Stat(value: '${share.downloadCount}', label: 'descargas'),
          ]),
          Row(children: [
            _IconBtn(icon: Icons.copy_rounded, onTap: onCopy),
            const SizedBox(width: 4),
            _IconBtn(icon: Icons.delete_outline_rounded, onTap: onDelete),
          ]),
        ]),
      ]),
    );
  }

  Widget _tag(BuildContext ctx, IconData icon, String text, Color color, {bool dot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot)
          Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
        else
          Icon(icon, size: 9, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.nunitoSans(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w700, color: context.ink)),
      Text(label.toUpperCase(),
          style: GoogleFonts.nunitoSans(fontSize: 9.5, color: context.inkFaint, letterSpacing: 0.6)),
    ]);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: context.inkSoft),
      ),
    );
  }
}
