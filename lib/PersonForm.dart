import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/Models/PersonModel.dart';
import 'package:grocery/repositories/person_repository.dart';
import 'package:grocery/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';

class PersonForm extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  const PersonForm({super.key, this.map, required this.eventName, required this.eventID});

  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  String? _imagePath;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.map != null) {
      _userNameController.text = widget.map!['userName'] ?? '';
      _imagePath = widget.map!['UserImage']?.toString();
    }
  }

  Future<void> _pickImage() async {
    final XFile? selection = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Image", style: DesignSystem.displayMedium.copyWith(fontSize: 18)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: DesignSystem.primary),
                title: const Text("Camera"),
                onTap: () async => Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera, imageQuality: 50)),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: DesignSystem.primary),
                title: const Text("Gallery"),
                onTap: () async => Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50)),
              ),
            ],
          ),
        ),
      ),
    );

    if (selection != null) {
      setState(() {
        _imagePath = selection.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.map == null ? 'Add Member' : 'Update Member', 
          style: DesignSystem.titleLarge.copyWith(color: DesignSystem.textPrimary)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: DesignSystem.cardBorderRadius,
                  boxShadow: DesignSystem.premiumShadow,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: DesignSystem.background,
                                shape: BoxShape.circle,
                                border: Border.all(color: DesignSystem.primary.withOpacity(0.1), width: 4),
                                boxShadow: DesignSystem.softShadow,
                                image: _imagePath != null && _imagePath!.isNotEmpty
                                    ? DecorationImage(
                                        image: FileImage(File(_imagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _imagePath == null || _imagePath!.isEmpty
                                  ? const Icon(Icons.person_add_rounded, size: 48, color: DesignSystem.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: DesignSystem.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: TextFormField(
                          controller: _userNameController,
                          style: DesignSystem.bodyLarge,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: "Enter Name",
                            prefixIcon: const Icon(Icons.badge_rounded, color: DesignSystem.primary),
                            filled: true,
                            fillColor: DesignSystem.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Name is required";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _addOrUpdateUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(widget.map != null ? "Save Member" : "Add Member", 
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel", style: DesignSystem.labelMedium.copyWith(color: DesignSystem.tertiary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _addOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      PersonModel personModel = PersonModel(
        userID: widget.map?['userID'],
        userName: _userNameController.text.trim(),
        eventID: widget.eventID,
        userImage: _imagePath,
      );

      bool isSuccess;
      if (widget.map != null) {
        isSuccess = await PersonRepository().updateUser(personModel, widget.map!['userID']);
      } else {
        isSuccess = await PersonRepository().insertUser(personModel);
      }

      if (isSuccess && mounted) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar("System encountered an error during recording.");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: DesignSystem.primary),
    );
  }
}