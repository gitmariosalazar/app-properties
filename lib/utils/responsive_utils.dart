import 'package:flutter/material.dart';

enum DeviceType { mobileSmall, mobileMedium, mobileLarge, tablet }

class ResponsiveUtils {
  // === UMBRALES ===
  static const double _mobileSmallThreshold = 360;
  static const double _mobileMediumThreshold = 540;
  static const double _tabletThreshold = 720;

  // === DETECCIÓN DE DISPOSITIVO ===
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _tabletThreshold) return DeviceType.tablet;
    if (width >= _mobileMediumThreshold) return DeviceType.mobileLarge;
    if (width >= _mobileSmallThreshold) return DeviceType.mobileMedium;
    return DeviceType.mobileSmall;
  }

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;
  static bool isMobile(BuildContext context) =>
      deviceType(context) != DeviceType.tablet;
  static bool isSmallDevice(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileSmallThreshold;

  // === TAMAÑOS ===
  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // === ESCALADO ===
  static double scaleWidth(BuildContext context, double factor) {
    final width = ResponsiveUtils.width(context);
    final dpr = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0);
    return (width * factor) / dpr;
  }

  static double scaleHeight(BuildContext context, double factor) {
    final height = ResponsiveUtils.height(context);
    final dpr = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0);
    return (height * factor) / dpr;
  }

  // === ESPACIADORES ===
  static Widget hSpace(BuildContext context, double factor) =>
      SizedBox(width: scaleWidth(context, factor));
  static Widget vSpace(BuildContext context, double factor) =>
      SizedBox(height: scaleHeight(context, factor));

  // === PADDING ===
  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: scaleWidth(context, 0.04),
    vertical: scaleHeight(context, 0.02),
  );

  static EdgeInsets cardPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: scaleWidth(context, 0.03),
    vertical: scaleHeight(context, 0.015),
  );

  // === TIPOGRAFÍA (SIMPLE Y SEGURA) ===
  static TextStyle _getTextStyle(
    BuildContext context, {
    required double baseSize,
    FontWeight? weight,
    double letterSpacing = 0,
  }) {
    final scale = _getFontScale(context, baseSize);
    return TextStyle(
      fontSize: scale,
      fontWeight: weight ?? FontWeight.normal,
      letterSpacing: letterSpacing,
    );
  }

  static double _getFontScale(BuildContext context, double baseSize) {
    final width = ResponsiveUtils.width(context);
    const minWidth = 320.0;
    const maxWidth = 1200.0;
    const minScale = 0.8;
    const maxScale = 1.1;

    final ratio = ((width - minWidth) / (maxWidth - minWidth)).clamp(0.0, 1.0);
    var scale = minScale + (maxScale - minScale) * ratio;

    if (isTablet(context)) scale = scale.clamp(0.95, 1.05);

    return (baseSize * scale).roundToDouble();
  }

  // === ESTILOS DE TEXTO ===
  static TextStyle titleLarge(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 22 : 26,
    weight: FontWeight.w700,
  );

  static TextStyle titleMedium(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 18 : 20,
    weight: FontWeight.w600,
  );

  static TextStyle titleSmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 16 : 18,
    weight: FontWeight.w600,
  );

  static TextStyle titleExtraSmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 12 : 14,
    weight: FontWeight.w600,
  );

  static TextStyle bodyLarge(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 14 : 16,
    weight: FontWeight.w500,
  );

  static TextStyle bodyMedium(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 12 : 14,
    weight: FontWeight.w400,
  );

  static TextStyle bodySmall(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 10 : 12,
    weight: FontWeight.w400,
  );

  static TextStyle buttonText(BuildContext context) => _getTextStyle(
    context,
    baseSize: isSmallDevice(context) ? 14 : 16,
    weight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // === ALTURA Y ELEVACIÓN ===
  static double cardElevation(BuildContext context) =>
      isSmallDevice(context) ? 2.0 : 4.0;

  static double buttonHeight(BuildContext context) =>
      scaleHeight(context, 0.07).clamp(44.0, 56.0);

  // === TAMAÑOS DE BOTONES (CORREGIDOS) ===
  static double buttonExtraSmall(BuildContext context) =>
      scaleHeight(context, 0.03).clamp(32.0, 40.0);

  static double buttonSmallMedium(BuildContext context) =>
      scaleHeight(context, 0.04).clamp(36.0, 44.0);

  static double buttonSmall(BuildContext context) =>
      scaleHeight(context, 0.05).clamp(40.0, 48.0);

  static double buttonLarge(BuildContext context) =>
      scaleHeight(context, 0.09).clamp(48.0, 56.0);

  static double buttonExtraLarge(BuildContext context) =>
      scaleHeight(context, 0.11).clamp(56.0, 64.0);

  // === ÍCONOS ===
  static double iconExtraSmall(BuildContext context) =>
      scaleWidth(context, 0.07);
  static double iconSmall(BuildContext context) => scaleWidth(context, 0.09);
  static double iconMedium(BuildContext context) => scaleWidth(context, 0.12);
  static double iconLarge(BuildContext context) => scaleWidth(context, 0.15);

  // === BORDER RADIUS ===
  static double cardBorderRadius(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double buttonBorderRadius(BuildContext context) =>
      scaleWidth(context, 0.04);

  static double extraSmallBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.015);
  static double smallBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.025);
  static double mediumBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double largeBorderRadiusValue(BuildContext context) =>
      scaleWidth(context, 0.04);

  // === ESPACIADO ===
  static double extraSmallSpacing(BuildContext context) =>
      scaleWidth(context, 0.008);
  static double smallSpacing(BuildContext context) =>
      scaleWidth(context, 0.015);
  static double mediumSpacing(BuildContext context) =>
      scaleWidth(context, 0.03);
  static double largeSpacing(BuildContext context) => scaleWidth(context, 0.05);

  // === SECTION ===
  static double sectionDividerHeight(BuildContext context) =>
      scaleHeight(context, 0.025);
  static double sectionTitleSpacing(BuildContext context) =>
      scaleHeight(context, 0.05);

  // === VALORES DIRECTOS ===
  static double cardBorderRadiusValue(BuildContext context) =>
      cardBorderRadius(context);
  static double buttonBorderRadiusValue(BuildContext context) =>
      buttonBorderRadius(context);
}

