
import 'package:flutter/foundation.dart';

import '../../models/course.dart';
import '../../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  final Set<String> favorites = {};

  bool isLoadingFavorites = false;
  String? favoriteError;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Memuat favorit dari Supabase.
  Future<void> loadFavorites() async {
    isLoadingFavorites = true;
    favoriteError = null;
    notifyListeners();

    try {
      final favoriteCodes = await repository.getFavorites();

      favorites
        ..clear()
        ..addAll(favoriteCodes);
    } catch (e) {
      favoriteError = e.toString();
    } finally {
      isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // Menambah atau menghapus favorit di Supabase.
  Future<void> toggleFavorite(String courseCode) async {
    if (isLoadingFavorites) return;

    final wasFavorite = favorites.contains(courseCode);

    // Simpan kondisi sebelumnya untuk pemulihan jika gagal.
    if (wasFavorite) {
      favorites.remove(courseCode);
    } else {
      favorites.add(courseCode);
    }

    favoriteError = null;
    notifyListeners();

    try {
      if (wasFavorite) {
        await repository.removeFavorite(courseCode);
      } else {
        await repository.addFavorite(courseCode);
      }
    } catch (e) {
      // Kembalikan tampilan jika penyimpanan gagal.
      if (wasFavorite) {
        favorites.add(courseCode);
      } else {
        favorites.remove(courseCode);
      }

      favoriteError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  bool isFavorite(String courseCode) {
    return favorites.contains(courseCode);
  }

  Future<bool> addCourse(Course course) async {
    try {
      await repository.createCourse(course);
      await loadCourses();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(int id, Course course) async {
    try {
      await repository.updateCourse(id, course);
      await loadCourses();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(int id, String courseCode) async {
    try {
      await repository.deleteCourse(id);

      if (favorites.contains(courseCode)) {
        await repository.removeFavorite(courseCode);
        favorites.remove(courseCode);
      }

      await loadCourses();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
