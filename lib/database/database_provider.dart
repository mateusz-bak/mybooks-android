import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Instruction how to add a new database field:
// 1. Add new parameters to the Book class in book.dart
// 2. Increase version number in the createDatabase method below
// 3. Add new fields to the booksTable in the onCreate argument below
// 4. Add a new case to the onUpgrade argument below
// 5. Add a new list of migration scripts to the migrationScriptsVx
// 6. Add a new method _updateBookDatabaseVytoVx
// 7. Update existing methods with new migration scripts
// 7. Update existing methods names with new version number

// book_type actually represents book's format

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();

    String path = join(
      docDirectory.path,
      "Books.db",
    );

    return await openDatabase(
      path,
      version: 7,
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE booksTable ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT, "
            "subtitle TEXT, "
            "author TEXT, "
            "description TEXT, "
            "book_type TEXT, "
            "status INTEGER, "
            "rating INTEGER, "
            "favourite INTEGER, "
            "deleted INTEGER, "
            "start_dates TEXT, "
            "finish_dates TEXT, "
            "pages INTEGER, "
            "publication_year INTEGER, "
            "isbn TEXT, "
            "olid TEXT, "
            "tags TEXT, "
            "my_review TEXT, "
            "notes TEXT, "
            "has_cover INTEGER, "
            "cover BLOB, "
            "blur_hash TEXT, "
            "reading_times TEXT"
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (newVersion > oldVersion) {
          var batch = db.batch();

          switch (oldVersion) {
            case 1:
              _updateBookDatabaseV1toV7(batch);
              break;
            case 2:
              _updateBookDatabaseV2toV7(batch);
              break;
            case 3:
              _updateBookDatabaseV3toV7(batch);
              break;
            case 4:
              _updateBookDatabaseV4toV7(batch);
              break;
            case 5:
              _updateBookDatabaseV5toV7(batch);
              break;
            case 6:
              _updateBookDatabaseV6toV7(batch);
              break;
          }

          await batch.commit();
        }
      },
    );
  }

  void _executeBatch(Batch batch, List<String> scripts) {
    for (var script in scripts) {
      batch.execute(script);
    }
  }

  final migrationScriptsV2 = [
    "ALTER TABLE booksTable ADD description TEXT",
  ];

  final migrationScriptsV3 = [
    "ALTER TABLE booksTable ADD book_type TEXT",
  ];

  final migrationScriptsV4 = [
    "ALTER TABLE booksTable ADD has_cover INTEGER DEFAULT 0",
  ];

  final migrationScriptsV5 = [
    "ALTER TABLE booksTable ADD notes TEXT",
  ];

  final migrationScriptsV6 = [
    "ALTER TABLE booksTable ADD reading_time INTEGER",
  ];

  final migrationScriptsV7 = [
    // reading_times is now text s it can handle a list
    "ALTER TABLE booksTable ADD reading_times TEXT",
    "UPDATE booksTable SET reading_times = reading_time",
    "ALTER TABLE booksTable DROP COLUMN reading_time",
    // just column name change
    "ALTER TABLE booksTable ADD start_dates TEXT",
    "UPDATE booksTable SET start_dates = start_date",
    "ALTER TABLE booksTable DROP COLUMN start_date",
    // just column name change
    "ALTER TABLE booksTable ADD finish_dates TEXT",
    "UPDATE booksTable SET finish_dates = finish_date",
    "ALTER TABLE booksTable DROP COLUMN finish_date",
  ];

  void _updateBookDatabaseV1toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV2 +
          migrationScriptsV3 +
          migrationScriptsV4 +
          migrationScriptsV5 +
          migrationScriptsV6 +
          migrationScriptsV7,
    );
  }

  void _updateBookDatabaseV2toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV3 +
          migrationScriptsV4 +
          migrationScriptsV5 +
          migrationScriptsV6 +
          migrationScriptsV7,
    );
  }

  void _updateBookDatabaseV3toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV4 +
          migrationScriptsV5 +
          migrationScriptsV6 +
          migrationScriptsV7,
    );
  }

  void _updateBookDatabaseV4toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV5 + migrationScriptsV6 + migrationScriptsV7,
    );
  }

  void _updateBookDatabaseV5toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV6 + migrationScriptsV7,
    );
  }

  void _updateBookDatabaseV6toV7(Batch batch) {
    _executeBatch(
      batch,
      migrationScriptsV7,
    );
  }
}
