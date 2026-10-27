import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'screens/profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'widgets/course_card.dart';
import 'layouts/compact_layout.dart';
import 'layouts/medium_layout.dart';
import 'layouts/expanded_layout.dart';
import 'screens/favorites_screen.dart';

const String studentName = 'MD. PRADIPTHA PRADNYASWARI';
const String studentId = '2415051055';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CourseProvider(CourseRepository(CourseService())),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<void> testFetchCourses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        final List<Course> fetchedCourses = data.map((json) => Course.fromJson(json)).toList();
        debugPrint('GET & PARSING BERHASIL! Jumlah objek Course: ${fetchedCourses.length}');
        debugPrint('Data 1: ${fetchedCourses[0].code} | ${fetchedCourses[0].title} | ${fetchedCourses[0].status}');
        debugPrint('Data 2: ${fetchedCourses[1].code} | ${fetchedCourses[1].title} | ${fetchedCourses[1].status}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil mem-parsing ${fetchedCourses.length} Course dari API!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Terjadi kesalahan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    testFetchCourses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Widget buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 26),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (courseProvider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Dashboard')),
        body: Center(child: Text('Gagal memuat data: ${courseProvider.error}')),
      );
    }

    final courses = courseProvider.courses;
    final int totalCourses = courses.length;
    final int completedCourses = courses.where((c) => c.status == 'done').length;
    final int totalCredits = courses.fold(0, (sum, item) => sum + item.credits);

    final List<Widget> pages = [
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/profil.jpg'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIM: $studentId',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selamat Datang di Learning Dashboard!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mahasiswa Aktif: $studentId\n$studentName',
              style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) return const CompactLayout();
                else if (constraints.maxWidth < 900) return const MediumLayout();
                else return const ExpandedLayout();
              },
            ),
          ],
        ),
      ),

      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Total Favorit: ${context.watch<CourseProvider>().favorites.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final Course course = courses[index];
                final isFav = context.watch<CourseProvider>().isFavorite(course.code); 
                return CourseCardPropDrilling(
                  course: course,
                  isFavorite: isFav, 
                  onFavoriteToggle: () => context.read<CourseProvider>().toggleFavorite(course.code),
                );
              },
            ),
          ),
        ],
      ),

      const FavoritesScreen(),

      const ProfilePage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isExpanded = constraints.maxWidth >= 840;
        
        String appBarTitle = 'Home';
        if (_currentIndex == 1) appBarTitle = 'Courses';
        if (_currentIndex == 2) appBarTitle = 'Favorites';
        if (_currentIndex == 3) appBarTitle = 'Profile';

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.feedback),
                tooltip: 'Beri Umpan Balik',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackPage()),
                  );
                },
              ),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              if (isExpanded)
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.school), label: Text('Courses')),
                    NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Favorites')),
                    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
                  ],
                ),
              if (isExpanded) const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: pages[_currentIndex]),
            ],
          ),
          bottomNavigationBar: isExpanded
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
                    NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'), 
                    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                  ],
                ),
        );
      },
    );
  }
}