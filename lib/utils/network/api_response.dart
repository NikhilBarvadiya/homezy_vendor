class APIResponse {
  final bool success;
  final dynamic message;
  final dynamic data;
  final int? currentPage;
  final int? totalPages;
  final bool? hasMore;
  final int? status;

  APIResponse({required this.success, this.message, this.data, this.currentPage, this.totalPages, this.hasMore, this.status});

  factory APIResponse.fromJson(Map<String, dynamic> json) {
    return APIResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasMore: json['hasMore'],
      status: json['status'],
    );
  }
}
