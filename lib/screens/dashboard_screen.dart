import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification_service.dart';
import '../main.dart' show studentName, studentId;
import '../providers/course_provider.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import '../widgets/error_view.dart';

import 'home_screen.dart';
import 'courses_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart';
import 'add_course_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late Future<UserProfile?> _profileFuture;

  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _primaryBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();

    _profileFuture = ProfileService().getMyProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<CourseProvider>();

      await NotificationService.instance.init();

      if (!mounted) return;

      await provider.loadCourses();
      provider.loadFavorites();

      NotificationService.instance.setupInteractedMessage();
    });
  }

  Widget _buildIdentityLabel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.center,
      child: Text(
        '$studentName - $studentId',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildAddCourseButton({required String role}) {
    return RoleGuard(
      role: role,
      allowed: const ['lecturer', 'admin'],
      child: FloatingActionButton(
        heroTag: 'addCourseButton',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Mata Kuliah',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Dashboard'),
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            const Expanded(child: Center(child: CircularProgressIndicator())),
            _buildIdentityLabel(),
          ],
        ),
      );
    }

    if (courseProvider.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Dashboard'),
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: ErrorView(
                message: courseProvider.error!,
                onRetry: () => courseProvider.loadCourses(),
              ),
            ),
            _buildIdentityLabel(),
          ],
        ),
      );
    }

    if (courseProvider.courses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Dashboard'),
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Data course belum tersedia',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            _buildIdentityLabel(),
          ],
        ),
      );
    }

    final List<Widget> pages = [
      const HomeScreen(),
      const CoursesScreen(),
      const FavoritesScreen(),
      const ProfilePage(),
    ];

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        final String role = profileSnapshot.data?.role ?? '';

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isExpanded = constraints.maxWidth >= 840;

            const List<String> pageTitles = [
              'Home',
              'Courses',
              'Favorites',
              'Profile',
            ];

            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitles[_currentIndex]),
                backgroundColor: _darkBlue,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.feedback),
                    tooltip: 'Beri Umpan Balik',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpanded)
                          NavigationRail(
                            selectedIndex: _currentIndex,
                            onDestinationSelected: (index) {
                              setState(() => _currentIndex = index);
                            },
                            labelType: NavigationRailLabelType.all,
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.home),
                                label: Text('Home'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.school),
                                label: Text('Courses'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.favorite),
                                label: Text('Favorites'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.person),
                                label: Text('Profile'),
                              ),
                            ],
                          ),
                        if (isExpanded)
                          const VerticalDivider(width: 1, thickness: 1),
                        Expanded(child: pages[_currentIndex]),
                      ],
                    ),
                  ),
                  _buildIdentityLabel(),
                ],
              ),
              floatingActionButton: _currentIndex == 1
                  ? _buildAddCourseButton(role: role)
                  : null,
              bottomNavigationBar: isExpanded
                  ? null
                  : NavigationBar(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        setState(() => _currentIndex = index);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.school),
                          label: 'Courses',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.favorite),
                          label: 'Favorites',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
