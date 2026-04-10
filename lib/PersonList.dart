import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/repositories/event_repository.dart';
import 'package:grocery/PersonForm.dart';
import 'package:grocery/repositories/person_repository.dart';
import 'package:grocery/design_system.dart';
import 'package:animate_do/animate_do.dart';

class PersonList extends StatefulWidget {
  final int eventId;
  final String eventName;

  const PersonList({super.key, required this.eventId, required this.eventName});

  @override
  State<PersonList> createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  late Future<List<dynamic>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPersons();
  }

  void _refreshPersons() {
    setState(() {
      _personsFuture = EventRepository().getById(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DesignSystem.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _personsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final persons = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: persons.length,
              itemBuilder: (context, index) {
                return FadeInLeft(
                  delay: Duration(milliseconds: 100 * (index % 10)),
                  child: _buildPersonProfessionalCard(persons[index]),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddPerson(),
          backgroundColor: DesignSystem.primary,
          elevation: 8,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text("Add Member", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: DesignSystem.softShadow),
            child: const Icon(Icons.group_off_rounded, size: 64, color: DesignSystem.outline),
          ),
          const SizedBox(height: 48),
          Text("No Members Found", style: DesignSystem.displayMedium.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Text("Add members to track expenses for this event.", style: DesignSystem.bodyMedium),
          const SizedBox(height: 64),
          ElevatedButton(
            onPressed: _navigateToAddPerson,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary, 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text("Add Member"),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonProfessionalCard(dynamic person) {
    String? imagePath = person['UserImage']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.primary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActionSheet(person),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Premium Sapphire Avatar Frame
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [DesignSystem.primary.withOpacity(0.5), DesignSystem.primary.withOpacity(0.1)],
                    ),
                  ),
                  child: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: DesignSystem.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()
                          ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imagePath == null || imagePath.isEmpty || !File(imagePath).existsSync()
                        ? const Icon(Icons.person_outline_rounded, color: DesignSystem.primary, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person['userName'] ?? 'Unknown User',
                        style: DesignSystem.titleLarge.copyWith(fontSize: 18, letterSpacing: -0.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "MEMBER",
                          style: DesignSystem.labelMedium.copyWith(fontSize: 8, color: DesignSystem.primary, letterSpacing: 1.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_mosaic_rounded, color: DesignSystem.primary, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddPerson() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonForm(eventID: widget.eventId, eventName: widget.eventName)),
    );
    if (result == true) {
      _refreshPersons();
      _showSnackBar("Member added successfully.");
    }
  }

  void _showActionSheet(dynamic person) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 32), decoration: BoxDecoration(color: DesignSystem.outline, borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.manage_accounts_rounded, color: DesignSystem.primary),
              title: const Text("Update Member", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonForm(eventID: widget.eventId, eventName: widget.eventName, map: person)),
                );
                if (result == true) _refreshPersons();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off_rounded, color: DesignSystem.tertiary),
              title: const Text("Delete Member", style: TextStyle(color: DesignSystem.tertiary, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(person);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Member?"),
        content: const Text("Are you sure you want to delete this member?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool deleted = await PersonRepository().deleteUser(person['userID']);
              if (deleted) {
                _refreshPersons();
                _showSnackBar("Member deleted successfully.");
              }
            },
            child: const Text("Delete Member", style: TextStyle(color: DesignSystem.tertiary)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: DesignSystem.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}
