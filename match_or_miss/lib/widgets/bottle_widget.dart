import 'package:flutter/material.dart';
import '../models/game_models.dart';

/// Premium 3D-style bottle widget with glass-like appearance and animated liquid
class BottleWidget extends StatefulWidget {
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
  State<BottleWidget> createState() => _BottleWidgetState();
}

class _BottleWidgetState extends State<BottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive sizing: scale down on mobile, scale up intelligently on larger screens
    final responsiveSize = screenWidth < 480
        ? widget.size * 0.85
        : screenWidth < 768
            ? widget.size * 0.95
            : widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: responsiveSize,
        height: responsiveSize * 1.54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsiveSize * 0.12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Transform.scale(
          scale: widget.isDragging ? 1.08 : 1.0,
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return CustomPaint(
                painter: PremiumBottlePainter(
                  liquidColor: widget.bottle.color,
                  isDragging: widget.isDragging,
                  shimmerValue: _shimmerController.value,
                ),
                size: Size(responsiveSize, responsiveSize * 1.54),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Premium custom painter for 3D glass-like bottle with animated liquid
class PremiumBottlePainter extends CustomPainter {
  final Color liquidColor;
  final bool isDragging;
  final double shimmerValue;

  PremiumBottlePainter({
    required this.liquidColor,
    required this.isDragging,
    required this.shimmerValue,
  });

  // ─ Color helpers ─────────────────────────────────────────────────────────
  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final glassEdgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.2),
        ],
        stops: [
          (shimmerValue - 0.3).clamp(0, 1).toDouble(),
          shimmerValue.clamp(0, 1).toDouble(),
          (shimmerValue + 0.3).clamp(0, 1).toDouble(),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Bottle cap (glossy top)
    final capWidth = size.width * 0.24;
    final capHeight = size.height * 0.10;
    final capLeft = (size.width - capWidth) / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(capLeft, 0, capWidth, capHeight),
        Radius.circular(size.width * 0.06),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    // Cap highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(capLeft + 1, 1, capWidth - 2, capHeight * 0.5),
        Radius.circular(size.width * 0.04),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );

    // Bottle neck transition (narrower for elegant look)
    final neckTopWidth = size.width * 0.22;
    final neckBottomWidth = size.width * 0.35;
    final neckHeight = size.height * 0.18;
    final neckLeft = (size.width - neckTopWidth) / 2;

    Path neckPath = Path()
      ..moveTo(neckLeft, capHeight)
      ..lineTo(neckLeft - (neckBottomWidth - neckTopWidth) / 2, capHeight + neckHeight)
      ..lineTo(neckLeft - (neckBottomWidth - neckTopWidth) / 2 + neckBottomWidth, capHeight + neckHeight)
      ..lineTo(neckLeft + neckTopWidth, capHeight)
      ..close();

    canvas.drawPath(neckPath, glassEdgePaint);

    // Bottle body (main container - slimmer proportions)
    final bodyWidth = size.width * 0.52;
    final bodyLeft = (size.width - bodyWidth) / 2;
    final bodyTop = capHeight + neckHeight;
    final bodyHeight = size.height - bodyTop - size.width * 0.05;
    final bodyRadius = size.width * 0.18;

    // Base floor shadow for depth
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height - size.width * 0.03),
        width: bodyWidth * 0.84,
        height: size.width * 0.12,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    // Main glass body outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      glassEdgePaint,
    );

    // Color rim glow adds subtle material tint to the glass edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      Paint()
        ..color = liquidColor.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012,
    );

    // Liquid fill (88% of bottle)
    final liquidHeight = bodyHeight * 0.88;
    final liquidTop = bodyTop + (bodyHeight - liquidHeight);

    // Liquid base fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyLeft + 2,
          liquidTop,
          bodyWidth - 4,
          liquidHeight - 2,
        ),
        Radius.circular(bodyRadius - 2),
      ),
      Paint()
        ..color = liquidColor
        ..style = PaintingStyle.fill,
    );

    // Advanced liquid gradient (multiple color stops for depth)
    final liquidRect = Rect.fromLTWH(bodyLeft + 2, liquidTop, bodyWidth - 4, liquidHeight - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft + 2, liquidTop, bodyWidth - 4, liquidHeight - 2),
        Radius.circular(bodyRadius - 2),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _darken(liquidColor, 0.35),
            liquidColor,
            _lighten(liquidColor, 0.25),
            liquidColor,
            _darken(liquidColor, 0.2),
          ],
          stops: const [0.0, 0.18, 0.42, 0.72, 1.0],
        ).createShader(liquidRect),
    );

    // Internal caustic blob (light refracted through glass)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft + 2, liquidTop, bodyWidth - 4, liquidHeight - 2),
        Radius.circular(bodyRadius - 2),
      ),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.65,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.transparent,
          ],
        ).createShader(liquidRect),
    );

    // Meniscus on top of liquid for a more realistic fluid surface
    canvas.drawOval(
      Rect.fromLTWH(
        bodyLeft + 3,
        liquidTop - size.height * 0.012,
        bodyWidth - 6,
        size.height * 0.03,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            liquidColor.withValues(alpha: 0.35),
          ],
        ).createShader(
          Rect.fromLTWH(bodyLeft, liquidTop, bodyWidth, size.height * 0.03),
        ),
    );

    // Glass overlay: Left-edge dark rim (depth illusion)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth * 0.22, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth * 0.22, bodyHeight)),
    );

    // Right-edge dark rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft + bodyWidth * 0.78, bodyTop, bodyWidth * 0.22, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(bodyLeft + bodyWidth * 0.78, bodyTop, bodyWidth * 0.22, bodyHeight)),
    );

    // Broad left specular highlight (main 3D illusion)
    final highlightW = bodyWidth * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft + bodyWidth * 0.08, bodyTop, highlightW, bodyHeight),
        Radius.circular(bodyRadius - 2),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(bodyLeft + bodyWidth * 0.08, bodyTop, highlightW, bodyHeight)),
    );

    // Narrow sharp specular streak
    final streakL = bodyLeft + bodyWidth * 0.14;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          streakL,
          bodyTop + bodyHeight * 0.04,
          bodyWidth * 0.07,
          bodyHeight * 0.68,
        ),
        Radius.circular(bodyWidth * 0.04),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.60),
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.40),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.35, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(streakL, bodyTop + bodyHeight * 0.04, bodyWidth * 0.07, bodyHeight * 0.68)),
    );

    // Liquid bottom wave effect
    final waveHeight = liquidHeight * 0.08;
    Path wavePath = Path()
      ..moveTo(bodyLeft + 2, liquidTop + liquidHeight - waveHeight)
      ..quadraticBezierTo(
        bodyLeft + bodyWidth / 4,
        liquidTop + liquidHeight - waveHeight + 3,
        bodyLeft + bodyWidth / 2,
        liquidTop + liquidHeight - waveHeight,
      )
      ..quadraticBezierTo(
        bodyLeft + bodyWidth * 0.75,
        liquidTop + liquidHeight - waveHeight - 3,
        bodyLeft + bodyWidth - 2,
        liquidTop + liquidHeight - waveHeight,
      )
      ..lineTo(bodyLeft + bodyWidth - 2, liquidTop + liquidHeight - 2)
      ..lineTo(bodyLeft + 2, liquidTop + liquidHeight - 2)
      ..close();

    canvas.drawPath(wavePath, Paint()..color = liquidColor.withValues(alpha: 0.6));

    // Liquid shine gradient
    final shineWidth = bodyWidth * 0.18;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyLeft + 4,
          liquidTop + 2,
          shineWidth,
          liquidHeight * 0.45,
        ),
        Radius.circular(size.width * 0.1),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill,
    );

    // Animated shimmer across glass
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        Radius.circular(bodyRadius),
      ),
      shimmerPaint,
    );

    // Vertical refraction streak for deeper glass realism
    final refractX = bodyLeft + bodyWidth * (0.58 + (shimmerValue - 0.5) * 0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          refractX,
          bodyTop + bodyHeight * 0.08,
          bodyWidth * 0.08,
          bodyHeight * 0.78,
        ),
        Radius.circular(bodyWidth * 0.05),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.03),
            Colors.black.withValues(alpha: 0.06),
          ],
        ).createShader(Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight)),
    );

    // Top glass highlight (3D effect)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyLeft + 3,
          bodyTop + 3,
          bodyWidth * 0.4,
          bodyHeight * 0.26,
        ),
        Radius.circular(bodyRadius - 3),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill,
    );

    // Bottom bubble shine
    canvas.drawCircle(
      Offset(bodyLeft + bodyWidth * 0.2, bodyTop + bodyHeight - size.width * 0.08),
      size.width * 0.1,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    // Dragging glow enhancement
    if (isDragging) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
          Radius.circular(bodyRadius),
        ),
        Paint()
          ..color = liquidColor.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(PremiumBottlePainter oldDelegate) {
    return oldDelegate.liquidColor != liquidColor ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.shimmerValue != shimmerValue;
  }
}
