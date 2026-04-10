import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grocery/design_system.dart';
import 'package:grocery/services/expense_service.dart';
import 'package:grocery/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  const ReportScreen({super.key, required this.eventId, required this.eventName});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final report = await ExpenseService().getOverallReport(widget.eventId);
      final members = await ExpenseService().getMemberReport(widget.eventId);
      final txs = await TransactionRepository().getTransactionByEvent(widget.eventId);

      setState(() {
        _reportData = report;
        _reportMemberData = members;
        _transactions = txs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading report: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: DesignSystem.backgroundSoft,
        child: const Center(child: CircularProgressIndicator(color: DesignSystem.accent)),
      );
    }

    return Scaffold(
      backgroundColor: DesignSystem.backgroundSoft,

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSection(),
              const SizedBox(height: 24),
              _buildSummaryCards(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent History", style: DesignSystem.titleLarge),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All", style: DesignSystem.labelMedium.copyWith(color: DesignSystem.accent)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTransactionList(),
              const SizedBox(height: 32),
              Text("Member Report", style: DesignSystem.titleLarge),
              const SizedBox(height: 16),
              _buildMemberDetailedTable(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    double totalIncome = (_reportData['totalIncome'] ?? 0).toDouble();
    double totalExpense = (_reportData['totalExpense'] ?? 0).toDouble();
    double remaining = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignSystem.cardBorderRadius,
        boxShadow: DesignSystem.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Overview", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: DesignSystem.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: DesignSystem.caption.copyWith(color: DesignSystem.accent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 6,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: DesignSystem.income,
                        value: totalIncome > 0 ? totalIncome : 1,
                        radius: 20,
                        showTitle: false,
                        badgeWidget: _badgeIcon(Icons.arrow_upward, DesignSystem.income),
                        badgePositionPercentageOffset: 1.1,
                      ),
                      PieChartSectionData(
                        color: DesignSystem.expense,
                        value: totalExpense > 0 ? totalExpense : 0,
                        radius: 25,
                        showTitle: false,
                        badgeWidget: _badgeIcon(Icons.arrow_downward, DesignSystem.expense),
                        badgePositionPercentageOffset: 1.1,
                      ),
                      if (remaining > 0)
                        PieChartSectionData(
                          color: DesignSystem.primary.withOpacity(0.2),
                          value: remaining,
                          radius: 15,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("BALANCE", style: DesignSystem.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      "₹${NumberFormat("#,##,##0", "en_IN").format(remaining)}",
                      style: DesignSystem.headlineSmall.copyWith(
                        color: remaining >= 0 ? DesignSystem.income : DesignSystem.expense,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _chartLegend("Income", DesignSystem.income),
              _chartLegend("Expense", DesignSystem.expense),
              _chartLegend("Savings", DesignSystem.primary.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: DesignSystem.softShadow,
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: DesignSystem.bodyMedium.copyWith(fontSize: 13)),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryBox(
            "Total Income",
            _reportData['totalIncome'] ?? 0,
            DesignSystem.income,
            Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryBox(
            "Total Expense",
            _reportData['totalExpense'] ?? 0,
            DesignSystem.expense,
            Icons.shopping_cart_outlined,
          ),
        ),
      ],
    );
  }

  Widget _summaryBox(String label, num value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignSystem.cardBorderRadius,
        boxShadow: DesignSystem.softShadow,
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(label, style: DesignSystem.caption),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "₹${NumberFormat("#,##,##0", "en_IN").format(value)}",
              style: TextStyle(color: DesignSystem.primary, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("No transactions yet", style: DesignSystem.bodyMedium),
        ),
      );
    }

    return Column(
      children: _transactions.take(5).map((tx) {
        bool isCredit = tx['transactionType'] == 'credit';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isCredit ? DesignSystem.income : DesignSystem.expense).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.add_rounded : Icons.remove_rounded,
                color: isCredit ? DesignSystem.income : DesignSystem.expense,
                size: 20,
              ),
            ),
            title: Text(tx['userName'], style: DesignSystem.titleLarge.copyWith(fontSize: 16)),
            subtitle: Text(
              DateFormat('dd MMM, yyyy').format(DateTime.parse(tx['transactionDate'])),
              style: DesignSystem.caption,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isCredit ? '+' : '-'} ₹${NumberFormat("#,##,##0", "en_IN").format(tx['amount'])}",
                  style: TextStyle(
                    color: isCredit ? DesignSystem.income : DesignSystem.expense,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isCredit ? "Income" : "Expense",
                  style: DesignSystem.caption.copyWith(fontSize: 10, color: isCredit ? DesignSystem.income : DesignSystem.expense),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMemberDetailedTable() {
    if (_reportMemberData.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: DesignSystem.cardBorderRadius,
        boxShadow: DesignSystem.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2.5),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.03)),
            children: [
              _tableHeader("Member"),
              _tableHeader("Income"),
              _tableHeader("Expense"),
              _tableHeader("Balance"),
            ],
          ),
          // Data Rows
          ..._reportMemberData.map((row) {
            final income = (row['income'] ?? 0).toDouble();
            final expense = (row['expense'] ?? 0).toDouble();
            final balance = income - expense;

            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: DesignSystem.outlineVariant, width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(row['member'], style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("₹${income.toStringAsFixed(0)}", style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.income)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("₹${expense.toStringAsFixed(0)}", style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.expense)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "₹${balance.toStringAsFixed(0)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: balance >= 0 ? DesignSystem.income : DesignSystem.expense,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: DesignSystem.labelMedium.copyWith(color: DesignSystem.textSecondary, fontWeight: FontWeight.w800),
      ),
    );
  }
}