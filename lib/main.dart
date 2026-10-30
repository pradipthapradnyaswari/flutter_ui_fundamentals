import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_api_service.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

import 'screens/profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'widgets/course_card.dart';
import 'layouts/compact_layout.dart';
import 'layouts/medium_layout.dart';
import 'layouts/expanded_layout.dart';
import 'screens/favorites_screen.dart';
import 'widgets/error_view.dart';
import 'screens/add_course_screen.dart';

const String studentName = 'MD. PRADIPTHA PRADNYASWARI';
const String studentId = '2415051055';

const String supabaseUrl = 'https://bsdruahkljuzencndnhq.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHJ1YWhrbGp1emVuY25kbmhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMyMDc0NTgsImV4cCI6MjEwODc4MzQ1OH0.QceZacD92EQtq6Z56tKkZyt4qxPKYkx5TVtyjVqkOKc';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  const String apiBaseUrl = 'https://jsonplaceholder.typicode.com';
  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository)..loadCourses(),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
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
        body: ErrorView(
          message: courseProvider.error!,
          onRetry: () => courseProvider.loadCourses(),
        ),
      );
    }

    if (courseProvider.courses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Dashboard')),
        body: const Center(child: Text('Data course belum tersedia', style: TextStyle(fontSize: 18))),
      );
    }

    final courses = courseProvider.courses;

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
                          const Text(
                            studentName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'NIM: $studentId',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
            const Text(
              'Mahasiswa Aktif: $studentId\n$studentName',
              style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return const CompactLayout();
                } else if (constraints.maxWidth < 900) {
                  return const MediumLayout();
                } else {
                  return const ExpandedLayout();
                }
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

          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              '$studentId\n$studentName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
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
          floatingActionButton: isExpanded ? null : FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCourseScreen()),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
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