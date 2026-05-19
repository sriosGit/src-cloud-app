import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import '../core/api.dart';
import '../theme.dart';
import 'file_thumb.dart';

String _fmtBytes(int b) {
  if (b >= 1e9) return '${(b / 1e9).toStringAsFixed(1)} GB';
  if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(1)} MB';
  if (b >= 1e3) return '${(b / 1e3).round()} KB';
  return '$b B';
}

Future<void> showPreviewSheet(BuildContext context, FileItem file) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PreviewSheet(file: file),
  );
}

class _PreviewSheet extends StatelessWidget {
  final FileItem file;
  const _PreviewSheet({required this.file});

  @override
  Widget build(BuildContext context) {
    final surface = context.surface;
    final ink = context.ink;
    final inkSoft = context.inkSoft;
    final inkFaint = context.inkFaint;
    final border = context.borderColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // Grab bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumb
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: context.surface2,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: FileThumb(file: file, size: 72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(file.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(
                      '${file.ext} · ${_fmtBytes(file.size)} · ${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}',
                      style: GoogleFonts.nunitoSans(fontSize: 12, color: inkSoft),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel(context, 'Detalles'),
                    _kvRow(context, 'Tipo', file.mimeType ?? file.ext, border, ink, inkSoft, inkFaint),
                    _kvRow(context, 'Tamaño', _fmtBytes(file.size), border, ink, inkSoft, inkFaint),
                    _kvRow(context, 'Modificado',
                        '${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}',
                        border, ink, inkSoft, inkFaint),
                    _kvRow(context, 'UUID', '${file.uuid.substring(0, 8)}…', border, ink, inkSoft, inkFaint,
                        last: true),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border)),
                color: surface,
              ),
              child: Row(children: [
                Expanded(
                  child: _SheetBtn(
                    label: 'Descargar',
                    icon: Icons.download_rounded,
                    onTap: () => _download(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SheetBtn(
                    label: 'Compartir',
                    icon: Icons.share_rounded,
                    primary: true,
                    onTap: () => _share(context),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.nunitoSans(
                fontSize: 10, letterSpacing: 1.2, color: context.inkFaint, fontWeight: FontWeight.w600)),
      );

  Widget _kvRow(BuildContext ctx, String k, String v, Color border, Color ink, Color inkSoft, Color inkFaint,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: border)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: TextStyle(fontSize: 13, color: inkSoft)),
        Text(v,
            style: GoogleFonts.nunitoSans(fontSize: 12, color: ink, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  void _download(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Descargando…'), duration: Duration(seconds: 2)));
    Navigator.pop(context);
  }

  Future<void> _share(BuildContext context) async {
    try {
      final resp = await dio.post('/api/shares/', data: {'file_uuid': file.uuid});
      final link = resp.data['public_link'] as String;
      await Clipboard.setData(ClipboardData(text: link));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Enlace copiado al portapapeles')));
        Navigator.pop(context);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error al crear enlace')));
      }
    }
  }
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _SheetBtn({required this.label, required this.icon, this.primary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: primary ? SrcColors.accent : context.surface2,
          borderRadius: BorderRadius.circular(11),
          border: primary ? null : Border.all(color: context.borderColor),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: primary ? Colors.white : context.ink),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: primary ? Colors.white : context.ink)),
        ]),
      ),
    );
  }
}
