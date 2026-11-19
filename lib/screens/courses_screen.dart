
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../models/course.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Total Favorit: ${provider.favorites.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final Course course = courses[index];
              final isFav = provider.isFavorite(course.code);

              return CourseCardPropDrilling(
                course: course,
                isFavorite: isFav,
                onFavoriteToggle: () async {
  await context
      .read<CourseProvider>()
      .toggleFavorite(course.code);
},
              );
            },
          ),
        ),
      ],
    );
  }
}
