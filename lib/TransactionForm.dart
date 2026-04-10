import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/Models/TransactionModel.dart';
import 'package:grocery/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';
import 'package:grocery/design_system.dart';
import 'package:animate_do/animate_do.dart';

class TransactionForm extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic>? map;
  final int eventID;

  const TransactionForm({super.key, this.map, required this.eventName, required this.eventID});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String transactionType = "debit";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  bool isLoading = false;
  String? selectedUser;
  int? selectedUserID;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    if (widget.map != null) {
      _amountController.text = widget.map!['amount'].toString();
      transactionType = widget.map!['transactionType'].toString().toLowerCase();
      _descriptionController.text = widget.map!['description'] ?? '';
      selectedUserID = widget.map!['userID'];
      selectedUser = selectedUserID?.toString();
    }
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final List<dynamic> fetchedUsers = await TransactionRepository().getUserDropdown(widget.eventID);
      setState(() => users = fetchedUsers);
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  Future<void> _addOrUpdateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      TransactionModel transModel = TransactionModel(
        expenseID: widget.map?['expenseID'] != null ? int.tryParse(widget.map!['expenseID'].toString()) : null,
        userID: selectedUserID ?? 0,
        eventID: widget.eventID,
        Amount: double.parse(_amountController.text),
        transactionDate: _selectedDate ?? DateTime.now(),
        transactionType: transactionType.toLowerCase(),
        description: _descriptionController.text.isEmpty ? "No Description" : _descriptionController.text,
      );

      bool isSuccess = widget.map != null
          ? await TransactionRepository().updateTransaction(transModel, widget.map!['expenseID'])
          : await TransactionRepository().insertTransaction(transModel);

      if (isSuccess && mounted) {
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar("Ledger update failed.");
      }
    } catch (error) {
      _showSnackBar("Error: $error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: DesignSystem.primary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: Text(widget.map == null ? 'Add Transaction' : 'Update Transaction', style: DesignSystem.titleLarge),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DesignSystem.primary.withOpacity(0.05), Colors.white],
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
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: DesignSystem.premiumShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeToggle(),
                        const SizedBox(height: 40),
                        
                        Text("MEMBER", style: DesignSystem.labelMedium.copyWith(letterSpacing: 1.5, fontSize: 10)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedUser,
                          onChanged: (newValue) {
                            setState(() {
                              selectedUser = newValue;
                              selectedUserID = int.tryParse(newValue!);
                            });
                          },
                          items: users.map((user) {
                            String? userImage = user['UserImage']?.toString();
                            return DropdownMenuItem<String>(
                              value: user['userID'].toString(),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: DesignSystem.background,
                                    backgroundImage: userImage != null && userImage.isNotEmpty && File(userImage).existsSync()
                                        ? FileImage(File(userImage))
                                        : null,
                                    child: userImage == null || userImage.isEmpty || !File(userImage).existsSync()
                                        ? const Icon(Icons.person, size: 14, color: DesignSystem.primary)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(user['userName'].toString(), style: DesignSystem.bodyLarge),
                                ],
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: DesignSystem.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.group_work_rounded, color: DesignSystem.primary),
                          ),
                          validator: (v) => v == null ? 'Member required' : null,
                        ),
                        
                        const SizedBox(height: 24),
                        Text("AMOUNT", style: DesignSystem.labelMedium.copyWith(letterSpacing: 1.5, fontSize: 10)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: DesignSystem.displayMedium.copyWith(fontSize: 24, color: DesignSystem.primary),
                          decoration: InputDecoration(
                            hintText: "0.00",
                            prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: DesignSystem.primary),
                            filled: true,
                            fillColor: DesignSystem.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Amount required' : null,
                        ),
                        
                        const SizedBox(height: 24),
                        Text("DATE", style: DesignSystem.labelMedium.copyWith(letterSpacing: 1.5, fontSize: 10)),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              color: DesignSystem.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: DesignSystem.primary),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate == null ? 'Select Date' : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                                  style: DesignSystem.bodyLarge,
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right_rounded, color: DesignSystem.outline),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text("DESCRIPTION", style: DesignSystem.labelMedium.copyWith(letterSpacing: 1.5, fontSize: 10)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Details...",
                            prefixIcon: const Icon(Icons.notes_rounded, color: DesignSystem.primary),
                            filled: true,
                            fillColor: DesignSystem.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        FadeInUp(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _addOrUpdateTransaction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                              ),
                              child: isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(widget.map != null ? "Save Transaction" : "Add Transaction", 
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Center(child: Text("Cancel", style: TextStyle(color: DesignSystem.tertiary.withOpacity(0.7)))),
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

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: DesignSystem.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleButton("EXPENSE", "debit", Colors.red)),
          Expanded(child: _toggleButton("INCOME", "credit", Colors.green)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, String type, Color activeColor) {
    bool isSelected = transactionType == type;
    return GestureDetector(
      onTap: () => setState(() => transactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : DesignSystem.textSecondary.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: DesignSystem.primary),
    );
  }
}