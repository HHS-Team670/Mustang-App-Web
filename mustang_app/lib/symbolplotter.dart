import 'package:flutter/material.dart';
import 'mapscouter.dart';

class SymbolPlotter extends StatefulWidget {
  static const String route = './SymbolPlotter';

  List<PlotPoint> _plotPoint;

  SymbolPlotter(this._plotPoint);

  @override
  State<StatefulWidget> createState() {
    return _SymbolPlotterState(_plotPoint);
  }
}

class _SymbolPlotterState extends State<SymbolPlotter> {
  List<PlotPoint> _points;

  _SymbolPlotterState(this._points);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ScatterPlot(_points, context));
  }
}

class ScatterPlot extends CustomPainter {
  List<PlotPoint> _plotPoint;
  BuildContext _context;

  ScatterPlot(this._plotPoint, this._context);

  @override
  void paint(Canvas canvas, Size size) {
    double width = MediaQuery.of(_context).size.width,
        height = MediaQuery.of(_context).size.height;
    canvas.translate(-0.5*width, -1.33*height);    
    for (PlotPoint p in _plotPoint) {
      double x = (p.x * width);
      double y = (p.y * height);
      Paint ppPaint = Paint()
        ..color = p.fillColor
        ..strokeWidth = 5
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(x, y), p.radius, ppPaint);

      ppPaint.color = Colors.black;
      ppPaint.style = PaintingStyle.stroke;
      canvas.drawCircle(
          Offset(x, y), p.radius, ppPaint);

      TextSpan ppSpan = TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: p.fontSize,
          fontWeight: FontWeight.bold,
        ),
        text: p.avgScore,
      );
      TextPainter pptp = TextPainter(
        text: ppSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      pptp.maxLines = 1;
      pptp.layout();

      pptp.paint(
        canvas,
        Offset(x - pptp.width / 2, y - p.fontSize / 2),
      );
      
    }
  }

  @override
  bool shouldRepaint(ScatterPlot old) => true;
}
