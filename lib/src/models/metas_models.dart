import 'dart:convert';

class Metas {

  List<Meta> items = new List();

  Metas();

  Metas.fromJsonList( List<dynamic> jsonList  ) {

    if ( jsonList == null ) return;

    for ( var item in jsonList  ) {
      final meta = new Meta.fromJsonMap(item);
      items.add( meta );
    }

  }

}

String metaModelToJson(Meta data) => json.encode(data.toJson());

String listMetasToJson(List<Meta> data) => json.encode(data.map((c) => c.toJson()).toList());

class Meta{
  String id;
  String parentid;
  String titulo;
  String descripcion;
  String notas;
  double porcentaje;
  int eliminado;
  int sincronizado;
  int subtareas;
  DateTime fechaAdd;

  Meta({
    this.id,
    this.parentid,
    this.titulo,
    this.descripcion,
    this.notas,
    this.porcentaje,
    this.eliminado,
    this.sincronizado,
    this.fechaAdd
  });

  Meta.fromJsonMap(Map<String, dynamic> json) {

    print(json['fechaAdd']);

    id            = json['id'];
    parentid      = json['parentid'];
    titulo        = json['titulo'];
    descripcion   = json['descripcion'];
    notas         = json['notas'];
    porcentaje    = json['porcentaje'];
    eliminado     = json['eliminado'];
    sincronizado  = json['sincronizado'];
    fechaAdd  = DateTime.parse(json['fechaAdd']);

    if (json['subtareas'] != null){
      subtareas = json['subtareas'];
    }
  }

  Map<String, dynamic> toJson() => {
        "id"            : id,
        "titulo"        : titulo,
        "descripcion"   : descripcion,
        "notas"         : notas,
        "parentid"      : parentid,
        "porcentaje"    : porcentaje,
        "eliminado"     : eliminado,
        "sincronizado"  : sincronizado,
        "fechaAdd"      : fechaAdd.toString()
  };
}

