import 'package:flutter/material.dart';
import 'package:metas/src/bloc/provider.dart';
import 'package:metas/src/pages/add_page.dart';
import 'package:metas/src/pages/detalle_page.dart';
import 'package:metas/src/pages/home_page.dart';
import 'package:metas/src/pages/login_page.dart';

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mis Metas',
        initialRoute: 'login',
        routes: {
          'login': (BuildContext context) => LoginPage(),
          'home': (BuildContext context) => HomePage(),
          'detalle': (BuildContext context) => DetallePage(),
          'add': (BuildContext context) => AddPage()
        },
      ),
    );
  }
}