import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository(CourseService());
  
  final Set<int> favorites = {};

  void toggleFavorite(int index) {
    if (favorites.contains(index)) {
      favorites.remove(index);
    } else {
      favorites.add(index);
    }
    notifyListeners();
  }

  bool isFavorite(int index) {
    return favorites.contains(index);
  }
}