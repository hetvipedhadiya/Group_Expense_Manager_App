import 'package:grocery/Models/InsertEventModel.dart';
import 'package:grocery/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final db = await _dbHelper.database;
      return await db.query('events');
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventsByHostId() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      
      // Calculate total expense for each event using a LEFT JOIN
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT e.*, IFNULL(SUM(t.amount), 0) as amount
        FROM events e
        LEFT JOIN transactions t ON e.eventID = t.eventID AND t.transactionType = 'debit'
        WHERE e.hostID = ?
        GROUP BY e.eventID
      ''', [hostId]);
      
      return result;
    } catch (error) {
      print("Error fetching events by host: $error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getById(dynamic eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      final db = await _dbHelper.database;
      // Corresponds to PR_User_SelectByEvent in SQL
      return await db.query(
        'persons',
        where: 'eventID = ? AND hostID = ?',
        whereArgs: [eventID, hostId],
      );
    } catch (error) {
      print("Error fetching event by ID: $error");
      return [];
    }
  }

  Future<bool> deleteEvent(dynamic eventID) async {
    try {
      final db = await _dbHelper.database;
      
      // BUG FIX: Manually handle full cascading deletion for an Event.
      // 1. First, wipe all transactions tied to this event.
      await db.delete(
        'transactions',
        where: 'eventID = ?',
        whereArgs: [eventID],
      );

      // 2. Next, delete all persons (members) assigned to this event.
      await db.delete(
        'persons',
        where: 'eventID = ?',
        whereArgs: [eventID],
      );

      // 3. Finally, delete the root Event record now that all child dependencies are cleared.
      int count = await db.delete(
        'events',
        where: 'eventID = ?',
        whereArgs: [eventID],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  Future<bool> insertEvent(Event event) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      event.hostID = hostId;
      
      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = event.toMap();
      row['created'] = DateTime.now().toIso8601String();
      
      int id = await db.insert('events', row);
      return id > 0;
    } catch (e) {
      print("Exception inserting event: $e");
      return false;
    }
  }

  Future<bool> updateEvent(Event event, dynamic eventID) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int? hostId = sp.getInt("hostID") ?? 1;

      event.hostID = hostId;
      event.eventID = eventID; // Ensure ID is set

      final db = await _dbHelper.database;
      
      Map<String, dynamic> row = event.toMap();
      row['modified'] = DateTime.now().toIso8601String();
      
      int count = await db.update(
        'events',
        row,
        where: 'eventID = ?',
        whereArgs: [eventID],
      );
      
      return count > 0;
    } catch (e) {
      print("Exception updating event: $e");
      return false;
    }
  }
}
