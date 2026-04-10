import 'package:grocery/Models/PersonModel.dart';
import 'package:grocery/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getPersonsByEvent(dynamic eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      return await db.query(
        'persons',
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
    } catch (e) {
      print("Error fetching persons by event: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPersonByHostId() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      return await db.query(
        'persons',
        where: 'hostID = ?',
        whereArgs: [hostId],
      );
    } catch (e) {
      print("Error fetching persons by host: $e");
      return [];
    }
  }

  Future<bool> insertUser(PersonModel personModel) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      personModel.hostID = hostId;
      
      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = personModel.toMap();
      row['created'] = DateTime.now().toIso8601String();
      
      int id = await db.insert('persons', row);
      return id > 0;
    } catch (e) {
      print("Exception inserting person: $e");
      return false;
    }
  }

  Future<bool> updateUser(PersonModel personModel, dynamic userID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      personModel.hostID = hostId;
      personModel.userID = userID;
      
      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = personModel.toMap();
      row['modified'] = DateTime.now().toIso8601String();
      
      int count = await db.update(
        'persons',
        row,
        where: 'userID = ?',
        whereArgs: [userID],
      );
      return count > 0;
    } catch (e) {
      print("Exception updating person: $e");
      return false;
    }
  }

  Future<bool> deleteUser(dynamic userID) async {
    try {
      final db = await _dbHelper.database;
      
      // BUG FIX: Manually handle cascading deletes for child records.
      // Before deleting the person, we must remove all transactions associated with them.
      // This prevents orphaned records in the 'transactions' table which caused calculation errors.
      await db.delete(
        'transactions',
        where: 'userID = ?',
        whereArgs: [userID],
      );

      // After clearing dependencies, safe to delete the person record.
      int count = await db.delete(
        'persons',
        where: 'userID = ?',
        whereArgs: [userID],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting person: $e');
      throw Exception('Error deleting person: $e');
    }
  }
}
