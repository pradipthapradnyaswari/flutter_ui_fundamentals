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

  Future<void> updateCourse(int id, Course course) async {
    await apiService.updateCourse(id, course);
  }

  Future<void> deleteCourse(int id) async {
    await apiService.deleteCourse(id);
  }
}