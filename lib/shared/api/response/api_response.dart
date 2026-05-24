class ApiResponse<T> {
  final int statusCode;
  final String time;
  final List<String> message;
  final String url;
  final T? data; // ← ACEPTA CUALQUIER TIPO: List, Map, String, null

  ApiResponse({
    required this.statusCode,
    required this.time,
    required this.message,
    required this.url,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT, // ← ACEPTA cualquier tipo
  ) {
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null) {
      if (rawData is List) {
        // Si es lista → mapear cada elemento
        parsedData = rawData.map(fromJsonT).toList() as T;
      } else {
        // Si es objeto, string, etc. → aplicar fromJsonT directamente
        parsedData = fromJsonT(rawData);
      }
    }

    int parseStatusCode(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) {
        return int.tryParse(val) ?? 0;
      }
      if (val is double) {
        return val.toInt();
      }
      return 0;
    }

    List<String> parseMessage(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [val.toString()];
    }

    return ApiResponse<T>(
      statusCode: parseStatusCode(json['status_code'] ?? json['statusCode']),
      time: (json['time'] ?? json['timestamp'] ?? '').toString(),
      message: parseMessage(json['message']),
      url: (json['url'] ?? json['path'] ?? '').toString(),
      data: parsedData,
    );
  }
}
