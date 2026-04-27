// lib/widgets/bottle_widget.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class BottleWidget extends StatefulWidget {
  final Bottle bottle;
  final double size;
  final bool isDragging;
  
  const BottleWidget({
    super.key,
    required this.bottle,
    this.size = 60,
    this.isDragging = false,
  });

  @override
  State<BottleWidget> createState() => _BottleWidgetState();
}

class _BottleWidgetState extends State<BottleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  
  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.isDragging ? 1.08 : 1,
      child: CustomPaint(
        painter: GlassBottlePainter(color: widget.bottle.color, shimmer: _shimmer.value),
        size: Size(widget.size, widget.size * 1.54),
      ),
    );
  }
}

class GlassBottlePainter extends CustomPainter {
  final Color color;
  final double shimmer;
  
  GlassBottlePainter({required this.color, required this.shimmer});

  Color _darken(Color c, [double amt = 0.2]) {
    return HSLColor.fromColor(c)
        .withLightness((HSLColor.fromColor(c).lightness - amt).clamp(0, 1))
        .toColor();
  }

  Color _lighten(Color c, [double amt = 0.2]) {
    return HSLColor.fromColor(c)
        .withLightness((HSLColor.fromColor(c).lightness + amt).clamp(0, 1))
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bodyLeft = size.width * 0.22;
    final bodyWidth = size.width * 0.56;
    final bodyTop = size.height * 0.12;
    final bodyHeight = size.height * 0.78;
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
      Radius.circular(size.width * 0.12),
    );

    // Fill
    canvas.drawRRect(bodyRRect, Paint()..color = color.withValues(alpha: 0.85));
    
    // Gradient depth
    canvas.drawRRect(
      bodyRRect,
      Paint()..shader = LinearGradient(
        colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, Colors.white.withValues(alpha: 0.15)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight)),
    );
    
    // Highlight streak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft + 4, bodyTop + 4, bodyWidth * 0.12, bodyHeight - 8),
        Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.3 + shimmer * 0.15),
    );
    
    // Cap
    final capLeft = size.width * 0.36;
    final capWidth = size.width * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(capLeft, 0, capWidth, size.height * 0.1),
        Radius.circular(6),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    
    // Rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(capLeft - 2, 0, capWidth + 4, size.height * 0.08),
        Radius.circular(8),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(GlassBottlePainter old) {
    return old.color != color || old.shimmer != shimmer;
  }
}