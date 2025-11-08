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

    return ApiResponse<T>(
      statusCode: json['status_code'] as int,
      time: json['time'] as String,
      message: List<String>.from(json['message'] ?? []),
      url: json['url'] as String,
      data: parsedData,
    );
  }
}
