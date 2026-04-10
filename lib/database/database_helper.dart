import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('group_expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );

    // Ensure default offline host exists to prevent foreign key constraint failures
    try {
      await db.execute("INSERT OR IGNORE INTO hosts (hostId, email, password, mobileNo, isActive) VALUES (1, 'offline@local', 'offline', '0000000000', 1)");
    } catch (e) {
      print("Warning: Could not create default offline host: $e");
    }

    return db;
  }

  Future _onConfigure(Database db) async {
    // Add support for foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // 1. hosts table (Users for auth)
    await db.execute('''
CREATE TABLE hosts (
  hostId $idType,
  email $textType,
  password $textType,
  mobileNo $textType,
  createAt $textNullableType,
  isActive $boolType
)
''');

    // 2. events table
    await db.execute('''
CREATE TABLE events (
  eventID $idType,
  eventName $textType,
  eventDate $textType,
  hostID $integerNullableType,
  created $textNullableType,
  modified $textNullableType,
  FOREIGN KEY (hostID) REFERENCES hosts (hostId) ON DELETE SET NULL
)
''');

    // 3. persons table (Users in an event)
    await db.execute('''
CREATE TABLE persons (
  userID $idType,
  userName $textType,
  eventID $integerNullableType,
  hostID $integerNullableType,
  UserImage $textNullableType,
  created $textNullableType,
  modified $textNullableType,
  FOREIGN KEY (eventID) REFERENCES events (eventID) ON DELETE CASCADE,
  FOREIGN KEY (hostID) REFERENCES hosts (hostId) ON DELETE SET NULL
)
''');

    // 4. transactions table
    // Note: We use 'ON DELETE CASCADE' for eventID to wipe all records when an event is deleted.
    // For userID, we use 'ON DELETE SET NULL' in schema, but handle full 'CASCADE' manually 
    // in the Repositories to ensure clean data removal during Person deletion.
    await db.execute('''
CREATE TABLE transactions (
  expenseID $idType,
  userID $integerNullableType,
  eventID $integerNullableType,
  hostId $integerNullableType,
  amount $realType,
  transactionDate $textType,
  transactionType $textType CHECK(transactionType IN ('credit', 'debit')),
  description $textNullableType,
  created $textNullableType,
  modified $textNullableType,
  FOREIGN KEY (userID) REFERENCES persons (userID) ON DELETE SET NULL,
  FOREIGN KEY (eventID) REFERENCES events (eventID) ON DELETE CASCADE,
  FOREIGN KEY (hostId) REFERENCES hosts (hostId) ON DELETE SET NULL
)
''');

    // 5. categories table (from original schema, not fully used in UI but keeping for completeness)
    await db.execute('''
CREATE TABLE categories (
  categoryID $idType,
  categoryName $textType,
  userID $integerNullableType,
  created $textNullableType,
  modified $textNullableType,
  FOREIGN KEY (userID) REFERENCES persons (userID) ON DELETE SET NULL
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
