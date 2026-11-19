
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../screens/course_detail_screen.dart';

class CourseCardPropDrilling extends StatelessWidget {
  final Course course;
  final bool isFavorite;
  final Future<void> Function() onFavoriteToggle;

  const CourseCardPropDrilling({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CourseDetailScreen(course: course),
            ),
          );
        },
        title: Text(course.title),
        subtitle: Text('SKS: ${course.credits}'),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () async {
            try {
              await onFavoriteToggle();
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memperbarui favorit: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
