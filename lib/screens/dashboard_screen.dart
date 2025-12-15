import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import 'chat_screen.dart';
import '../widgets/course_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/courses'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _courses = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createCourse(String name, String code, String semester,
      String chatRoomId, String chatPassword) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}'
        },
        body: jsonEncode({
          'name': name,
          'code': code,
          'semester': semester,
          'chatRoomId': chatRoomId,
          'chatPassword': chatPassword
        }),
      );

      if (response.statusCode == 201) {
        _fetchCourses();
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully')),
        );
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Failed to create course';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _joinCourse(String chatRoomId, String chatPassword) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/enroll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}'
        },
        body: jsonEncode({
          'chatRoomId': chatRoomId,
          'chatPassword': chatPassword,
        }),
      );

      if (response.statusCode == 201) {
        _fetchCourses();
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined course successfully')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to join';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _showCreateCourseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final semesterController = TextEditingController();
    final chatRoomIdController = TextEditingController();
    final chatPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(labelText: 'Semester'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: chatRoomIdController,
                decoration: const InputDecoration(
                  labelText: 'Create Chat Room ID',
                  hintText: 'Unique ID for students to join',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: chatPasswordController,
                decoration: const InputDecoration(labelText: 'Create Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  codeController.text.isNotEmpty &&
                  chatRoomIdController.text.isNotEmpty &&
                  chatPasswordController.text.isNotEmpty) {
                _createCourse(
                  nameController.text,
                  codeController.text,
                  semesterController.text,
                  chatRoomIdController.text,
                  chatPasswordController.text,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    final chatRoomIdController = TextEditingController();
    final chatPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Chat Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chatRoomIdController,
              decoration: const InputDecoration(labelText: 'Chat Room ID'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: chatPasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (chatRoomIdController.text.isNotEmpty &&
                  chatPasswordController.text.isNotEmpty) {
                _joinCourse(
                  chatRoomIdController.text,
                  chatPasswordController.text,
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Image.asset(
              'assets/images/logo.png',
              height: 40,
              fit: BoxFit.contain,
              color: Colors
                  .white, // Tints the logo white to match previous text color, assuming logo is monotone/needs contrast on gradient
            ),
            centerTitle: true,
            floating: true,
            pinned: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(text: 'Ongoing'),
                Tab(text: 'Previous'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              )
            ],
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCourseList(ongoing: true),
            _buildCourseList(ongoing: false),
          ],
        ),
      ),
      floatingActionButton: role == 'TEACHER'
          ? FloatingActionButton.extended(
              onPressed: _showCreateCourseDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Course'),
            )
          : FloatingActionButton.extended(
              onPressed: _showJoinDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Join Room'),
            ),
    );
  }

  Widget _buildCourseList({required bool ongoing}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final filteredCourses = _courses.where((course) {
      final sections = course['sections'] as List<dynamic>?;
      if (sections == null || sections.isEmpty) return false;
      final isActive = sections[0]['isActive'] ?? true;
      return ongoing ? isActive : !isActive;
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ongoing ? Icons.school_rounded : Icons.history_edu_rounded,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              ongoing ? 'No active courses' : 'No previous courses',
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            if (ongoing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  Provider.of<AuthProvider>(context).role == 'TEACHER'
                      ? 'Tap + to create one'
                      : 'Tap "Join Room" to enroll',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth > 800;

        if (isGrid) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 1.0,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: filteredCourses.length,
            itemBuilder: (context, index) {
              final course = filteredCourses[index];
              return _buildCourseItem(context, course, isGrid: true);
            },
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCourses.length,
            itemBuilder: (context, index) {
              final course = filteredCourses[index];
              return _buildCourseItem(context, course, isGrid: false);
            },
          );
        }
      },
    );
  }

  Widget _buildCourseItem(BuildContext context, dynamic course,
      {required bool isGrid}) {
    final sectionId =
        (course['sections'] != null && course['sections'].isNotEmpty)
            ? course['sections'][0]['id']
            : null;

    return CourseCard(
      course: course,
      isGrid: isGrid,
      onTap: () {
        if (sectionId != null) {
          _showSections(sectionId, course['name']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active section for this course')),
          );
        }
      },
    );
  }

  void _showSections(String sectionId, String courseName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ChatScreen(sectionId: sectionId, title: courseName)),
    ).then((_) => _fetchCourses());
  }
}
