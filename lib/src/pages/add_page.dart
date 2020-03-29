import 'package:flutter/material.dart';
import 'package:metas/src/bloc/metas_bloc.dart';
import 'package:metas/src/bloc/provider.dart';
import 'package:metas/src/models/metas_models.dart';
import 'package:uuid/uuid.dart';

class AddPage extends StatefulWidget {
  const AddPage();


  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  Meta _dataMeta = new Meta();
  
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Meta _meta = ModalRoute.of(context).settings.arguments;
    final metasBloc = Provider.of(context);

    return Scaffold(
      appBar: _titulo(context, _meta.id),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: <Widget>[
            _crearInputTitulo(_meta.titulo ?? ''),
            Divider(),
            _crearInputDescription(_meta.descripcion ?? ''),
            Divider(),
            _crearInputNotas(_meta.notas ?? '')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: (){
          _guardarEditarFormulario(context, _formKey, _meta.id, _meta.parentid, metasBloc);
        },
      ),
    );
  }

  Widget _titulo(BuildContext context, String metaid){
    final texto = metaid.trim().length == 0 ? 'Agregar nueva meta' : 'Editar meta';

    return AppBar(
      title: Text(texto, style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black)
    );
  }

  Widget _crearInputTitulo(String titulo) {
    return TextFormField(
      initialValue: titulo,
      maxLines: 1,
      validator: (value) {
        if (value.isEmpty) {
          return 'Debe ingresar el Título';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        hintText: 'Título',
        labelText: 'Título',
        icon: Icon(Icons.title)
      ),
      onSaved: (value){
        _dataMeta.titulo = value;
      },
    );
  }

  Widget _crearInputDescription(String descrip) {
    return TextFormField(
      maxLines: 3,
      initialValue: descrip,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        hintText: 'Descripción',
        labelText: 'Descripción',
        icon: Icon(Icons.description)
      ),
      onSaved: (value){
        _dataMeta.descripcion = value;
      },
    );
  }

  Widget _crearInputNotas(String notas) {
    return TextFormField(
      maxLines: 5,
      initialValue: notas,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        hintText: 'Notas',
        labelText: 'Notas',
        icon: Icon(Icons.note)
      ),
      onSaved: (value){
        _dataMeta.notas = value;
      },
    );
  }

  void _guardarEditarFormulario(BuildContext context, GlobalKey<FormState> formKey, String metaid, String parentid, MetasBloc bloc) {
    if(formKey.currentState.validate()){

      _dataMeta.id = metaid;
      
      if (metaid.trim().length == 0){
        formKey.currentState.save();
        
        _dataMeta.id = Uuid().v1();
        _dataMeta.parentid = parentid;
        _dataMeta.porcentaje = 0.0;
        _dataMeta.fechaAdd = DateTime.now();

        bloc.agregarMeta(_dataMeta);

        Navigator.pop(context);
      }

      if (metaid.trim().length > 0){
        formKey.currentState.save();
        
        _dataMeta.parentid = '';

        bloc.actualizarMeta(_dataMeta);

        Navigator.pop(context);
      }
    }
  }
}