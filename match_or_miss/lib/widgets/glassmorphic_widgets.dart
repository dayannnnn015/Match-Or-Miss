import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Glassmorphic card with hover and tap animations
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double sigmaX;
  final double sigmaY;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.border,
    this.boxShadow,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: widget.boxShadow ??
                    [
                      BoxShadow(
                        color: Colors.cyan.withValues(
                          alpha: 0.1 + (_elevationAnimation.value * 0.05),
                        ),
                        blurRadius: 20 + (_elevationAnimation.value * 2),
                        spreadRadius: 2 + (_elevationAnimation.value * 0.5),
                        offset: Offset(0, _elevationAnimation.value),
                      ),
                    ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: widget.sigmaX,
                    sigmaY: widget.sigmaY,
                  ),
                  child: Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      border: widget.border ??
                          Border.all(
                            color: Colors.cyan.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Gradient button with smooth animations
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = const LinearGradient(
      colors: [Colors.cyan, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.height = 56,
    this.borderRadius = 16,
    this.textStyle,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withValues(
                      alpha: 0.3 + (_scaleAnimation.value - 0.95) * 5,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.leftIcon != null) ...[
                          widget.leftIcon!,
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.label,
                          style: widget.textStyle ??
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                        ),
                        if (widget.rightIcon != null) ...[
                          const SizedBox(width: 12),
                          widget.rightIcon!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated progress indicator with glow effect
class GlowingProgressIndicator extends StatefulWidget {
  final double value;
  final Color color;
  final double size;
  final String? label;

  const GlowingProgressIndicator({
    super.key,
    required this.value,
    this.color = Colors.cyan,
    this.size = 100,
    this.label,
  });

  @override
  State<GlowingProgressIndicator> createState() =>
      _GlowingProgressIndicatorState();
}

class _GlowingProgressIndicatorState extends State<GlowingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: 0.3 * (1 - _pulseController.value),
                      ),
                      blurRadius: 20 + (_pulseController.value * 20),
                      spreadRadius: 5 + (_pulseController.value * 10),
                    ),
                  ],
                ),
              ),
              // Progress circle
              CircularProgressIndicator(
                value: widget.value,
                color: widget.color,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 4,
              ),
              // Center label or percentage
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              else
                Text(
                  '${(widget.value * 100).toInt()}%',
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
