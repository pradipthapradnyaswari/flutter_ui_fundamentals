import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'MD. PRADIPTHA PRADNYASWARI';
const String studentId = '2415051055';

void main() {
  runApp(const MyApp());
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
  late Future<Map<String, dynamic>> studentFuture;
  
  int _currentIndex = 0;

  final Set<int> _favoriteIndices = {};

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  Future<Map<String, dynamic>> loadStudentData() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );
    return jsonDecode(jsonString) as Map<String, dynamic>;
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
    return FutureBuilder<Map<String, dynamic>>(
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Learning Dashboard')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Learning Dashboard')),
            body: Center(child: Text('Gagal memuat data: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Learning Dashboard')),
            body: const Center(child: Text('Tidak ada data tersedia')),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = data['courses'] as List<dynamic>;

        final int totalCourses = courses.length;
        final int completedCourses = courses.where((c) => c['status'] == 'done').length;
        final int totalCredits = courses.fold(0, (sum, item) => sum + (item['credits'] as int));

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
                                student['name'] as String,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIM: ${student['nim']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    buildSummaryCard('Total Topik', '$totalCourses Topik', Icons.book),
                    const SizedBox(width: 8),
                    buildSummaryCard('Selesai', '$completedCourses Selesai', Icons.check_circle),
                    const SizedBox(width: 8),
                    buildSummaryCard('Total SKS', '$totalCredits SKS', Icons.credit_card),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang di Learning Dashboard!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mahasiswa Aktif: $studentId - $studentName',
                  style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index] as Map<String, dynamic>;
              final String status = course['status'] as String;
              final bool isDone = status == 'done';
              final String category = course['category'] as String; 
              
              final bool isFavorite = _favoriteIndices.contains(index);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailPage(course: course),
                      ),
                    );

                    if (result == true && context.mounted) {
                      setState(() {
                        _favoriteIndices.add(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berhasil menandai materi: ${course['title']} sebagai favorit!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Info: ${course['title']} (Kode: ${course['code']}) • Mahasiswa: $studentId'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Icon(
                        isDone ? Icons.check_circle : Icons.schedule,
                        color: isDone ? Colors.green : Colors.orange,
                      ),
                      title: Text(course['title'] as String),
                      subtitle: Text('Kode: ${course['code']} • Kategori: $category • SKS: ${course['credits']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isFavorite) {
                                  _favoriteIndices.remove(index);
                                } else {
                                  _favoriteIndices.add(index);
                                }
                              });
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFavorite ? 'Dihapus dari Favorit' : 'Ditambahkan ke Favorit'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDone ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const ProfilePage(),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isExpanded = constraints.maxWidth >= 840;

            return Scaffold(
              appBar: AppBar(
                title: Text(_currentIndex == 0 ? 'Home' : _currentIndex == 1 ? 'Courses' : 'Profile'),
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
                children: [
                  if (isExpanded)
                    NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
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
                          icon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
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
                      onDestinationSelected: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
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

class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade100, 
      child: const Text(
        '$studentId - $studentName\nKategori: Compact Layout', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade100, 
      child: const Text(
        '$studentId - $studentName\nKategori: Medium Layout', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
    );
  }
}

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.purple.shade100, 
      child: const Text(
        '$studentId - $studentName\nKategori: Expanded Layout', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontWeight: FontWeight.bold)
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String title = course['title'] as String;
    final String code = course['code'] as String;
    final String category = course['category'] as String;
    final int credits = course['credits'] as int;
    final String status = course['status'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Kode Mata Kuliah: $code', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Kategori: $category', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Jumlah SKS: $credits', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Status: ${status.toUpperCase()}', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: status == 'done' ? Colors.green : Colors.orange,
              ),
            ),
            const Divider(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.favorite),
                label: const Text('Tandai Materi Dipilih / Favorit'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: studentName);
  final TextEditingController _nimController = TextEditingController(text: studentId);
  final TextEditingController _feedbackController = TextEditingController();

  String _selectedRating = 'Puas';

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umpan Balik & Saran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mahasiswa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Bagaimana penilaian Anda terhadap materi praktikum ini?'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRating,
                items: ['Sangat Puas', 'Puas', 'Cukup'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRating = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Komentar / Saran (Minimal 5 karakter)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar tidak boleh kosong';
                  }
                  if (value.trim().length < 5) {
                    return 'Komentar minimal harus 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

             SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text('Apakah Anda yakin ingin mengirim umpan balik ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Terima kasih! Umpan balik berhasil dikirim.'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  _feedbackController.clear();
                                },
                                child: const Text('Kirim'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Kirim Umpan Balik'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
   return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profil.jpg'),
          ),
          const SizedBox(height: 16),
          Text(
            studentName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'NIM: $studentId',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text('Email Mahasiswa'),
            subtitle: Text('2415051055@student.undiksha.ac.id'),
          ),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Program Studi'),
            subtitle: Text('Pendidikan Teknik Informatika'),
          ),
        ],
      ),
    );
  }
}