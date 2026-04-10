import 'package:flutter/material.dart';
import 'package:grocery/repositories/event_repository.dart';
import 'package:grocery/Models/InsertEventModel.dart';
import 'package:intl/intl.dart';
import 'package:grocery/design_system.dart';
import 'package:animate_do/animate_do.dart';

class EventForm  extends StatefulWidget {
  final Map<String, dynamic>? map;
  const EventForm({super.key, this.map});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final TextEditingController _eventNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  DateTime? _selectedDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    if (widget.map != null) {
      _eventNameController.text = widget.map!['eventName'].toString();
      _selectedDate = DateTime.tryParse(widget.map!['eventDate']) ?? DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.map == null ? 'Add Event' : 'Update Event', 
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInRight(
                        delay: const Duration(milliseconds: 200),
                        child: Text("Event Details", style: DesignSystem.displayMedium.copyWith(fontSize: 20)),
                      ),
                      const SizedBox(height: 8),
                      FadeInRight(
                        delay: const Duration(milliseconds: 300),
                        child: Text("Details for your expense tracking event.", style: DesignSystem.bodyMedium),
                      ),
                      const SizedBox(height: 48),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: TextFormField(
                          controller: _eventNameController,
                          style: DesignSystem.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Event Name',
                            hintText: 'e.g., Annual Trip',
                            prefixIcon: const Icon(Icons.event_note_rounded, color: DesignSystem.accent),
                            filled: true,
                            fillColor: DesignSystem.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            labelStyle: DesignSystem.labelMedium,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Please provide a valid title";
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              color: DesignSystem.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: DesignSystem.accent),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Event Date", style: DesignSystem.labelMedium),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedDate == null ? 'Select Event Date' : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                                        style: DesignSystem.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 64),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveEvent(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            child: const Text("Save Event", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: DesignSystem.labelMedium.copyWith(color: DesignSystem.tertiary)),
                          ),
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

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() => _dateError = "Required");
      return;
    }

    bool success;
    if (widget.map != null) {
      final event = Event(
        eventID: widget.map!['eventID'],
        eventName: _eventNameController.text,
        eventDate: _selectedDate!,
      );
      success = await EventRepository().updateEvent(event, widget.map!['eventID']);
    } else {
      final event = Event(
        eventName: _eventNameController.text,
        eventDate: _selectedDate!,
      );
      success = await EventRepository().insertEvent(event);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
