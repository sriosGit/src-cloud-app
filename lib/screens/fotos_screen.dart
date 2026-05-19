import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api.dart';
import '../models/file_item.dart';
import '../theme.dart';
import '../widgets/preview_sheet.dart';

class FotosScreen extends StatefulWidget {
  const FotosScreen({super.key});

  @override
  State<FotosScreen> createState() => _FotosScreenState();
}

class _FotosScreenState extends State<FotosScreen> {
  List<FileItem> _photos = [];
  bool _isLoading = true;
  String _filter = 'todas';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await dio.get('/api/files/');
      final all = (r.data['files'] as List).map((j) => FileItem.fromJson(j as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _photos = all.where((f) => f.kind == FileKind.img).toList(); _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FileItem> get _filtered {
    if (_filter == 'favoritas') return _photos.where((f) => f.isStarred).toList();
    return _photos;
  }

  Map<String, List<FileItem>> get _grouped {
    final m = <String, List<FileItem>>{};
    for (final f in _filtered) {
      final d = f.modifiedAt;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      (m[key] ??= []).add(f);
    }
    return Map.fromEntries(m.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _monthLabel(String key) {
    final parts = key.split('-');
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return '${months[d.month]} · ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Filter chips
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          children: [
            _Chip(label: 'Todas', active: _filter == 'todas', onTap: () => setState(() => _filter = 'todas')),
            const SizedBox(width: 6),
            _Chip(label: 'Recientes', active: _filter == 'recientes', onTap: () => setState(() => _filter = 'recientes')),
            const SizedBox(width: 6),
            _Chip(label: 'Favoritas', active: _filter == 'favoritas', onTap: () => setState(() => _filter = 'favoritas')),
          ],
        ),
      ),

      Expanded(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: SrcColors.accent))
            : _filtered.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: context.surface2, borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.photo_library_outlined, size: 26, color: context.inkFaint),
                      ),
                      const SizedBox(height: 14),
                      Text('Sin fotos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink)),
                      const SizedBox(height: 4),
                      Text('Sube imágenes para verlas aquí',
                          style: TextStyle(fontSize: 12.5, color: context.inkSoft)),
                    ]),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: SrcColors.accent,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                      children: _grouped.entries.map((e) {
                        final items = e.value;
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_monthLabel(e.key),
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600, color: context.ink, letterSpacing: -0.3)),
                            Text('${items.length} fotos',
                                style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkSoft)),
                          ]),
                          const SizedBox(height: 10),
                          _PhotoGrid(photos: items),
                          const SizedBox(height: 22),
                        ]);
                      }).toList(),
                    ),
                  ),
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? context.accentSoft : context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? Colors.transparent : context.borderColor),
        ),
        child: Row(children: [
          if (active) ...[
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(color: SrcColors.accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: active ? SrcColors.accent : context.ink2, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<FileItem> photos;
  const _PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
      itemCount: photos.length,
      itemBuilder: (_, i) {
        final f = photos[i];
        final hue = f.uuid.codeUnitAt(0) * 37 % 360;
        return GestureDetector(
          onTap: () => showPreviewSheet(context, f),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              color: HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.55).toColor(),
              child: f.hasThumbnail
                  ? Image.network(
                      '${dio.options.baseUrl}/api/files/${f.uuid}/thumbnail',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
