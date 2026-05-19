import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api.dart';
import '../models/file_item.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/file_thumb.dart';
import '../widgets/galleta_mark.dart';
import '../widgets/preview_sheet.dart';

String _fmtBytes(int b) {
  if (b >= 1e12) return '${(b / 1e12).toStringAsFixed(2)} TB';
  if (b >= 1e9) return '${(b / 1e9).toStringAsFixed(1)} GB';
  if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(0)} MB';
  return '${(b / 1e3).round()} KB';
}

String _relTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'hace momentos';
  if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'hace ${diff.inHours} h';
  return 'hace ${diff.inDays} días';
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback onAskGalleta;
  const DashboardScreen({super.key, required this.onAskGalleta});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _storageOpen = false;
  List<FileItem> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final r = await dio.get('/api/files/');
      final files = (r.data['files'] as List).map((j) => FileItem.fromJson(j as Map<String, dynamic>)).toList();
      files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      if (mounted) setState(() => _recent = files.take(4).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : hour < 18 ? 'Buenas tardes' : 'Buenas noches';
    final name = user?.displayName ?? 'Sebas';

    return RefreshIndicator(
      onRefresh: _loadRecent,
      color: SrcColors.accent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting, $name',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700, color: context.ink, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(
                    user != null
                        ? '${_fmtBytes(user.storageUsed)} usados · 8 servicios activos'
                        : 'Cargando…',
                    style: GoogleFonts.nunitoSans(fontSize: 12.5, color: context.inkSoft),
                  ),
                  const SizedBox(height: 16),

                  // Storage card
                  if (user != null) _StorageCard(user: user, open: _storageOpen, onToggle: () => setState(() => _storageOpen = !_storageOpen)),
                  const SizedBox(height: 12),

                  // Galleta card
                  _GalletaCard(onTap: widget.onAskGalleta),
                  const SizedBox(height: 16),

                  // Recent files
                  if (_recent.isNotEmpty) ...[
                    Text('RECIENTE',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 10, letterSpacing: 1.5, color: context.inkFaint, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _RecentList(files: _recent),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Storage Card ─────────────────────────────────────────────────────────────

class _StorageCard extends StatelessWidget {
  final User user;
  final bool open;
  final VoidCallback onToggle;

  const _StorageCard({required this.user, required this.open, required this.onToggle});

  static const _labels = ['Fotos', 'Vídeos', 'Documentos', 'Backups', 'Otros'];
  static const _colors = [SrcColors.ok, Color(0xFF8E4D7A), SrcColors.info, SrcColors.warn, Color(0xFF5B544A)];
  static const _pcts = [30, 16, 9, 5, 2];

  @override
  Widget build(BuildContext context) {
    final pct = user.storageQuota > 0
        ? (user.storageUsed / user.storageQuota).clamp(0.0, 1.0)
        : 0.0;
    final free = user.storageQuota - user.storageUsed;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ALMACENAMIENTO',
                      style: GoogleFonts.nunitoSans(fontSize: 10, letterSpacing: 1.2, color: context.inkFaint)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: _fmtBytes(user.storageUsed),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700, color: context.ink, letterSpacing: -0.5)),
                      TextSpan(
                          text: ' / ${_fmtBytes(user.storageQuota)}',
                          style: GoogleFonts.nunitoSans(fontSize: 13, color: context.inkSoft)),
                    ]),
                  ),
                ]),
              ),
              Row(children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '${(pct * 100).round()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: SrcColors.accent, fontSize: 12)),
                    TextSpan(
                        text: ' usado',
                        style: GoogleFonts.nunitoSans(fontSize: 11, color: context.inkSoft)),
                  ]),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: open ? -0.25 : 0.25,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: context.inkSoft),
                ),
              ]),
            ]),
            const SizedBox(height: 14),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: context.surface2,
                valueColor: const AlwaysStoppedAnimation(SrcColors.accent),
              ),
            ),
          ]),
        ),

        // Expandable breakdown
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 14),
              ..._labels.asMap().entries.map((e) {
                final bytes = (user.storageUsed * _pcts[e.key] / 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    Container(
                      width: 9, height: 9,
                      decoration: BoxDecoration(color: _colors[e.key], borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value, style: TextStyle(fontSize: 13, color: context.ink2))),
                    Text(_fmtBytes(bytes),
                        style: GoogleFonts.nunitoSans(fontSize: 11.5, fontWeight: FontWeight.w500, color: context.ink)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 32,
                      child: Text('${_pcts[e.key]}%',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkFaint)),
                    ),
                  ]),
                );
              }),
              Divider(color: context.borderColor, height: 1),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Disponible', style: TextStyle(fontSize: 13, color: context.ink2)),
                Text(_fmtBytes(free),
                    style: GoogleFonts.nunitoSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: context.ink)),
              ]),
            ],
          ),
          crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 240),
        ),
      ]),
    );
  }
}

// ── Galleta Card ─────────────────────────────────────────────────────────────

class _GalletaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GalletaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.6, -0.8),
            end: Alignment.bottomRight,
            colors: [context.surface, context.accentSoft],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: SrcColors.accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: SrcColors.accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: const Center(child: GalletaMark(size: 26)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Galleta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink, letterSpacing: -0.2)),
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: SrcColors.ok, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text('qwen2.5:14b · local',
                    style: GoogleFonts.nunitoSans(
                        fontSize: 10, color: SrcColors.ok, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ]),
            ]),
          ]),
          const SizedBox(height: 12),
          Text('¡Hola! ¿En qué te ayudo hoy? Puedo analizar archivos, hacer backups o darte un reporte.',
              style: TextStyle(fontSize: 13.5, color: context.ink2, height: 1.5)),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Chip(label: 'Hacer álbum', onTap: onTap),
            _Chip(label: '/reporte-finanzas', onTap: onTap),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(children: [
              const SizedBox(width: 12),
              Icon(Icons.bolt_rounded, size: 14, color: context.inkSoft),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Pregúntale a Galleta…',
                    style: TextStyle(fontSize: 13, color: context.inkFaint)),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                width: 32, height: 32,
                decoration: BoxDecoration(color: SrcColors.accent, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(label,
            style: GoogleFonts.nunitoSans(fontSize: 11, color: context.ink2, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── Recent List ───────────────────────────────────────────────────────────────

class _RecentList extends StatelessWidget {
  final List<FileItem> files;
  const _RecentList({required this.files});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: files.asMap().entries.map((e) {
          final f = e.value;
          final last = e.key == files.length - 1;
          return GestureDetector(
            onTap: () => f.isFolder ? null : showPreviewSheet(context, f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: last ? null : Border(bottom: BorderSide(color: context.borderColor)),
              ),
              child: Row(children: [
                FileThumb(file: f, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: context.ink)),
                    const SizedBox(height: 2),
                    Text('${f.ext} · ${_fmtBytes(f.size)}',
                        style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkFaint)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(_relTime(f.modifiedAt),
                    style: GoogleFonts.nunitoSans(fontSize: 11, color: context.inkSoft)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
