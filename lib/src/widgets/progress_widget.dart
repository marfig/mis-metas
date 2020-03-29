import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressWidget extends StatelessWidget {

  final double porcentaje;

  ProgressWidget({ @required this.porcentaje });

  @override
  Widget build(BuildContext context) {
    return _crearProgress(porcentaje);
  }

  Widget _crearProgress(double porcentaje){
    return CircularPercentIndicator(
                  radius: 48.0,
                  animation: true,
                  animationDuration: 1000,
                  lineWidth: 6.0,
                  percent: porcentaje,
                  center: new Text("${(porcentaje*100).toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                  progressColor: _colorProgress(porcentaje)
                );
  }

  Color _colorProgress(double porcentaje){

    final valor = porcentaje * 100;

    if (valor < 25){
      return Colors.red;
    }

    if (valor >= 25 && valor < 50){
      return Colors.orange;
    }

    if (valor >= 50 && valor < 75){
      return Colors.yellow;
    }

    if (valor >= 75){
      return Colors.green;
    }

    return Colors.blueGrey;

  }
}