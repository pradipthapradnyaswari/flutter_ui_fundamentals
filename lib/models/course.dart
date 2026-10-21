class Course {
  final String code;
  final String title;
  final String category; // Tambahan agar UI sebelumnya tidak error
  final int credits;
  final String status;

  Course({
    required this.code,
    required this.title,
    required this.category,
    required this.credits,
    required this.status,
  });

  // Factory untuk mem-parsing JSON menjadi Object Course
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      credits: json['credits'] as int,
      status: json['status'] as String,
    );
  }
}