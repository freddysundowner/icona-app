import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../controllers/auction_controller.dart';

class FloatingHeartsOptimized extends StatefulWidget {
  const FloatingHeartsOptimized({Key? key}) : super(key: key);

  @override
  _FloatingHeartsOptimizedState createState() =>
      _FloatingHeartsOptimizedState();
}

class _FloatingHeartsOptimizedState extends State<FloatingHeartsOptimized>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late Ticker _ticker;
  final List<Heart> _hearts = [];
  final int _maxHearts = 20;
  final bool _isAddingHearts =
      true; // Flag that indicates whether we can still add hearts
  bool _isStopped = false; // Flag to indicate everything has been stopped

  @override
  void initState() {
    super.initState();

    _ticker = Ticker((elapsed) {
      // If we've stopped, do nothing
      if (_isStopped) return;

      setState(() {
        _updateHearts();
      });
    });
    _ticker.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAddingRandomHearts();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Spawns hearts periodically for 15 seconds, then stops everything.
  void _startAddingRandomHearts() async {
    final startTime = DateTime.now();
    final cutoffTime = startTime.add(const Duration(seconds: 15));

    while (mounted && DateTime.now().isBefore(cutoffTime)) {
      // Generate a random number of hearts (between 1 and 4)
      int heartCount = 1 + _random.nextInt(4);

      for (int i = 0; i < heartCount; i++) {
        _addHeart();
      }

      // Delay before the next burst
      await Future.delayed(
        Duration(milliseconds: 800 + _random.nextInt(1200)),
      );
    }

    // After 15s, completely stop everything
    _stopAll();
  }

  /// Stops the ticker and clears all hearts from the screen
  void _stopAll() {
    if (_isStopped) return; // Prevent multiple calls
    _isStopped = true;
    _ticker.stop();
    _hearts.clear();
    setState(() {
      Get.find<AuctionController>().showbubble.value = false;
    }); // Update UI so it paints nothing
  }

  void _addHeart() {
    if (_hearts.length < _maxHearts && _isAddingHearts) {
      _hearts.add(
        Heart(
          xPosition: _random.nextDouble() * MediaQuery.of(context).size.width,
          size: 24 + _random.nextDouble() * 24,
          startTime: DateTime.now(),
          duration: Duration(seconds: 3 + _random.nextInt(2)),
          color: Colors.amber.withOpacity(0.8),
        ),
      );
    }
  }

  void _updateHearts() {
    final now = DateTime.now();
    _hearts.removeWhere((heart) => heart.isExpired(now));
    for (var heart in _hearts) {
      heart.updatePosition(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If everything is stopped, build a blank container
    if (_isStopped) {
      return const SizedBox.shrink();
    }

    // Otherwise, paint the hearts
    return CustomPaint(
      size: Size.infinite,
      painter: HeartPainter(_hearts),
    );
  }
}

class Heart {
  final double xPosition;
  final double size;
  final Color color;
  final DateTime startTime;
  final Duration duration;
  double yPosition = 0.0;

  Heart({
    required this.xPosition,
    required this.size,
    required this.color,
    required this.startTime,
    required this.duration,
  });

  bool isExpired(DateTime now) {
    return now.isAfter(startTime.add(duration));
  }

  void updatePosition(DateTime now) {
    final elapsed =
        now.difference(startTime).inMilliseconds / duration.inMilliseconds;
    // Move upward (1.0 down the screen to 0.0 at the top)
    yPosition = 1.0 - elapsed;
  }
}

class HeartPainter extends CustomPainter {
  final List<Heart> hearts;

  HeartPainter(this.hearts);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var heart in hearts) {
      paint.color = heart.color;

      final x = heart.xPosition;
      final y = size.height * heart.yPosition;

      final path = Path();
      path.moveTo(x, y);

      // Left lobe
      path.cubicTo(
        x - heart.size / 2,
        y - heart.size / 2,
        x - heart.size,
        y + heart.size / 3,
        x,
        y + heart.size,
      );

      // Right lobe
      path.cubicTo(
        x + heart.size,
        y + heart.size / 3,
        x + heart.size / 2,
        y - heart.size / 2,
        x,
        y,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
