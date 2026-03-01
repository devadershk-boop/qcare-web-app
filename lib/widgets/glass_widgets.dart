import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 🌈 Full-screen smooth gradient background - Slightly more saturated
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A), // Slate 900
                      const Color(0xFF1E293B), // Slate 800
                      const Color(0xFF1E1B4B), // Custom Deep Indigo
                    ]
                  : [
                      const Color(0xFFF0F9FF), // Sky 50
                      const Color(0xFFE0F2FE), // Sky 100
                      const Color(0xFFBAE6FD), // Sky 200
                    ],
            ),
          ),
        ),

        // 🔵 Subtle blurred decorative circles - Increased opacity slightly
        Positioned(
          top: -50,
          left: -50,
          child: _BlurredCircle(
            size: 200,
            color: Colors.blue.withOpacity(0.4),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: _BlurredCircle(
            size: 250,
            color: Colors.purple.withOpacity(0.3),
          ),
        ),
        Positioned(
          top: 250,
          right: 40,
          child: _BlurredCircle(
            size: 150,
            color: Colors.teal.withOpacity(0.2),
          ),
        ),

        // 🖼️ Content
        SafeArea(child: child),
      ],
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurredCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 25,
    this.blur = 15,
    this.opacity = 0.25, // Increased slightly for visibility
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // Slightly brighter border
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 🚀 REUSABLE HOVER ANIMATION WIDGET
class HoverItem extends StatefulWidget {
  final Widget child;
  final double hoverOffset;
  final double hoverScale;

  const HoverItem({
    super.key,
    required this.child,
    this.hoverOffset = -10, // Move up by 10 pixels
    this.hoverScale = 1.02, // Scale up slightly
  });

  @override
  State<HoverItem> createState() => _HoverItemState();
}

class _HoverItemState extends State<HoverItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? widget.hoverOffset : 0.0)
          ..scale(_isHovered ? widget.hoverScale : 1.0),
        child: widget.child,
      ),
    );
  }
}
