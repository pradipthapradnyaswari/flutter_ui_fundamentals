import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCardPropDrilling extends StatefulWidget {
  final Course course;
  final bool isFavorite; 
  final VoidCallback onFavoriteToggle; 

  const CourseCardPropDrilling({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<CourseCardPropDrilling> createState() => _CourseCardPropDrillingState();
}

class _CourseCardPropDrillingState extends State<CourseCardPropDrilling> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        title: Text(widget.course.title),
        subtitle: _isExpanded ? Text('SKS: ${widget.course.credits}') : null,
        trailing: IconButton(
          icon: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: widget.onFavoriteToggle, 
        ),
      ),
    );
  }
}