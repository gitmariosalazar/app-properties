// lib/features/scan/data/datasources/scan_datasource.dart
abstract class ScanDataSource {
  Future<String> scanQR();
}

class ScanDataSourceImpl implements ScanDataSource {
  @override
  Future<String> scanQR() async {
    // In actual impl, this would be handled in presentation layer with mobile_scanner
    // But for repo, we can mock or leave as is. Since scanning is UI-driven, usecase might not be needed, but for clean arch, we keep it.
    throw UnimplementedError('Scanning is handled in UI');
  }
}
