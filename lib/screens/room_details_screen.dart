import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../widgets/responsive_container.dart';

class RoomDetailsScreen extends StatefulWidget {
  final String sectionId;
  final String title;
  final Map<String, dynamic>? sectionData; // Optional, pass if available

  const RoomDetailsScreen({
    super.key,
    required this.sectionId,
    required this.title,
    this.sectionData,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  List<dynamic> _members = [];
  bool _isLoading = true;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    // Initialize isActive if passed, otherwise default true (or fetch? avoiding extra fetch for now)
    if (widget.sectionData != null) {
      _isActive = widget.sectionData!['isActive'] ?? true;
    }
  }

  Future<void> _fetchMembers() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/sections/${widget.sectionId}/members'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _members = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMember(String userId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.delete(
        Uri.parse(
            '${auth.baseUrl}/sections/${widget.sectionId}/members/$userId'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _members.removeWhere((m) => m['id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member removed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove member')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _endClass() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.patch(
        Uri.parse('${auth.baseUrl}/sections/${widget.sectionId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}'
        },
        body: jsonEncode({'isActive': false}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class ended successfully')),
        );
        // Navigate back to Dashboard? or just stay here?
        // Maybe pop until dashboard?
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final msg = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ?? response.body
            : 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode} - $msg')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _confirmRemove(String userId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeMember(userId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmEndClass() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Class'),
        content: const Text(
            'Are you sure you want to end this class? It will be moved to "Previous Courses".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endClass();
            },
            child: const Text('End Class', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;
    final isTeacher = role == 'TEACHER';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        centerTitle: true,
      ),
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Could show ChatRoomID/Password here if available
                      // Assuming we might pass them strictly if needed, but for now just title/status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isActive
                                ? Colors.green.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _isActive ? 'Active' : 'Ended',
                          style: TextStyle(
                            color: _isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Members (${_members.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _members.isEmpty
                        ? const Center(
                            child: Text('No members found',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: _members.length,
                            separatorBuilder: (ctx, i) => const Divider(),
                            itemBuilder: (ctx, i) {
                              final member = _members[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Text(
                                    member['name'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(member['name']),
                                subtitle: Text(member['email']),
                                trailing: isTeacher
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _confirmRemove(
                                            member['id'], member['name']),
                                      )
                                    : null,
                              );
                            },
                          ),
              ),
              if (isTeacher && _isActive) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmEndClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: const Text('End Class'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
