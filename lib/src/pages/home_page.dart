import 'package:flutter/material.dart';
import 'package:metas/src/bloc/metas_bloc.dart';
import 'package:metas/src/bloc/provider.dart';
import 'package:metas/src/models/metas_models.dart';
import 'package:metas/src/search/search_delegate.dart';
import 'package:metas/src/widgets/metas_list_widgt.dart';

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context)  {
    final metasBloc = Provider.of(context);

    metasBloc.obtenerMetas();

    return Scaffold(
      appBar: _titulo(context),
      body: _crearListado(context, metasBloc),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){

          final metaArgument = Meta();  
          metaArgument.id = '';
          metaArgument.parentid = '';

          Navigator.pushNamed(context, 'add', arguments: metaArgument);
        },
      ),
    );
  }

  Widget _crearListado(BuildContext context, MetasBloc bloc){
    return StreamBuilder<List<Meta>>(
      stream: bloc.metasStream,
      builder: (BuildContext context, AsyncSnapshot<List<Meta>> snapshot){

        if ( !snapshot.hasData ) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey)));
        }

        final _listMetas = snapshot.data.where((c) => c.parentid == '').toList();

        return Container(
          padding: EdgeInsets.only(top: 5.0),
            child: MetasListWidget(
              listMetas: _listMetas
            ),
        );
      },
    );
  }

  Widget _titulo(BuildContext context){
    return AppBar(
      title: Text('Mis Metas', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: DataSearch());
          },
          color: Colors.black,
        )
      ],
    );
  }
}