import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/student_model.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper dbHelper = DBHelper._();

  static const table = 'student';
  static const colId = 'id';
  static const colName = 'name';
  static const colAge = 'age';
  static const colCity = 'city';
  // static const colImage = 'image';

  Database? db;

  Future<Database?> initDB() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'student.db');

   if(db != null) {
     return db;
   }
   else{
     db = await openDatabase(
       path,
       version: 1,
       onCreate: (Database db, int version) {
         String query =
             "CREATE TABLE IF NOT EXISTS $table($colId INTEGER PRIMARY KEY AUTOINCREMENT , $colName TEXT , $colAge INTEGER , $colCity TEXT)";
         return db.execute(query);
       },
     );
    return db;
   }
  }

  Future<int> insert (Student data) async {
    db = await initDB();

    String query = "INSERT INTO $table($colName, $colCity , $colAge) VALUES(?, ?, ?)";

    List args = [
      data.name,
      data.city,
      data.age,
      // data.image,
    ];
    return await db!.rawInsert(query , args);
  }

  Future<List<Student>> fetchAllData() async {
    db = await initDB();

    String query = "SELECT * FROM $table";

    List response = await db!.rawQuery(query);

    return response.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> delete(int? id) async {
    await initDB();

    String query = "DELETE FROM $table WHERE id = ?";
    List args = [id];
    return await db!.rawDelete(query,args);
  }

  Future<int> update(Student s, int? id) async {
    db = await initDB();

    String query = "UPDATE $table SET name = ?, city = ?, age = ?WHERE id = ?";
    List args = [s.name, s.city, s.age, id];

    return await db!.rawUpdate(query,args);
  }

  Future<List<Student>> fetchSearchedData (String val) async {
    db = await initDB();

    String query = "SELECT * FROM $table WHERE name LIKE '%$val%'";

    List response = await db!.rawQuery(query);

    return response.map((e) => Student.fromMap(e)).toList();
  }
}
