import 'dart:async';
import 'package:metas/src/models/metas_models.dart';
import 'package:metas/src/providers/DBProvider.dart';

class MetasBloc {
  
  final _metasController = StreamController<List<Meta>>.broadcast();

  Stream<List<Meta>> get metasStream  => _metasController.stream;

  dispose() {
    _metasController?.close();
  }

  obtenerMetas() async {
    _metasController.sink.add( await DBProvider.db.getAllMetas() );
  }

  agregarMeta( Meta meta ) async{
    await DBProvider.db.addMeta(meta, true);
  }

  actualizarMeta( Meta meta ) async{
    await DBProvider.db.updateMeta(meta);
  }

  borrarMeta( String id ) async {
    await DBProvider.db.deleteMeta(id);
    obtenerMetas();
  }

  setPorcentajeMeta( String id, double porcentaje ) async {
    await DBProvider.db.setPorcentajeMeta(id, porcentaje);
    obtenerMetas();
  }

}