import 'package:flutter/material.dart';
import '../models/flag_style.dart';

class FlagCircleAvatar extends StatelessWidget {
  final String teamName;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final FlagStyle? flagStyle; // Optional pre-resolved style

  const FlagCircleAvatar({
    super.key,
    required this.teamName,
    this.size = 24.0,
    this.borderWidth = 1.0,
    this.borderColor,
    this.flagStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = flagStyle;
    final borderCol = borderColor ?? const Color(0xFF1E294B).withOpacity(0.8);

    // Fallback: if no flag style configuration exists, draw a gray circle with initials.
    if (style == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF334155),
          border: Border.all(color: borderCol, width: borderWidth),
        ),
        child: Center(
          child: Text(
            teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: FlagPainter(
          colors: style.flagColors,
          pattern: style.pattern,
          borderColor: borderCol,
          borderWidth: borderWidth,
        ),
      ),
    );
  }
}

class FlagPainter extends CustomPainter {
  final List<Color> colors;
  final FlagPattern pattern;
  final Color borderColor;
  final double borderWidth;

  FlagPainter({
    required this.colors,
    required this.pattern,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final clipPath = Path()..addOval(rect);

    canvas.save();
    canvas.clipPath(clipPath);

    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    switch (pattern) {
      case FlagPattern.solidCircle:
        paint.color = colors[0];
        canvas.drawRect(rect, paint);
        break;

      case FlagPattern.centeredCircle:
        // Background color
        paint.color = colors[0];
        canvas.drawRect(rect, paint);
        // Center circle (Japan, Tunisia, Morocco, South Korea)
        if (colors.length > 1) {
          paint.color = colors[1];
          if (colors.length > 2) {
            // South Korea yin-yang approximation
            final centerRect = Rect.fromCircle(center: center, radius: size.width * 0.28);
            canvas.save();
            canvas.clipPath(Path()..addOval(centerRect));
            
            // Top red half
            paint.color = colors[1];
            canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), paint);
            
            // Bottom blue half
            paint.color = colors[2];
            canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), paint);
            
            canvas.restore();
          } else {
            canvas.drawCircle(center, size.width * 0.28, paint);
          }
        }
        break;

      case FlagPattern.verticalStripes:
        final stripeCount = colors.length;
        final stripeWidth = size.width / stripeCount;
        for (int i = 0; i < stripeCount; i++) {
          paint.color = colors[i];
          canvas.drawRect(
            Rect.fromLTWH(i * stripeWidth, 0, stripeWidth + 0.5, size.height),
            paint,
          );
        }
        break;

      case FlagPattern.horizontalStripes:
        final stripeCount = colors.length;
        final stripeHeight = size.height / stripeCount;
        for (int i = 0; i < stripeCount; i++) {
          paint.color = colors[i];
          canvas.drawRect(
            Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight + 0.5),
            paint,
          );
        }
        break;

      case FlagPattern.cross:
        // Background color
        paint.color = colors[0];
        canvas.drawRect(rect, paint);

        if (colors.length > 1) {
          final crossColor = colors.length > 2 ? colors[2] : colors[1];
          final crossPaint = Paint()
            ..color = crossColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.22;
          
          // Draw cross
          canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), crossPaint);
          canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), crossPaint);

          // If Norway style, draw thinner inner cross
          if (colors.length > 2) {
            final innerCrossPaint = Paint()
              ..color = colors[1]
              ..style = PaintingStyle.stroke
              ..strokeWidth = size.width * 0.10;
            canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), innerCrossPaint);
            canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), innerCrossPaint);
          }
        }
        break;

      case FlagPattern.diagonalApproximation:
        // Background color
        paint.color = colors[0];
        canvas.drawRect(rect, paint);

        if (colors.length > 1) {
          final stripePaint = Paint()
            ..color = colors[1]
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.20;
          
          // Diagonal line bottom-left to top-right (e.g. Congo DR, Bosnia)
          canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), stripePaint);

          // Scotland: white diagonal cross (saltire)
          if (colors.length == 2 && colors[1] == Colors.white) {
            canvas.drawLine(Offset.zero, Offset(size.width, size.height), stripePaint);
          }

          // Red diagonal with yellow borders
          if (colors.length > 2) {
            final innerStripePaint = Paint()
              ..color = colors[2]
              ..style = PaintingStyle.stroke
              ..strokeWidth = size.width * 0.10;
            canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), innerStripePaint);
          }
        }
        break;

      case FlagPattern.complexApproximation:
        // Special drawing by colors
        if (colors.length >= 3 && colors[0] == const Color(0xFF0A3161)) {
          // USA: Canton + stripes
          final stripeHeight = size.height / 7;
          for (int i = 0; i < 7; i++) {
            paint.color = i % 2 == 0 ? colors[2] : colors[1];
            canvas.drawRect(
              Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight + 0.5),
              paint,
            );
          }
          paint.color = colors[0];
          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width * 0.5, size.height * 0.5),
            paint,
          );
        } else if (colors.length >= 3 && colors[0] == const Color(0xFF009739)) {
          // Brazil: Diamond + circle
          paint.color = colors[0];
          canvas.drawRect(rect, paint);

          final path = Path()
            ..moveTo(center.dx, size.height * 0.12)
            ..lineTo(size.width * 0.88, center.dy)
            ..lineTo(center.dx, size.height * 0.88)
            ..lineTo(size.width * 0.12, center.dy)
            ..close();
          paint.color = colors[1];
          canvas.drawPath(path, paint);

          paint.color = colors[2];
          canvas.drawCircle(center, size.width * 0.20, paint);
        } else if (colors.length >= 3 && colors[0] == const Color(0xFF11457E)) {
          // Czechia: Halves + Triangle
          paint.color = colors[1];
          canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), paint);
          paint.color = colors[2];
          canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), paint);
          
          paint.color = colors[0];
          final path = Path()
            ..moveTo(0, 0)
            ..lineTo(size.width * 0.45, center.dy)
            ..lineTo(0, size.height)
            ..close();
          canvas.drawPath(path, paint);
        } else if (colors.length >= 3 && colors[0] == const Color(0xFF00008B)) {
          // Australia / NZ: Union Jack + Blue background
          paint.color = colors[0];
          canvas.drawRect(rect, paint);
          final ujpaint = Paint()
            ..color = colors[1]
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.08;
          canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.4, size.height * 0.4), ujpaint);
          canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width * 0.4, 0), ujpaint);
          
          ujpaint.color = colors[2];
          ujpaint.strokeWidth = size.width * 0.04;
          canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.4, size.height * 0.4), ujpaint);
          canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width * 0.4, 0), ujpaint);
        } else if (colors.length >= 3 && colors[0] == const Color(0xFFDE3831)) {
          // South Africa: Red top, Blue bottom, Green horizontal stripe
          paint.color = colors[0];
          canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), paint);
          paint.color = colors[4];
          canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), paint);
          
          paint.color = colors[2];
          canvas.drawRect(
            Rect.fromLTWH(0, size.height * 0.38, size.width, size.height * 0.24),
            paint,
          );
        } else {
          // Fallback: draw vertical stripes
          final stripeCount = colors.length;
          final stripeWidth = size.width / stripeCount;
          for (int i = 0; i < stripeCount; i++) {
            paint.color = colors[i];
            canvas.drawRect(
              Rect.fromLTWH(i * stripeWidth, 0, stripeWidth + 0.5, size.height),
              paint,
            );
          }
        }
        break;
    }

    canvas.restore();

    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawOval(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FlagPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.pattern != pattern ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
