import 'package:flutter/material.dart';

class BlinkingLiveIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const BlinkingLiveIndicator({
    super.key,
    this.color = const Color(0xFFFF4D4D),
    this.size = 8.0,
  });

  @override
  State<BlinkingLiveIndicator> createState() => _BlinkingLiveIndicatorState();
}

class _BlinkingLiveIndicatorState extends State<BlinkingLiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.6),
              blurRadius: widget.size * 0.8,
              spreadRadius: widget.size * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}
