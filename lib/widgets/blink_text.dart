import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String text; // The text to display
  final TextStyle textStyle; // The style of the text
  final Duration duration; // The duration of the blinking effect

  const BlinkingText({
    required this.text,
    required this.textStyle,
    this.duration = const Duration(seconds: 1), // Default duration of 1 second
    Key? key,
  }) : super(key: key);

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration, // Use the specified duration
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
      child: Text(
        widget.text,
        style: widget.textStyle,
      ),
    );
  }
}
