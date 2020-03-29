import 'package:flutter/material.dart';
import 'package:metas/src/bloc/metas_bloc.dart';
import 'package:metas/src/bloc/provider.dart';
import 'package:metas/src/models/metas_models.dart';
import 'package:metas/src/widgets/metas_list_widgt.dart';
import 'package:metas/src/widgets/progress_widget.dart';

class DetallePageContent extends StatefulWidget {

  final String metaid;

  const DetallePageContent({ @required this.metaid });

  @override
  _DetallePageContentState createState() => _DetallePageContentState();
}

class _DetallePageContentState extends State<DetallePageContent> {

  final estiloSubTitulo = TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);

  final estiloDescript = TextStyle(fontSize: 12.5, color: Colors.grey);
  
  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final metasBloc = Provider.of(context);

    return Scaffold(
      body: _cargarContenido(metasBloc),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){

          final metaArgument = Meta();  
          metaArgument.id = '';
          metaArgument.parentid = widget.metaid;

          Navigator.pushNamed(context, 'add', arguments: metaArgument );
        },
      ),
    );
  }

  Widget _cargarContenido(MetasBloc bloc){

    return StreamBuilder<List<Meta>>(
        stream: bloc.metasStream,
        builder: (BuildContext context, AsyncSnapshot<List<Meta>> snapshot){

          if ( snapshot.hasError ) {
            return Center(child: Text(snapshot.error) );
          }


          if ( !snapshot.hasData ) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey)));
          }

          final _meta = snapshot.data.where((c) => c.id == widget.metaid).toList()[0];
          final _listMetas = snapshot.data.where((c) => c.parentid == widget.metaid).toList();

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: _titulo(_meta, context, bloc),
              body: _cargarBody(_meta, _listMetas, context)
            ),
            
          );
          
        }
    );

  }

  Widget _cargarBody(Meta meta, List<Meta> listMetas, BuildContext context){

      return TabBarView(
            children: <Widget>[
              _detalle(meta, context),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: MetasListWidget(
                  listMetas: listMetas
                ),
              )
            ],
          );
  }

  Widget _titulo(Meta meta, BuildContext context, MetasBloc bloc){
    return AppBar(
            bottom: TabBar(
              labelColor: Colors.black,
              tabs: <Widget>[
                Tab(text: 'Detalles'),
                Tab(text: 'Sub Tareas')
              ],
            ),
            title: Text((meta.titulo ?? ''), style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            actions: _accionesAppBar(meta, bloc),
          );
  }

  List<Widget> _accionesAppBar(Meta meta, MetasBloc bloc){
    List<Widget> _lista = new List();

    _lista.add(
      IconButton(
                icon: Icon(Icons.edit),
                onPressed: (){
                  Navigator.pushNamed(context, 'add', arguments: meta);
                },
              )
    );

    if (meta.subtareas == 0){
      _lista.add(
      IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  _deleteMeta(context, meta.id, bloc);
                },
              )
      );
    }

    return _lista;
  }

  Widget _detalle(Meta meta, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Progreso:', style: estiloSubTitulo),
          SizedBox(height: 5.0),
          ProgressWidget(porcentaje: meta.porcentaje),
          SizedBox(height: 20.0),
          Text('Descripción:', style: estiloSubTitulo),
          SizedBox(height: 5.0),
          Text((meta.descripcion ?? ''), style: estiloDescript),
          SizedBox(height: 20.0),
          Text('Notas:', style: estiloSubTitulo),
          SizedBox(height: 5.0),
          Text((meta.notas ?? ''), style: estiloDescript),
          SizedBox(height: 5.0)
        ],
      ),
    );
  }

  void _deleteMeta(BuildContext context, String id, MetasBloc bloc){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Eliminar'),
          content: Text('Desea eliminar la meta seleccionada?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Si'),
              onPressed: (){
                bloc.borrarMeta(id);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }


}