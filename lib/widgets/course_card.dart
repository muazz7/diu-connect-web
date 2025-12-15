import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;
  final bool isGrid;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin handled by parent Grid/List builder usually, but we keep it safe for List
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isGrid
                ? _buildGridContent(context)
                : _buildListContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildListContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildTags(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTeacherRow(context),
      ],
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(context),
        const SizedBox(height: 16),
        Text(
          course['name'],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
        _buildTags(),
        const Spacer(),
        _buildTeacherRow(context, centered: true),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.school_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: isGrid ? 32 : 24,
      ),
    );
  }

  Widget _buildTags() {
    final sections = course['sections'] as List<dynamic>?;
    final semester = (sections != null && sections.isNotEmpty)
        ? sections[0]['semester']
        : 'Unknown'; // Fallback if not found

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBadge(course['code']),
        const SizedBox(width: 8),
        _buildBadge(semester),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTeacherRow(BuildContext context, {bool centered = false}) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.person, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            course['teacher']?['name'] ?? 'Unknown Teacher',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
