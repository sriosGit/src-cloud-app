import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import '../theme.dart';

List<Color> _kindGradient(FileKind kind) {
  switch (kind) {
    case FileKind.img:    return SrcColors.thumbImg;
    case FileKind.vid:    return SrcColors.thumbVid;
    case FileKind.aud:    return SrcColors.thumbAud;
    case FileKind.pdf:    return SrcColors.thumbPdf;
    case FileKind.zip:    return SrcColors.thumbZip;
    case FileKind.code:   return SrcColors.thumbCode;
    case FileKind.folder: return [SrcColors.accent, const Color(0xFF8A3A26)];
    default:              return SrcColors.thumbDoc;
  }
}

IconData _kindIcon(FileKind kind) {
  switch (kind) {
    case FileKind.folder: return Icons.folder_rounded;
    case FileKind.img:    return Icons.image_rounded;
    case FileKind.vid:    return Icons.movie_rounded;
    case FileKind.aud:    return Icons.music_note_rounded;
    default:              return Icons.insert_drive_file_rounded;
  }
}

class FileThumb extends StatelessWidget {
  final FileItem file;
  final double size;

  const FileThumb({super.key, required this.file, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final kind = file.kind;
    final gradient = _kindGradient(kind);
    final radius = BorderRadius.circular(size * 0.22);
    final iconSize = size * 0.42;

    if (kind == FileKind.folder || kind == FileKind.img || kind == FileKind.vid || kind == FileKind.aud) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Icon(_kindIcon(kind), size: iconSize, color: Colors.white.withOpacity(0.9)),
      );
    }

    // Show ext label for doc/pdf/zip/code
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        file.ext.length > 4 ? file.ext.substring(0, 4) : file.ext,
        style: GoogleFonts.nunitoSans(
          fontSize: size * 0.22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
