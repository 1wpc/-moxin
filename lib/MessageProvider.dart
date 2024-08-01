import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageProvider{
  late Database db;
  late QueryCursor cursor;

  Future open()async{
    db = await openDatabase(join(await getDatabasesPath(), "data.db"), version: 1,
        onCreate:(Database db, int version)async{
          await db.execute('''
          CREATE TABLE Messages1 (
    id VARCHAR(255) NOT NULL,
    author_id VARCHAR(255) NOT NULL,
    createdAt INT DEFAULT NULL,
    metadata TEXT DEFAULT NULL,
    previewData TEXT DEFAULT NULL,
    remoteId VARCHAR(255) DEFAULT NULL,
    repliedMessage VARCHAR(255) DEFAULT NULL,
    roomId VARCHAR(255) DEFAULT NULL,
    showStatus BOOLEAN DEFAULT NULL,
    status TEXT DEFAULT NULL,
    text TEXT NOT NULL,
    type TEXT DEFAULT 'text',
    updatedAt INT DEFAULT NULL,
    PRIMARY KEY (id)
);
          ''');
        }
        );
  }

  Future insert(types.TextMessage tmsg)async{
    var author_id = tmsg.author.id;
    var msg_map = tmsg.toJson();
    msg_map.remove("author");
    msg_map['author_id'] = author_id;
    await db.insert("Messages1", msg_map);
  }

  Future initCursorForPerson(String id)async{
    var sql = 'SELECT * FROM Messages1 WHERE roomId = ? OR author_id = ? ORDER BY createdAt DESC';
    cursor = await db.rawQueryCursor(sql, [id, id]);
  }

  Future initCursorForShow()async{
    var sql = 'SELECT * FROM Messages1 ORDER BY createdAt DESC';
    cursor = await db.rawQueryCursor(sql, []);
  }

  Future close() async => db.close();

  Future deleteAll()async{
    await db.execute('DELETE FROM Messages1');
  }
}