import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api.dart';
import '../models/file_item.dart';
import '../theme.dart';
import '../widgets/file_thumb.dart';
import '../widgets/preview_sheet.dart';

String _fmtBytes(int b) {
  if (b >= 1e9) return '${(b / 1e9).toStringAsFixed(1)} GB';
  if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(1)} MB';
  if (b >= 1e3) return '${(b / 1e3).round()} KB';
  return '$b B';
}

class ArchivosScreen extends StatefulWidget {
  const ArchivosScreen({super.key});

  @override
  State<ArchivosScreen> createState() => _ArchivosScreenState();
}

class _ArchivosScreenState extends State<ArchivosScreen> {
  List<FileItem> _files = [];
  bool _isLoading = true;
  bool _gridView = false;
  String _search = '';
  String? _currentFolder;
  List<({String name, String? id})> _breadcrumbs = [const (name: 'Mi nube', id: null)];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(null);
  }

  Future<void> _load(String? parentUuid) async {
    setState(() => _isLoading = true);
    try {
      final params = parentUuid != null ? '?parent_uuid=$parentUuid' : '';
      final r = await dio.get('/api/files/$params');
      final files = (r.data['files'] as List)
          .map((j) => FileItem.fromJson(j as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _files = files; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFolder(FileItem f) {
    setState(() {
      _currentFolder = f.uuid;
      _breadcrumbs = [..._breadcrumbs, (name: f.name, id: f.uuid)];
    });
    _load(f.uuid);
  }

  void _goTo(int idx) {
    final crumb = _breadcrumbs[idx];
    setState(() {
      _breadcrumbs = _breadcrumbs.sublist(0, idx + 1);
      _currentFolder = crumb.id;
    });
    _load(crumb.id);
  }

  Future<void> _toggleStar(FileItem f) async {
    final newVal = !f.isStarred;
    setState(() => _files = _files.map((x) => x.uuid == f.uuid ? x.copyWith(isStarred: newVal) : x).toList());
    try {
      await dio.patch('/api/files/${f.uuid}', data: {'is_starred': newVal});
    } catch (_) {
      setState(() => _files = _files.map((x) => x.uuid == f.uuid ? x.copyWith(isStarred: !newVal) : x).toList());
    }
  }

  List<FileItem> get _filtered => _search.isEmpty
      ? _files
      : _files.where((f) => f.name.toLowerCase().contains(_search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Search
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, size: 16, color: context.inkFaint),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(fontSize: 13.5, color: context.ink),
                decoration: InputDecoration(
                  hintText: 'Buscar archivos…',
                  hintStyle: TextStyle(color: context.inkFaint, fontSize: 13.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          ]),
        ),
      ),

      // Breadcrumbs + view toggle
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _breadcrumbs.asMap().entries.map((e) {
                  final last = e.key == _breadcrumbs.length - 1;
                  return GestureDetector(
                    onTap: last ? null : () => _goTo(e.key),
                    child: Row(children: [
                      if (e.key > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.chevron_right_rounded, size: 14, color: context.inkFaint),
                        ),
                      Text(e.value.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: last ? context.ink : SrcColors.accent,
                            fontWeight: last ? FontWeight.w500 : FontWeight.w400,
                          )),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ViewToggle(gridView: _gridView, onToggle: (v) => setState(() => _gridView = v)),
        ]),
      ),

      // Content
      Expanded(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: SrcColors.accent))
            : _filtered.isEmpty
                ? _Empty(hasSearch: _search.isNotEmpty)
                : RefreshIndicator(
                    onRefresh: () => _load(_currentFolder),
                    color: SrcColors.accent,
                    child: _gridView ? _GridView(files: _filtered, onTap: _onTap, onStar: _toggleStar)
                        : _ListView(files: _filtered, onTap: _onTap, onStar: _toggleStar),
                  ),
      ),
    ]);
  }

  void _onTap(FileItem f) {
    if (f.isFolder) _openFolder(f);
    else showPreviewSheet(context, f);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
}

class _ViewToggle extends StatelessWidget {
  final bool gridView;
  final ValueChanged<bool> onToggle;
  const _ViewToggle({required this.gridView, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(children: [
        _Btn(icon: Icons.list_rounded, active: !gridView, onTap: () => onToggle(false)),
        _Btn(icon: Icons.grid_view_rounded, active: gridView, onTap: () => onToggle(true)),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 24,
        decoration: BoxDecoration(
          color: active ? context.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: active ? context.ink : context.inkSoft),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool hasSearch;
  const _Empty({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: context.surface2, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.folder_open_rounded, size: 26, color: context.inkFaint),
        ),
        const SizedBox(height: 14),
        Text(hasSearch ? 'Sin resultados' : 'Carpeta vacía',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.ink)),
        const SizedBox(height: 4),
        Text(hasSearch ? 'Intenta con otra búsqueda' : 'Sube archivos para empezar',
            style: TextStyle(fontSize: 12.5, color: context.inkSoft)),
      ]),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<FileItem> files;
  final ValueChanged<FileItem> onTap;
  final ValueChanged<FileItem> onStar;
  const _ListView({required this.files, required this.onTap, required this.onStar});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
      children: [
        Container(
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
                onTap: () => onTap(f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    border: last ? null : Border(bottom: BorderSide(color: context.borderColor)),
                  ),
                  child: Row(children: [
                    FileThumb(file: f, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(f.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: context.ink)),
                          ),
                          if (f.isStarred)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.star_rounded, size: 12, color: SrcColors.accent),
                            ),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          f.isFolder ? '–' : '${f.ext} · ${_fmtBytes(f.size)}',
                          style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkFaint),
                        ),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => onStar(f),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          f.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 18,
                          color: f.isStarred ? SrcColors.accent : context.inkFaint,
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _GridView extends StatelessWidget {
  final List<FileItem> files;
  final ValueChanged<FileItem> onTap;
  final ValueChanged<FileItem> onStar;
  const _GridView({required this.files, required this.onTap, required this.onStar});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
      itemCount: files.length,
      itemBuilder: (_, i) {
        final f = files[i];
        return GestureDetector(
          onTap: () => onTap(f),
          child: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surface2,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Stack(alignment: Alignment.topRight, children: [
                    Center(child: FileThumb(file: f, size: 56)),
                    if (f.isStarred)
                      Container(
                        margin: const EdgeInsets.all(6),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.star_rounded, size: 13, color: SrcColors.accent),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Text(f.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.ink)),
              const SizedBox(height: 2),
              Text(f.isFolder ? '–' : _fmtBytes(f.size),
                  style: GoogleFonts.nunitoSans(fontSize: 10.5, color: context.inkSoft)),
            ]),
          ),
        );
      },
    );
  }
}
