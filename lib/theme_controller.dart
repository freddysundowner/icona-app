import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static const MaterialColor kCoral = MaterialColor(
    0xFFFF435E, // main value
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFFF435E), // your main coral
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );
  static const MaterialColor kTeal = MaterialColor(
    0xFF0D9488,
    <int, Color>{
      50: Color(0xFFE0F2F1),
      100: Color(0xFFB2DFDB),
      200: Color(0xFF80CBC4),
      300: Color(0xFF4DB6AC),
      400: Color(0xFF26A69A),
      500: Color(0xFF0D9488), // your teal
      600: Color(0xFF00897B),
      700: Color(0xFF00796B),
      800: Color(0xFF00695C),
      900: Color(0xFF004D40),
    },
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: kCoral,
    primaryColor: kCoral,
    scaffoldBackgroundColor: Colors.white,

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      contentTextStyle: const TextStyle(color: Colors.black),
      titleTextStyle: const TextStyle(color: Colors.black),
    ),

    // Color Scheme
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: kCoral,
      onPrimary: Colors.black,
      secondary: kTeal,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      secondaryContainer: kCoral.withOpacity(0.3),
      onSecondaryContainer: Colors.grey.withOpacity(0.5),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerColor: Colors.grey.shade300,

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: kCoral,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kCoral,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kCoral,
        side: const BorderSide(color: kCoral),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),

    // Text Theme with ScreenUtil for responsive sizing
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "Circular"),
      bodyLarge: TextStyle(
          fontSize: 14.sp, color: Colors.black, fontFamily: "Circular"),
      bodyMedium: TextStyle(
          fontSize: 12.sp, color: Colors.black87, fontFamily: "Circular"),
      titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: "Circular"),
      titleSmall: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontFamily: "Circular"),
      bodySmall: TextStyle(
          fontSize: 12.sp, color: Colors.grey, fontFamily: "Circular"),
      labelSmall: TextStyle(
          fontSize: 10.sp, color: Colors.grey, fontFamily: "Circular"),
      labelLarge: TextStyle(
          fontSize: 14.sp,
          color: kCoral,
          fontWeight: FontWeight.bold,
          fontFamily: "Circular"),
      labelMedium: TextStyle(
          fontSize: 18.sp,
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: "Circular"),
    ),
  );

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: kCoral,
      primaryColor: kCoral,
      scaffoldBackgroundColor: Color(0xff131313),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.black,
        contentTextStyle: TextStyle(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          primary: kCoral,
          onPrimary: Colors.black,
          secondary: kTeal,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          error: Colors.red,
          secondaryContainer: Colors.white.withValues(alpha: 0.3),
          onSecondaryContainer: Colors.grey.withAlpha(50)),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff131313),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: kCoral,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            iconColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade700),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kCoral,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      dividerColor: Colors.grey.shade700,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kCoral,
          side: const BorderSide(color: kCoral),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Circular"),
          displayMedium: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          displaySmall: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          headlineMedium: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          headlineSmall: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          titleLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          bodyLarge: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          bodyMedium: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
            fontFamily: "Circular",
          ),
          titleMedium: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          titleSmall: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: "Circular",
          ),
          bodySmall: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
            fontFamily: "Circular",
          ),
          labelSmall: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontFamily: "Circular",
          ),
          labelLarge: TextStyle(
            fontSize: 14.sp,
            color: kCoral,
            fontWeight: FontWeight.bold,
            fontFamily: "Circular",
          ),
          labelMedium: TextStyle(
            fontSize: 18.sp,
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Circular",
          )));

  RxBool isDarkMode = true.obs;

  ThemeMode get currentThemeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
