import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {
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