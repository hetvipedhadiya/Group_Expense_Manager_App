import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grocery/repositories/person_repository.dart';
import 'package:grocery/repositories/transaction_repository.dart';
import 'package:grocery/TransactionForm.dart';
import 'package:grocery/design_system.dart';
import 'package:animate_do/animate_do.dart';

class TransactionList extends StatefulWidget {
  final int eventId;
  final String eventName;
  const TransactionList({super.key, required this.eventId, required this.eventName});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  Future<List<dynamic>>? _transactionFuture;
  List<dynamic> _personsFuture = [];
  bool _isViewAll = false;

  @override
  void initState() {
    super.initState();
    _fetchEventWisePersons();
    _refreshTransactions();
  }

  Future<void> _fetchEventWisePersons() async {
    var persons = await PersonRepository().getPersonsByEvent(widget.eventId);
    if (mounted) {
      setState(() {
        _personsFuture = persons;
      });
    }
  }

  void _refreshTransactions() {
    setState(() {
      _transactionFuture = TransactionRepository().getTransactionByEvent(widget.eventId);
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
          future: _transactionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final transactions = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                if (!_isViewAll) ...[
                  FadeInDown(child: _buildBalanceSection(transactions)),
                  const SizedBox(height: 40),
                ],
                FadeInLeft(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_isViewAll ? "Full History" : "Recent Transactions", 
                          style: DesignSystem.displayMedium.copyWith(fontSize: 20)),
                        TextButton(
                          onPressed: () => setState(() => _isViewAll = !_isViewAll),
                          child: Text(_isViewAll ? "Show Less" : "View All", 
                            style: const TextStyle(color: DesignSystem.accent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...(_isViewAll ? transactions : transactions.take(3)).toList().asMap().entries.map((entry) {
                  int index = entry.key;
                  var tx = entry.value;
                  return FadeInUp(
                    delay: const Duration(milliseconds: 0),
                    child: _buildTransactionCard(tx),
                  );
                }),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddTransaction(),
          backgroundColor: DesignSystem.primary,
          elevation: 8,
          icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
          label: const Text("Add Transaction", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: DesignSystem.softShadow),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 64, color: DesignSystem.outline),
          ),
          const SizedBox(height: 48),
          Text("No Transactions Found", style: DesignSystem.displayMedium.copyWith(fontSize: 20)),
          const SizedBox(height: 64),
          ElevatedButton(
            onPressed: _navigateToAddTransaction,
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            child: const Text("Add Transaction"),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(List<dynamic> transactions) {
    double totalIncome = transactions
        .where((t) => t['transactionType'] == "credit")
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    double totalExpense = transactions
        .where((t) => t['transactionType'] == "debit")
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    double balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: DesignSystem.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: DesignSystem.premiumShadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignSystem.primary,
            DesignSystem.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Text("BALANCE", style: DesignSystem.labelMedium.copyWith(color: Colors.white70, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(
            "₹${NumberFormat("#,##0", "en_IN").format(balance)}",
            style: DesignSystem.displayLarge.copyWith(color: Colors.white, fontSize: 36),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _balanceInfo("Income", totalIncome, Colors.greenAccent),
                Container(width: 1, height: 40, color: Colors.white10),
                _balanceInfo("Expense", totalExpense, Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceInfo(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: DesignSystem.labelMedium.copyWith(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(
          "₹${NumberFormat("#,##0", "en_IN").format(amount)}",
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic tx) {
    bool isCredit = tx['transactionType'] == 'credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.primary.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActionSheet(tx),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isCredit ? Colors.green : Colors.red).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                    color: isCredit ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['userName'], style: DesignSystem.titleLarge.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.parse(tx['transactionDate'])),
                        style: DesignSystem.labelMedium.copyWith(color: DesignSystem.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isCredit ? '+' : '-'} ₹${NumberFormat("#,##0", "en_IN").format(tx['amount'])}",
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransaction() {
    if (_personsFuture.isEmpty) {
      _showSnackBar("Please add a member first.");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionForm(eventID: widget.eventId, eventName: widget.eventName, map: null),
      ),
    ).then((value) {
      if (value == true) {
        _refreshTransactions();
        _showSnackBar("Transaction added.");
      }
    });
  }

  void _showActionSheet(dynamic tx) {
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
              leading: const Icon(Icons.edit_note_rounded, color: DesignSystem.primary),
              title: const Text("Edit Transaction"),
              onTap: () async {
                Navigator.pop(context);
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionForm(eventID: widget.eventId, eventName: widget.eventName, map: tx)),
                );
                if (result == true) _refreshTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: DesignSystem.tertiary),
              title: const Text("Delete Transaction", style: TextStyle(color: DesignSystem.tertiary)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(tx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction?"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool deleted = await TransactionRepository().deleteTransaction(tx['expenseID']);
              if (deleted) {
                _refreshTransactions();
                _showSnackBar("Transaction deleted.");
              }
            },
            child: const Text("Delete Transaction", style: TextStyle(color: DesignSystem.tertiary)),
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
