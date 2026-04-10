import 'package:flutter/material.dart';
import 'package:grocery/PersonList.dart';
import 'package:grocery/TransactionList.dart';
import 'package:grocery/design_system.dart';
import 'package:grocery/services/expense_service.dart';
import 'package:grocery/ReportScreen.dart';
import 'package:grocery/repositories/transaction_repository.dart';
import 'package:grocery/savePDF.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseList extends StatefulWidget {
  final String eventName;
  final int eventId;

  const ExpenseList({super.key, required this.eventName, required this.eventId});

  @override
  State<ExpenseList> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseList> {
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _reportMemberData = [];
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final overall = await ExpenseService().getOverallReport(widget.eventId);
      final members = await ExpenseService().getMemberReport(widget.eventId);
      final txs = await TransactionRepository().getTransactionByEvent(widget.eventId);

      setState(() {
        _reportData = overall;
        _reportMemberData = members;
        _transactions = txs;
      });
    } catch (e) {
      debugPrint("Error fetching detail data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: DesignSystem.background,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: DesignSystem.primary),
          title: Text(widget.eventName, style: DesignSystem.headlineSmall),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: DesignSystem.primary),
              onPressed: () => _handlePdfGeneration(),
            ),
          ],
          bottom: TabBar(
            labelColor: DesignSystem.primary,
            unselectedLabelColor: DesignSystem.textSecondary,
            indicatorColor: DesignSystem.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: DesignSystem.labelMedium.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: DesignSystem.labelMedium,
            tabs: const [
              Tab(text: "PEOPLE"),
              Tab(text: "HISTORY"),
              Tab(text: "INSIGHTS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PersonList(eventName: widget.eventName, eventId: widget.eventId),
            TransactionList(eventName: widget.eventName, eventId: widget.eventId),
            ReportScreen(eventId: widget.eventId, eventName: widget.eventName),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePdfGeneration() async {
    try {
      await _fetchData();

      if (_reportData.isNotEmpty && _reportMemberData.isNotEmpty) {
        final pdfFile = await PdfReportAPI().generateReportPdf(
          reportData: _reportData,
          reportMemberData: _reportMemberData,
          transactions: _transactions,
        );

        SaveAndOpenDirectory.openPdf(pdfFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Report generated: ${pdfFile.path.split('/').last}", style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: DesignSystem.primary,
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data available to generate PDF')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: DesignSystem.tertiary),
        );
      }
    }
  }
}

class PdfReportAPI {
  Future<File> generateReportPdf({
    required Map<String, dynamic> reportData,
    required List<Map<String, dynamic>> reportMemberData,
    required List<dynamic> transactions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Event Report: Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildSummaryCard(reportData),
          pw.SizedBox(height: 20),
          pw.Text('Transactions', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 20),
          pw.Text('Member Details', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          _buildTable(reportMemberData),
        ],
      ),
    );

    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }

    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      downloadsDir = await getExternalStorageDirectory();
    }

    final filePath = '${downloadsDir!.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildTransactionTable(List<dynamic> transactions) {
    final data = transactions.map((tx) {
      final isCredit = tx['transactionType'] == 'credit';
      final amount = (tx['amount'] as num).toDouble();
      final date = tx['transactionDate'].toString().split('T')[0];

      return [
        tx['userName'],
        date,
        isCredit ? 'Credit' : 'Debit',
        '${amount.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Name', 'Date', 'Type', 'Amount'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 14),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildSummaryCard(Map<String, dynamic> reportData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _summaryRow("Total Members:", reportData['totalMembers'].toString()),
          _summaryRow("Total Income:", reportData['totalIncome'].toString()),
          _summaryRow("Total Expense:", reportData['totalExpense'].toString()),
          _summaryRow("Expense Per Head:", reportData['expensePerHead'].toStringAsFixed(2)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> reportMemberData) {
    return pw.Table.fromTextArray(
      headers: ['Member', 'Income', 'Expense', 'Remaining'],
      data: reportMemberData.map((row) {
        final income = (row['income'] ?? 0).toDouble();
        final expense = (row['expense'] ?? 0).toDouble();
        final remaining = income - expense;

        return [
          row['member'].toString(),
          income.toStringAsFixed(2),
          expense.toStringAsFixed(2),
          remaining.toStringAsFixed(2),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 16),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
      ],
    );
  }
}
