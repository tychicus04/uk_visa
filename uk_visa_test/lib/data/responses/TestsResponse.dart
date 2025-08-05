import '../models/Test.dart';

class TestsResponse {
  final bool success;
  final Map<String, List<Test>> data;

  TestsResponse({
    required this.success,
    required this.data,
  });

  factory TestsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final testData = <String, List<Test>>{};

    data.forEach((key, value) {
      if (value is List) {
        testData[key] = value.map((test) => Test.fromJson(test)).toList();
      }
    });

    return TestsResponse(
      success: json['success'] ?? false,
      data: testData,
    );
  }
}