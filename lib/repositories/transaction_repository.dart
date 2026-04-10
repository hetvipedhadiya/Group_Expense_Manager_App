import 'package:grocery/Models/TransactionModel.dart';
import 'package:grocery/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<TransactionModel>> getAllTransaction() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('transactions');
      return maps.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      print("Error getting all transactions: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionByEvent(dynamic eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      
      // Corresponds to PR_Transactions_SelectAll / by-event with User JOIN
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT t.*, p.userName, e.eventName
        FROM transactions t
        LEFT JOIN persons p ON t.userID = p.userID
        LEFT JOIN events e ON t.eventID = e.eventID
        WHERE t.eventID = ? AND t.hostId = ?
      ''', [eventID, hostId]);
      
      // Make it modifiable list since we might want to change it (like the original code assigning empty strings)
      List<Map<String, dynamic>> modifiableResult = List<Map<String, dynamic>>.from(result);
      
      for (var item in modifiableResult) {
        // Since sqlite returns immutable maps from rawQuery, we need to create a new map to modify it
        Map<String, dynamic> modifiedItem = Map<String, dynamic>.from(item);
        modifiedItem['userName'] = modifiedItem['userName'] ?? '';
        modifiedItem['eventName'] = modifiedItem['eventName'] ?? '';
        modifiedItem['description'] = modifiedItem['description'] ?? '';
        modifiedItem['currency'] = 'USD';
        
        // Replace in list
        int index = modifiableResult.indexOf(item);
        modifiableResult[index] = modifiedItem;
      }
      
      return modifiableResult;
    } catch (e) {
      print("Error fetching transactions by event: $e");
      return [];
    }
  }

  Future<bool> insertTransaction(TransactionModel transaction) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      transaction.hostId = hostId;
      
      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = transaction.toMap();
      row['created'] = DateTime.now().toIso8601String();
      
      int id = await db.insert('transactions', row);
      return id > 0;
    } catch (e) {
      print("Exception inserting transaction: $e");
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction, int expenseID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      transaction.hostId = hostId;
      transaction.expenseID = expenseID;
      
      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = transaction.toMap();
      row['modified'] = DateTime.now().toIso8601String();
      
      int count = await db.update(
        'transactions',
        row,
        where: 'expenseID = ?',
        whereArgs: [expenseID],
      );
      return count > 0;
    } catch (e) {
      print("Exception updating transaction: $e");
      return false;
    }
  }

  Future<bool> deleteTransaction(int transactionID) async {
    try {
      final db = await _dbHelper.database;
      int count = await db.delete(
        'transactions',
        where: 'expenseID = ?',
        whereArgs: [transactionID],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception('Error deleting transaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserDropdown(int eventID) async {
    try {
      // In the original, this fetches users for dropdown in Transaction form
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      
      return await db.query(
        'persons',
        columns: ['userID', 'userName', 'eventID', 'UserImage'],
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
    } catch (e) {
      print("Error getting user dropdown: $e");
      return [];
    }
  }
}
