import 'package:flutter/material.dart';
import 'package:metas/src/models/metas_models.dart';
import 'package:metas/src/providers/DBProvider.dart';

class DataSearch extends SearchDelegate {

  

  @override
  List<Widget> buildActions(BuildContext context) {
    // Las acciones del AppBar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          query = '';
        },
      )
    ];
  }

 @override
  Widget buildLeading(BuildContext context) {
    // Icono a la izquierda del AppBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: (){
        close( context, null );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Crea los resultados que vamos a mostrar
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Muestra las sugerencias al escribir
    if ( query.isEmpty ) {
      return Container();
    }

    return FutureBuilder(
      future: DBProvider.db.getMetasByFilter(query),
      builder: (BuildContext context, AsyncSnapshot<List<Meta>> snapshot) {

          if( snapshot.hasData ) {
            
            final _listMetas = snapshot.data;
            
            return ListView(
              children: _listMetas.map( (meta) {
                  return ListTile(
                    title: Text( meta.titulo ),
                    subtitle: Text( meta.descripcion ),
                    onTap: (){
                      close( context, null);
                      Navigator.pushNamed(context, 'detalle', arguments: meta.id);
                    },
                  );
              }).toList()
            );
            
          } else {
            return Center(
              child: CircularProgressIndicator()
            );
          }

      },
    );
  }

}