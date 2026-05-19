import 'package:flutter/material.dart';

class GalletaMark extends StatelessWidget {
  final double size;
  const GalletaMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GalletaPainter()),
    );
  }
}

class _GalletaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    final bodyPaint = Paint()..color = Colors.white;
    final darkPaint = Paint()..color = const Color(0xA6000000);
    final darkPaint2 = Paint()..color = const Color(0x80000000);
    final shinePaint = Paint()..color = const Color(0xE6FFFFFF);

    // Body
    final bodyPath = Path()
      ..moveTo(8 * s, 18 * s)
      ..cubicTo(8 * s, 14 * s, 10.5 * s, 11 * s, 13 * s, 11 * s)
      ..cubicTo(14.2 * s, 11 * s, 15 * s, 11.4 * s, 16 * s, 12 * s)
      ..lineTo(18 * s, 12.6 * s)
      ..lineTo(20 * s, 12 * s)
      ..cubicTo(21 * s, 11.4 * s, 21.8 * s, 11 * s, 23 * s, 11 * s)
      ..cubicTo(25.5 * s, 11 * s, 28 * s, 14 * s, 28 * s, 18 * s)
      ..lineTo(28 * s, 24 * s)
      ..cubicTo(28 * s, 27.3 * s, 25.3 * s, 30 * s, 22 * s, 30 * s)
      ..lineTo(14 * s, 30 * s)
      ..cubicTo(10.7 * s, 30 * s, 8 * s, 27.3 * s, 8 * s, 24 * s)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Left ear
    final leftEar = Path()
      ..moveTo(8 * s, 11 * s)
      ..cubicTo(6.5 * s, 12 * s, 5 * s, 14 * s, 5 * s, 16 * s)
      ..cubicTo(5 * s, 17.5 * s, 5.8 * s, 18.5 * s, 6.6 * s, 19 * s)
      ..cubicTo(7.4 * s, 19.5 * s, 8.6 * s, 19.5 * s, 9 * s, 18.5 * s)
      ..lineTo(10.5 * s, 15 * s)
      ..cubicTo(11 * s, 13.8 * s, 9.9 * s, 10.7 * s, 8 * s, 11 * s)
      ..close();
    canvas.drawPath(leftEar, bodyPaint);

    // Right ear
    final rightEar = Path()
      ..moveTo(32 * s, 11 * s)
      ..cubicTo(33.5 * s, 12 * s, 35 * s, 14 * s, 35 * s, 16 * s)
      ..cubicTo(35 * s, 17.5 * s, 34.2 * s, 18.5 * s, 33.4 * s, 19 * s)
      ..cubicTo(32.6 * s, 19.5 * s, 31.4 * s, 19.5 * s, 31 * s, 18.5 * s)
      ..lineTo(29.5 * s, 15 * s)
      ..cubicTo(29 * s, 13.8 * s, 30.1 * s, 10.7 * s, 32 * s, 11 * s)
      ..close();
    canvas.drawPath(rightEar, bodyPaint);

    // Eyes
    canvas.drawCircle(Offset(15.5 * s, 20.5 * s), 1.4 * s, darkPaint);
    canvas.drawCircle(Offset(24.5 * s, 20.5 * s), 1.4 * s, darkPaint);

    // Eye shines
    canvas.drawCircle(Offset(16 * s, 20 * s), 0.4 * s, shinePaint);
    canvas.drawCircle(Offset(25 * s, 20 * s), 0.4 * s, shinePaint);

    // Nose
    final noseRect = Rect.fromCenter(
      center: Offset(20 * s, 24.5 * s),
      width: 3.2 * s,
      height: 2.4 * s,
    );
    canvas.drawOval(noseRect, darkPaint2);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0x80000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9 * s
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(20 * s, 26 * s)
      ..lineTo(20 * s, 27.6 * s);
    canvas.drawPath(mouth, mouthPaint);
    final mouthCurve = Path()
      ..moveTo(18 * s, 27.6 * s)
      ..cubicTo(18.5 * s, 28.1 * s, 19 * s, 28.4 * s, 20 * s, 28.4 * s)
      ..cubicTo(21 * s, 28.4 * s, 21.5 * s, 28.1 * s, 22 * s, 27.6 * s);
    canvas.drawPath(mouthCurve, mouthPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
