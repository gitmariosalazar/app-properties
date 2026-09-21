import 'package:flutter/material.dart';

class AppMapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final Widget widget;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const AppMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.widget,
    this.width = 50.0,
    this.height = 50.0,
    this.onTap,
  });
}
