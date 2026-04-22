import 'package:flutter/material.dart';

// 🔹 Responsive Helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  // Breakpoints para diferentes dispositivos
  static bool isSmallMobile(BuildContext context) => MediaQuery.of(context).size.width < 375;
  static bool isLargeMobile(BuildContext context) => MediaQuery.of(context).size.width >= 375 && MediaQuery.of(context).size.width < 414; // iPhone Plus
  static bool isTabletPortrait(BuildContext context) => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
  static bool isTabletLandscape(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

  // Métodos para obtener tamanos dinamicos
  static double heroFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 32; // Mobile pequeno
    if (width < 768) return 38; // Mobile grande / Tablet pequeno
    if (width < 1024) return 44; // Tablet
    if (width < 1200) return 48; // Tablet grande
    return 52; // Desktop
  }

  static double subtitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 14;
    if (width < 768) return 16;
    if (width < 1024) return 17;
    return 18;
  }

  static double sectionTitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 24;
    if (width < 768) return 28;
    if (width < 1024) return 32;
    return 36;
  }

  static double cardWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 200;
    if (width < 768) return 220;
    if (width < 1024) return 240;
    if (width < 1200) return 260;
    return 280;
  }

  static double cardHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 280;
    if (width < 768) return 300;
    if (width < 1024) return 320;
    return 340;
  }

  static double horizontalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 768) return 24;
    if (width < 1024) return 40;
    if (width < 1200) return 50;
    return 60;
  }

  static double verticalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 32;
    if (width < 768) return 40;
    if (width < 1024) return 50;
    return 60;
  }

  static int gridCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 768) return 2;
    if (width < 1024) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  static int specialtiesCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 768) return 2;
    if (width < 1024) return 3;
    if (width < 1200) return 4;
    return 6;
  }

  static double cardImageHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 120;
    if (width < 768) return 140;
    if (width < 1024) return 150;
    return 160;
  }

  static double buttonHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 44;
    if (width < 768) return 48;
    return 52;
  }

  static double testimonialCardWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return width * 0.85;
    if (width < 768) return 300;
    if (width < 1024) return 320;
    return 340;
  }

  static double heroImageHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 300;
    if (width < 768) return 400;
    if (width < 1024) return 500;
    if (width < 1200) return 550;
    return 600;
  }

  static double logoImageHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 250;
    if (width < 768) return 300;
    if (width < 1024) return 400;
    return 500;
  }

  static double pilarCardWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return width * 0.8;
    if (width < 768) return 220;
    if (width < 1024) return 240;
    if (width < 1200) return 260;
    return 280;
  }

  static double ctaHorizPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 20;
    if (width < 768) return 28;
    if (width < 1024) return 32;
    if (width < 1200) return 36;
    return 40;
  }

  static double ctaVertPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 14;
    if (width < 768) return 16;
    return 20;
  }

  static double ctaFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 14;
    if (width < 768) return 16;
    return 18;
  }

  static double headerTitleSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 768) return 18;
    if (width < 1024) return 20;
    return 22;
  }

  static double sectionSpacing(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 40;
    if (width < 768) return 60;
    if (width < 1024) return 80;
    return 100;
  }

  static double ctaSectionFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 28;
    if (width < 768) return 36;
    if (width < 1024) return 42;
    return 48;
  }

  static double galeriaWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 150;
    if (width < 768) return 170;
    if (width < 1024) return 190;
    return 200;
  }

  static double galeriaHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 180;
    if (width < 768) return 200;
    if (width < 1024) return 230;
    return 250;
  }

  static double footerColumnWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return width / 2;
    return width / 3;
  }
}

// 🔹 Responsive Layout Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}