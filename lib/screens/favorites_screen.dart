
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    final favoriteCourses = provider.courses
        .where((course) => provider.isFavorite(course.code))
        .toList();

    return favoriteCourses.isEmpty
        ? const Center(
            child: Text(
              'Belum ada mata kuliah favorit.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: favoriteCourses.length,
            itemBuilder: (context, index) {
              final course = favoriteCourses[index];

              return CourseCardPropDrilling(
                course: course,
                isFavorite: true,
                onFavoriteToggle: () async {
  await provider.toggleFavorite(course.code);
},
              );
            },
          );
  }
}
