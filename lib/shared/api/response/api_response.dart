class ApiResponse<T> {
  final int statusCode;
  final String time;
  final List<String> message;
  final String url;
  final List<T> data;

  ApiResponse({
    required this.statusCode,
    required this.time,
    required this.message,
    required this.url,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['status_code'],
      time: json['time'],
      message: List<String>.from(json['message']),
      url: json['url'],
      data: (json['data'] as List<dynamic>).map((e) => fromJsonT(e)).toList(),
    );
  }
}
