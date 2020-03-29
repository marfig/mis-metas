import 'package:flutter/material.dart';
import 'package:metas/src/bloc/metas_bloc.dart';
import 'package:metas/src/bloc/provider.dart';
import 'package:metas/src/models/metas_models.dart';
import 'package:metas/src/widgets/progress_widget.dart';

class MetasListWidget extends StatelessWidget {

  final List<Meta> listMetas;
  final estiloTitulo = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  final estiloDescript = TextStyle(fontSize: 12.5, color: Colors.grey);

  MetasListWidget({@required this.listMetas});

  @override
  Widget build(BuildContext context) {
    final metasBloc = Provider.of(context);

    if (listMetas.length == 0){
      return Center(child: Text("Click en '+' para agregar un item"));
    }

    return ListView.builder(
      itemCount: listMetas.length,
      itemBuilder: (BuildContext context, int index) {
        final _itemMeta = listMetas[index];
        return _crearItem(context, _itemMeta, metasBloc);
      },
    );
  }

  Widget _crearItem(BuildContext context, Meta item, MetasBloc bloc) {
    return  Column(
      children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            title: Text(item.titulo, style: estiloTitulo),
            subtitle: Text(item.descripcion, style: estiloDescript, textAlign: TextAlign.justify),
            leading: ProgressWidget(porcentaje: item.porcentaje),
            trailing: item.subtareas > 0 ? null : _checkBox(item.id, item.porcentaje, bloc),
            onTap: (){
              Navigator.pushNamed(context, 'detalle', arguments: item.id);
            },
          ),
          Divider()
      ],
    );
  }

  Widget _checkBox(String id, double porcentaje, MetasBloc bloc){
    return Checkbox(
      value: porcentaje == 1,
      onChanged: (value){

        final _setporc = porcentaje == 1.0 ? 0.0 : 1.0;

        bloc.setPorcentajeMeta(id, _setporc);
      },
      tristate: false,
    );
  }
}