import 'package:flutter/material.dart';
import 'package:metas/src/pages/detalle_page_content.dart';

class DetallePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final String metaid = ModalRoute.of(context).settings.arguments;

    return DetallePageContent(metaid: metaid);
  }
}