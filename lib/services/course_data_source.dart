
import '../models/course.dart';

abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);

  // Favorite
  Future<List<String>> getFavorites();
  Future<void> addFavorite(String courseCode);
  Future<void> removeFavorite(String courseCode);
}
