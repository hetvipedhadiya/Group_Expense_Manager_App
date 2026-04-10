import 'package:grocery/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getOverallReport(int eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      
      // Calculate overall stats matching SQL PR_Report_Generate
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT 
          COUNT(DISTINCT userID) as totalMembers,
          SUM(CASE WHEN transactionType = 'credit' THEN amount ELSE 0 END) as totalIncome,
          SUM(CASE WHEN transactionType = 'debit' THEN amount ELSE 0 END) as totalExpense
        FROM transactions
        WHERE eventID = ? AND hostId = ?
      ''', [eventID, hostId]);
      
      if (results.isEmpty) return {};
      
      var row = results.first;
      int totalMembers = row['totalMembers'] ?? 0;
      double totalIncome = (row['totalIncome'] ?? 0.0).toDouble();
      double totalExpense = (row['totalExpense'] ?? 0.0).toDouble();
      double expensePerHead = totalMembers > 0 ? totalExpense / totalMembers : 0.0;
      
      return {
        'totalMembers': totalMembers,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'expensePerHead': expensePerHead,
      };
    } catch (e) {
      print("Error getting overall report: $e");
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getMemberReport(int eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      
      // Calculate per member stats matching SQL PR_Report_Generate
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT 
          p.userName as member,
          SUM(CASE WHEN t.transactionType = 'credit' THEN t.amount ELSE 0 END) as income,
          SUM(CASE WHEN t.transactionType = 'debit' THEN t.amount ELSE 0 END) as expense
        FROM transactions t
        LEFT JOIN persons p ON t.userID = p.userID
        WHERE t.eventID = ? AND t.hostId = ?
        GROUP BY p.userName
      ''', [eventID, hostId]);
      
      // sqlite rawQuery returns immutable maps, converting to standard List<Map>
      return results.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print("Error getting member report: $e");
      return [];
    }
  }
}
