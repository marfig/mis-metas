import 'dart:convert';
import 'dart:io';

import 'package:metas/src/models/metas_models.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

class DBProvider {

  static Database _database; 
  String _apiKey    = '{api_key}';
  String _url       = '10.0.2.2:49937';
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {

    if ( _database != null ) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join( documentsDirectory.path, 'MetasDB.db' );

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: ( Database db, int version ) async {
        await db.execute(
          'CREATE TABLE Metas ('
          ' id TEXT PRIMARY KEY,'
          ' parentid INTEGER,'
          ' titulo TEXT,'
          ' descripcion TEXT,'
          ' notas TEXT,'
          ' porcentaje REAL,'
          ' eliminado INTEGER,'
          ' sincronizado INTEGER,'
          ' fechaAdd TEXT'
          ')'
        );
      }
    
    );

  }

  Future<int> countMetas() async {

    final db  = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Metas'));

    return count;
  }

  Future addMeta( Meta metaItem, bool actualizar) async {

    metaItem.eliminado = 0;

    if (metaItem.parentid == null){
      metaItem.parentid = '';
    }

    if (!actualizar){
      metaItem.sincronizado = 1;
    }
    else{
      metaItem.sincronizado = 0;
    }

    final db  = await database;
    final res = await db.insert('Metas',  metaItem.toJson() );

    if (actualizar){
      await actualizarPorcentajes(metaItem.parentid);
    }

    return res;
  }

  Future<Meta> getMetaById( String id ) async {

    final db  = await database;
    final res = await db.rawQuery("SELECT *, (select COUNT(*) FROM Metas where parentid = m.id) as subtareas FROM Metas m where id = '$id'");
    return res.isNotEmpty ? Meta.fromJsonMap( res.first ) : null;

  }

  Future<List<Meta>> getMetasByParentId(String parentid) async {

    final db  = await database;

    final res = await db.rawQuery("SELECT *, (select COUNT(*) FROM Metas where parentid = m.id) as subtareas FROM Metas m where eliminado = 0 AND parentid = '$parentid' order by fechaAdd");

    List<Meta> list = res.isNotEmpty 
                              ? res.map( (c) => Meta.fromJsonMap(c) ).toList()
                              : [];
    return list;
  }

  Future<List<Meta>> getMetasByFilter(String filter) async {

    final db  = await database;

    final res = await db.rawQuery("SELECT * FROM Metas m where eliminado = 0 AND titulo like '%$filter%' order by fechaAdd");

    List<Meta> list = res.isNotEmpty 
                              ? res.map( (c) => Meta.fromJsonMap(c) ).toList()
                              : [];
    return list;
  }

  Future<List<Meta>> getAllMetas() async {

    final db  = await database;

    final res = await db.rawQuery("SELECT *, (select COUNT(*) FROM Metas where parentid = m.id) as subtareas FROM Metas m where eliminado = 0 order by fechaAdd");

    List<Meta> list = res.isNotEmpty 
                              ? res.map( (c) => Meta.fromJsonMap(c) ).toList()
                              : [];
    return list;
  }
  
  Future<int> updateMeta( Meta item ) async {

    final db  = await database;
    
    final res = await db.rawUpdate("UPDATE Metas set sincronizado = 0, titulo = '${item.titulo}', descripcion = '${item.descripcion}', notas = '${item.notas}'  WHERE id='${item.id}'");

    return res;
  }

  Future<int> marcarComoSincronizados( List<Meta> items ) async {

    final db  = await database;

    final ids = items.map((f) => f.id).toList();
    
    final sql = "UPDATE Metas set sincronizado = 1 WHERE id in('${ids.join("' , '")}')";

    final res = await db.rawUpdate(sql);

    return res;
  }

  Future<int> setPorcentajeMeta(String id, double porcentaje) async {

    final db  = await database;
    
    final res = await db.rawUpdate("UPDATE Metas set sincronizado = 0, porcentaje = $porcentaje WHERE id='$id'");

    final _item = await getMetaById(id);

    await actualizarPorcentajes(_item.parentid);

    return res;
  }
  
  Future<int> deleteMeta( String id ) async {

    final _item = await getMetaById(id);

    final _parentid = _item.parentid;
    
    final db  = await database;
    final res = await db.rawUpdate("UPDATE Metas set sincronizado = 0, eliminado = 1 WHERE id='$id'");

    await actualizarPorcentajes(_parentid);

    return res;
  }

  Future<int> actualizarPorcentaje(String id, double porc) async {

    final db  = await database;
    
    final res = await db.rawUpdate("UPDATE Metas set sincronizado = 0, porcentaje = $porc WHERE id='$id'");

    return res;
  }

  Future actualizarPorcentajes (String parentid) async {
    if (parentid == null) return;

    if (parentid.trim().length > 0){
      final _childs = await getMetasByParentId(parentid);
      final _cantidad = _childs.length;
      double _monto = 0.0;

      _childs.forEach((f){
        _monto += f.porcentaje;
      });

      final _porc = _cantidad == 0 ? 0 : (_monto / _cantidad);

      final _parent = await getMetaById(parentid);

      await actualizarPorcentaje(_parent.id, _porc);

      await actualizarPorcentajes(_parent.parentid);
    }
  }

  //////////////// Sincronización con Servidor /////////////////////

  Future<List<Meta>> getAllMetasFromServer() async{
    final url = Uri.https(_url, '/api/metas/get-all', {
      'api_key'           : _apiKey
    });

    final resp = await _procesarGetResponse(url);

    resp.forEach((f) async {
      await addMeta(f, false);
    });

    return resp;
  }

  Future sincronizarConServidor() async {

    final db  = await database;
    final res = await db.query('Metas', where: 'sincronizado = ?', whereArgs: [0]);

    List<Meta> list = res.isNotEmpty 
                              ? res.map( (c) => Meta.fromJsonMap(c) ).toList()
                              : [];

    if (list.length > 0){
      final url = Uri.https(_url, '/api/metas/sincronize', {
        'api_key'           : _apiKey
      });
      
      Map<String, String> headers = {"Content-type": "application/json"};

      final _body = listMetasToJson(list);

      await http.post( url, headers: headers, body: _body );

      await marcarComoSincronizados(list);
    }
  }

  Future<List<Meta>> _procesarGetResponse(Uri url) async{
    final resp = await http.get(url);

    final decodedData = json.decode(resp.body);

    final metas = new Metas.fromJsonList(decodedData);

    return metas.items;
  }
}