// === EXTENSIÓN (100% compatible con tu código actual) ===
extension ResponsiveExtension on BuildContext {
  DeviceType get deviceType => ResponsiveUtils.deviceType(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isSmallDevice => ResponsiveUtils.isSmallDevice(this);

  Size get screenSize => ResponsiveUtils.screenSize(this);
  double get width => ResponsiveUtils.width(this);
  double get height => ResponsiveUtils.height(this);

  Widget hSpace(double f) => ResponsiveUtils.hSpace(this, f);
  Widget vSpace(double f) => ResponsiveUtils.vSpace(this, f);

  TextStyle get titleLarge => ResponsiveUtils.titleLarge(this);
  TextStyle get titleMedium => ResponsiveUtils.titleMedium(this);
  TextStyle get titleSmall => ResponsiveUtils.titleSmall(this);
  TextStyle get titleExtraSmall => ResponsiveUtils.titleExtraSmall(this);
  TextStyle get bodyLarge => ResponsiveUtils.bodyLarge(this);
  TextStyle get bodyMedium => ResponsiveUtils.bodyMedium(this);
  TextStyle get bodySmall => ResponsiveUtils.bodySmall(this);
  TextStyle get buttonText => ResponsiveUtils.buttonText(this);

  double get iconExtraSmall => ResponsiveUtils.iconExtraSmall(this);
  double get iconSmall => ResponsiveUtils.iconSmall(this);
  double get iconMedium => ResponsiveUtils.iconMedium(this);
  double get iconLarge => ResponsiveUtils.iconLarge(this);

  double get extraSmallSpacing => ResponsiveUtils.extraSmallSpacing(this);
  double get smallSpacing => ResponsiveUtils.smallSpacing(this);
  double get mediumSpacing => ResponsiveUtils.mediumSpacing(this);
  double get largeSpacing => ResponsiveUtils.largeSpacing(this);

  double get cardBorderRadiusValue =>
      ResponsiveUtils.cardBorderRadiusValue(this);
  double get buttonBorderRadiusValue =>
      ResponsiveUtils.buttonBorderRadiusValue(this);
  double get extraSmallBorderRadiusValue =>
      ResponsiveUtils.extraSmallBorderRadiusValue(this);
  double get smallBorderRadiusValue =>
      ResponsiveUtils.smallBorderRadiusValue(this);
  double get mediumBorderRadiusValue =>
      ResponsiveUtils.mediumBorderRadiusValue(this);
  double get largeBorderRadiusValue =>
      ResponsiveUtils.largeBorderRadiusValue(this);

  double get cardElevation => ResponsiveUtils.cardElevation(this);
  double get buttonHeight => ResponsiveUtils.buttonHeight(this);
  double get sectionDividerHeight => ResponsiveUtils.sectionDividerHeight(this);
  double get sectionTitleSpacing => ResponsiveUtils.sectionTitleSpacing(this);

  EdgeInsets get screenPadding => ResponsiveUtils.screenPadding(this);
  EdgeInsets get cardPadding => ResponsiveUtils.cardPadding(this);
}
