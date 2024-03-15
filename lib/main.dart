import 'package:flutter_decasteljau_demo/painter_path.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color backgroundColor = Color(0xFF202124);
  double tValue = 0.25; // Initial value of t

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: MyPainter(tValue: tValue), // Pass tValue to MyPainter
                child: Container(),
              ),
            ),
            Slider(
              value: tValue,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  tValue = value; // Update tValue when slider value changes
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CubicBezierCurve {
  final Point startPoint;
  final Point controlPoint1;
  final Point controlPoint2;
  final Point endPoint;

  CubicBezierCurve(this.startPoint, this.controlPoint1, this.controlPoint2, this.endPoint);
}

class MyPainter extends CustomPainter {
  Color pointColor = Color(0xFFD6D6D6);
  Color curveColor = Color(0xFF7B191E);
  Color linePrimaryColor = Color(0xFF8A6B52);
  Color lineSecondaryColor = Color(0xFF065B87);
  Color lineTertiaryColor = Color(0xFF439246);
  double pointWidth = 8;
  final double tValue;
  MyPainter({required this.tValue});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    Point transfromPoint = Point(100, 0);
    
    Point startPoint = Point(0, 400);
    Point c1 = Point(100, 200);
    Point c2 = Point(500, 200);
    Point endPoint = Point(600, 400);
    
    startPoint += transfromPoint;
    c1 += transfromPoint;
    c2 += transfromPoint;
    endPoint += transfromPoint;

    CubicBezierCurve curve = CubicBezierCurve(startPoint, c1, c2, endPoint);
    List<Point> curvePoints = adaptiveApproximateCubicBezier(curve, 1);
    
    Path curvePath = Path();
    // Draw the curve using the calculated points
    curvePath.moveTo(curvePoints[0].x, curvePoints[0].y);
    for (int i = 1; i < curvePoints.length; i++) {
      curvePath.lineTo(curvePoints[i].x, curvePoints[i].y);
    }
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = curveColor;
    canvas.drawPath(curvePath, paint);

    List<Point> points = [startPoint, c1, c2, endPoint];
    
    Path path = Path();
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    paint.color = linePrimaryColor;
    path.moveTo(points[0].x, points[0].y);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(path, paint);

    List<Color> lineColors = [lineSecondaryColor, lineTertiaryColor];
    
    List<Point> currentPoint = points;
    for (int index = 0; index < 2; index++) {
      List<Point> linesPoints = [];
      for (int i = 0; i < currentPoint.length - 1; i++) {
        Point p = Point.lerp(currentPoint[i], currentPoint[i+1], tValue);
        linesPoints.add(p);
      }
      Path newPath = Path();
      newPath.moveTo(linesPoints[0].x, linesPoints[0].y);
      for (int i = 1; i < linesPoints.length; i++) {
        newPath.lineTo(linesPoints[i].x, linesPoints[i].y);
      }
      paint.color = lineColors[index];
      canvas.drawPath(newPath, paint);
      currentPoint = linesPoints;
    }

    paint.color = pointColor;
    paint.style = PaintingStyle.fill;
    for (Point point in points) {
      drawPoint(point, canvas, paint);
    }
    
    Point pointOnCurve = Point.lerp(currentPoint[0], currentPoint[1], tValue);
    paint.color = curveColor;
    paint.style = PaintingStyle.fill;
    drawPoint(pointOnCurve, canvas, paint);
  }

  List<Point> adaptiveApproximateCubicBezier(CubicBezierCurve curve, double threshold) {
    List<Point> points = [];
    double length = calculateCurveLength(curve);

    if (length <= threshold) {
      points.add(curve.startPoint);
      points.add(curve.endPoint);
    } else {
      List<CubicBezierCurve> subCurves = splitCurve(curve, 0.5);
      CubicBezierCurve leftSubCurve = subCurves[0];
      CubicBezierCurve rightSubCurve = subCurves[1];

      points.addAll(adaptiveApproximateCubicBezier(leftSubCurve, threshold));
      points.addAll(adaptiveApproximateCubicBezier(rightSubCurve, threshold));
    }

    return points;
  }



  double calculateCurveLength(CubicBezierCurve curve) {
    double length = sqrt(pow(curve.startPoint.x - curve.endPoint.x, 2) + pow(curve.startPoint.y - curve.endPoint.y, 2));
    return length;
  }

  List<CubicBezierCurve> splitCurve(CubicBezierCurve curve, double t) {
    Point p0 = curve.startPoint;
    Point p1 = curve.controlPoint1;
    Point p2 = curve.controlPoint2;
    Point p3 = curve.endPoint;

    Point q0 = Point.lerp(p0, p1, t);
    Point q1 = Point.lerp(p1, p2, t);
    Point q2 = Point.lerp(p2, p3, t);
    Point r0 = Point.lerp(q0, q1, t);
    Point r1 = Point.lerp(q1, q2, t);
    Point s = Point.lerp(r0, r1, t);

    CubicBezierCurve leftSubCurve = CubicBezierCurve(p0, q0, r0, s);
    CubicBezierCurve rightSubCurve = CubicBezierCurve(s, r1, q2, p3);

    return [leftSubCurve, rightSubCurve];
  }

  void drawPoint(Point point, Canvas canvas, Paint paint) {
    canvas.drawOval(Rect.fromLTWH(point.x - pointWidth/2, point.y - pointWidth/2, pointWidth, pointWidth), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
