import 'package:flutter/material.dart';
import 'package:metas/src/bloc/metas_bloc.dart';

class Provider extends InheritedWidget {

  static Provider _instancia;

  factory Provider({ Key key, Widget child }) {

    if ( _instancia == null ) {
      _instancia = new Provider._internal(key: key, child: child );
    }

    return _instancia;

  }

  Provider._internal({ Key key, Widget child })
    : super(key: key, child: child );


  final metasBloc = MetasBloc();
 
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MetasBloc of ( BuildContext context ) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().metasBloc;
  }

}