import 'package:flutter/material.dart';
import 'package:metas/src/providers/DBProvider.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    _actualizarDatos(context);

    return Scaffold(
      body: Center(
        child: Text("Actualizando datos...", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  void _actualizarDatos(BuildContext context) async {

    final cantidad = await DBProvider.db.countMetas();

    if (cantidad == 0){

      await DBProvider.db.getAllMetasFromServer();

      Navigator.of(context).pushReplacementNamed('home');

    }
    else{
      
      DBProvider.db.sincronizarConServidor();

      Navigator.of(context).pushReplacementNamed('home');

    }
  }
}