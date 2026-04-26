import 'package:flutter/material.dart';
import '../models/game_models.dart';

/// A 2D bottle widget with liquid color inside
class BottleWidget extends StatelessWidget {
  final Bottle bottle;
  final double size;
  final bool isDragging;
  final VoidCallback? onTap;

  const BottleWidget({
    super.key,
    required this.bottle,
    this.size = 80,
    this.isDragging = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size * 1.3,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDragging ? Colors.white : Colors.white30,
            width: isDragging ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: bottle.color.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: CustomPaint(
          painter: BottlePainter(
            liquidColor: bottle.color,
            isDragging: isDragging,
          ),
          size: Size(size, size * 1.3),
        ),
      ),
    );
  }
}

/// Custom painter for 2D bottle with liquid
class BottlePainter extends CustomPainter {
  final Color liquidColor;
  final bool isDragging;

  BottlePainter({
    required this.liquidColor,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint liquidPaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Bottle cap/neck (top)
    final neckWidth = size.width * 0.35;
    final neckHeight = size.height * 0.15;
    final neckLeft = (size.width - neckWidth) / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(neckLeft, 0, neckWidth, neckHeight),
        const Radius.circular(4),
      ),
      borderPaint,
    );

    // Bottle body (main container)
    final bodyLeft = size.width * 0.1;
    final bodyTop = neckHeight;
    final bodyWidth = size.width * 0.8;
    final bodyHeight = size.height - neckHeight - size.width * 0.05;

    // Body outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(size.width * 0.15),
      ),
      borderPaint,
    );

    // Liquid fill (80% of bottle)
    final liquidHeight = bodyHeight * 0.8;
    final liquidTop = bodyTop + (bodyHeight - liquidHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyLeft + 2,
          liquidTop,
          bodyWidth - 4,
          liquidHeight - 2,
        ),
        Radius.circular(size.width * 0.15),
      ),
      liquidPaint,
    );

    // Highlight on liquid (shine effect)
    final highlightWidth = size.width * 0.15;
    final highlightHeight = liquidHeight * 0.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyLeft + 5,
          liquidTop + 2,
          highlightWidth,
          highlightHeight,
        ),
        Radius.circular(size.width * 0.08),
      ),
      highlightPaint,
    );

    // Bottle bottom shine
    final bottomShineRadius = size.width * 0.12;
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bottomShineRadius),
      bottomShineRadius,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(BottlePainter oldDelegate) {
    return oldDelegate.liquidColor != liquidColor ||
        oldDelegate.isDragging != isDragging;
  }
}
