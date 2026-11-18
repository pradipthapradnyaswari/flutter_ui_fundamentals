import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_keys.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

import 'screens/dashboard_screen.dart';
import 'screens/auth_gate.dart';


const String studentName = 'MD. PRADIPTHA PRADNYASWARI';
const String studentId = '2415051055';

const String apiBaseUrl = 'https://jsonplaceholder.typicode.com';

const String supabaseUrl = 'https://bsdruahkljuzencndnhq.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHJ1YWhrbGp1emVuY25kbmhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMyMDc0NTgsImV4cCI6MjEwODc4MzQ1OH0.QceZacD92EQtq6Z56tKkZyt4qxPKYkx5TVtyjVqkOKc';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize(
  url: supabaseUrl,
  publishableKey: supabaseAnonKey,
);


  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository),
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
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      home: AuthGate(
        authenticatedBuilder: (_) => const DashboardScreen(),
      ),
    );
  }
}