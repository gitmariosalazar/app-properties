import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';

Map<String, double> extractCoordinates(String wkbHex) {
  if (wkbHex.isEmpty) {
    return {'longitude': -78.10616480, 'latitude': 0.32069990};
  }
  // Convert hex string to bytes
  final bytes = Uint8List.fromList(hex.decode(wkbHex));
  final byteData = ByteData.sublistView(bytes);
  final x = byteData.getFloat64(9, Endian.little);
  final y = byteData.getFloat64(17, Endian.little);

  return {'longitude': x, 'latitude': y};
}
