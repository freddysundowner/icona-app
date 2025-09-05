import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      authController.callInit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // ✅ consistent
      body: FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: _animation,
          child: Center(
            // ✅ centers the column
            child: Column(
              mainAxisSize: MainAxisSize.min, // shrink to content
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ✅ center horizontally
              children: [
                // App Logo
                Image.asset(
                  "assets/images/logo_transparent.png",
                  width: 150.w,
                  height: 150.w,
                ),

                SizedBox(height: 20.h),

                // Slogan with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFF43F5E), Color(0xFF0D9488)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    "Shop Live, Sell Smarter",
                    textAlign: TextAlign.center, // ✅ center text
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: "Circular",
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // Subtle loading indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary, // Coral
                  ),
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
