import 'package:grocery/Models/UserModel.dart';
import 'package:grocery/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> signUpUser(String email, String password, String confirmPassword, String mobileNo) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if user already exists
      final List<Map<String, dynamic>> existing = await db.query(
        'hosts',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existing.isNotEmpty) {
        print("SignUp Error: Email already exists");
        return false;
      }

      UserModel user = UserModel(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        mobileNo: mobileNo,
        createAt: DateTime.now().toIso8601String(),
        isActive: true,
      );

      final id = await db.insert(
        'hosts',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("SignUp Success, HostId: $id");
      return id > 0;
    } catch (e) {
      print("SignUp Error: $e");
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final db = await _dbHelper.database;
      
      final List<Map<String, dynamic>> users = await db.query(
        'hosts',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );

      if (users.isNotEmpty) {
        final userData = users.first;
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('userEmail', userData['email']);
        await prefs.setInt("hostID", userData['hostId']);
        await prefs.setBool('isLoggedIn', true);
        
        print("Login Success for HostId: ${userData['hostId']}");
        return true;
      } else {
        print("Login Error: Invalid credentials");
        return false;
      }
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }
}
