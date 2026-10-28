import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService apiService;

  CourseRepository(this.apiService);

  Future<List<Course>> getCourses() async {
    return await apiService.getCourses();
  }

  Future<Course> addCourse(Course course) async {
    return await apiService.createCourse(course);
  }
}